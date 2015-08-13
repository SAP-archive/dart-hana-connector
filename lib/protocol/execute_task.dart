/**
Copyright 2015 SAP Labs LLC

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
 */

import 'dart:async';
import 'dart:typed_data';

import 'package:Connector/protocol/common/function_code.dart';
import 'package:Connector/protocol/connection/connection.dart';
import 'package:Connector/protocol/reply/reply.dart';
import "package:Connector/protocol/request/request.dart";
import 'package:Connector/protocol/writer.dart';


class ExecuteTask {
  static const int STATEMENT_ID_PART_LENGTH = 24;

  Connection _connection;
  var _autoCommit;
  bool _needFinializeTransaction;
  var _holdCursorsOverCommit;
  var _scrollableCursor;
  var _statementId;
  int _functionCode;
  Writer _writer;
  var _parameterValues;
  var _reply;

  ExecuteTask(Connection connection, options) {
    _connection = connection;
    _autoCommit = options['autoCommit'];
    _needFinializeTransaction = false;
    _holdCursorsOverCommit = options['holdCursorsOverCommit'];
    _scrollableCursor = options['scrollableCursor'];
    _statementId = options['statementId'];
    _functionCode = options['functionCode'];
    _writer = new Writer(options['parameters']['types']);

    var values = options['parameters']['values'];
    if (values is List && values.length > 0 && values[0] is List) {
      _parameterValues = values.toList(growable: true);

      if (_functionCode != FunctionCode.DDL.index && _functionCode != FunctionCode.INSERT.index && _functionCode != FunctionCode.UPDATE.index && _functionCode != FunctionCode.DELETE.index) {
         throw new StateError('Statement in batch must be DDL or DML');
      }

    } else {
      _parameterValues = [values];
    }
    _reply = null;
  }

  void run(Function callbackFunc) {

    Function writeLob;
    Reply previousReply;

    done(res) {
      end(previousReply, callbackFunc);
    }

    finalize(response) {
      if (!_needFinializeTransaction) {
        return end(response, callbackFunc);
      }
      if (response is Error) {
        return sendRollback(done);
      }
      sendCommit(done);
    }

    execute() {
      if (_parameterValues.length == 0) {
        return finalize(previousReply);
      }

      callbackFunction(reply) {
        if (reply is Error || reply is String) {
          return finalize(reply);
        } else {
          previousReply = reply;
          pushReply(reply);
          if (!_writer.finished && reply.attributes.containsKey('writeLobReply')) {
            _writer.update(reply.attributes['writeLobReply']);
          }
          writeLob();
        }
      }
      sendExecute(callbackFunction);
    }

    writeLob = () {
      if (_writer.finished) {
        return execute();
      }

      callbackFunction(response) {
        if (response is Error) {
          return finalize(response);
        }
        writeLob();
      }
      sendWriteLobRequest(callbackFunction);
    };
    execute();
  }

  void sendExecute(Function callbackFunc) {
    var availableSize = _connection.getAvailableSize() - STATEMENT_ID_PART_LENGTH;

    Completer com = new Completer();
    try {
      var parameters = getParameters(availableSize, com);
    } catch (err) {
      callbackFunc(err);
    }
    com.future.then((parameters) {
      _connection.queue.schedule(_connection.send, callbackFunc, positionalArgs: [Request.execute({
          'autoCommit': _autoCommit,
          'holdCursorsOverCommit': _holdCursorsOverCommit,
          'scrollableCursor': _scrollableCursor,
          'statementId': _statementId,
          'parameters': parameters
        })]);
    }, onError: (err) {
      callbackFunc(err);
    });
  }

  sendWriteLobRequest(Function callbackFunc) {
    var availableSize = _connection.getAvailableSize();

    callbackFunction(buffer) {
      if (buffer is Error) {
        callbackFunction(buffer);
        return;
      } else {
        _connection.writeLob(callbackFunc, {
          'writeLobRequest': buffer
        });
      }
    }
    _writer.getWriteLobRequest(availableSize, callbackFunction);
  }

  sendCommit(Function callbackFunc) {
    _connection.commit({
      'holdCursorsOverCommit': _holdCursorsOverCommit
    }, callbackFunc);
  }

  sendRollback(Function callbackFunc) {
    _connection.rollback({
      'holdCursorsOverCommit': _holdCursorsOverCommit
    }, callbackFunc);
  }

  end(result, Function callbackFunc) {
    callbackFunc(result);
  }

  pushReply(val) {
    if (_reply == null) {
      _reply = val;
      return;
    }
    if (val.attributes['rowsAffected'] != null) {
      if (_reply.attributes['rowsAffected'] is! List) {
        _reply.attributes['rowsAffected'] = [_reply.attributes['rowsAffected']];
      }
      _reply.attributes['rowsAffected'] = _reply.attributes['rowsAffected'].add(val.attributes['rowsAffected']);
    }
  }

  getParameters(int availableSize, Completer com) {
    int bytesWritten = 0;
    List args = [];

    next() {
      if (_parameterValues.length == 0) {
        com.complete(args);
        return;
      }

      setValuesCallbackFunction() {
        int remainingSize = availableSize - bytesWritten;
        if (_writer.length > remainingSize) {
          com.complete(args);
          return;
        }

        getParamsCallbackFunction(buffer) {
          if (buffer is Error) {
            throw buffer;
          }

          bytesWritten += buffer.lengthInBytes;
          args.add(buffer);

          if (!_writer.finished) {
            if (_autoCommit) {
              _needFinializeTransaction = true;
              _autoCommit = false;
            }
            com.complete(args);
            return;
          }
          next();
        }
        
        Uint8List buffer = _writer.getParameters(remainingSize, getParamsCallbackFunction);
      }

      if (_writer.length == 0) {
        try {
          _writer.setValues(_parameterValues.removeAt(0));
          setValuesCallbackFunction();
        } catch (e) {
          com.completeError(e);
        }
      } else {
        setValuesCallbackFunction();
      }
    }

    return next();
  }
}
