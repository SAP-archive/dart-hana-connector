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

library protocol.result.result;

import "dart:async";
import "package:Connector/protocol/connection/connection.dart";
import "package:Connector/protocol/lob.dart";
import 'package:Connector/protocol/reply/reply.dart';
import "package:Connector/protocol/common/function_code.dart";
import "package:Connector/protocol/result/result_set.dart";
import 'package:Connector/protocol/result/reader.dart';
import 'package:Connector/protocol/result/parser.dart';
import 'package:Connector/protocol/common/type_code.dart';
import 'package:Connector/protocol/data/transaction_flags.dart';

class Result {
  Connection _connection;
  bool _autoFetch;
  int _readSize;
  var _resultSetMetadata;
  var _parameterMetadata;


  Result(this._connection, Map options) {
    if (options == null) {
      options = new Map();
    }
    _autoFetch = (options['autoFetch'] == null) ? true : options['autoFetch'];
    _readSize = (options['readSize'] == null) ? Lob.DEFAULT_READ_SIZE : options['readSize'];
    _resultSetMetadata = null;
    _parameterMetadata = null;
  }

  void set resultSetMetadata(var metadata) {
    _resultSetMetadata = metadata;
  }

  void set parameterMetadata(var metadata) {
    _parameterMetadata = metadata;
  }

  List<String> getLobColumnNames() {
    if (_parameterMetadata != null) {
      List lobColumnNames = new List();
      for (int i = 0; i < _parameterMetadata.length; i++) {
        if (Lob.isLobType(_parameterMetadata[i])) {
          lobColumnNames.add(_parameterMetadata[i]._name);
        }
      }
      return lobColumnNames;
    }
    return [];
  }

  Future handle(Reply reply) {
    Completer cHandle = new Completer();
    int funcCode = reply.functionCode;

    if (funcCode == FunctionCode.SELECT.index || funcCode == FunctionCode.SELECT_FOR_UPDATE.index) {
      Future f = handleQuery(createResultSets(reply.resultSets));
      f.then((var result) {
        cHandle.complete(result);
      }, onError: (Error err) {
        cHandle.completeError(err);
      });
    } else if (funcCode == FunctionCode.INSERT.index || funcCode == FunctionCode.UPDATE.index || funcCode == FunctionCode.DELETE.index) {
      Map result = handleModify(reply);
      cHandle.complete(result);
    } else if (funcCode == FunctionCode.DDL.index) {
      cHandle.complete(1);
    } else if (funcCode == FunctionCode.DB_PROCEDURE_CALL.index || funcCode == FunctionCode.DB_PROCEDURE_CALL_WITH_RESULT.index) {
      handleDBCall(createOutputParameters(reply.attributes['outputParameters']), createResultSets(reply.resultSets), cHandle);
    } else if (funcCode == FunctionCode.NIL.index) {
      cHandle.completeError(reply.attributes['error']);
    } else {
      cHandle.completeError(new StateError('Error on operation as it returned Invalid or unsupported functioncode.'));
    }
    return cHandle.future;
  }

  Future handleQuery(List<ResultSet> resultSets) {
    Completer cQuery = new Completer();

    done(results) {
      cQuery.complete(results);
      return cQuery.future;
    }

    if (!_autoFetch) {
      return done(resultSets[0]);
    }
    
    Future fFetchall = fetchAll(resultSets);
    fFetchall.then((List results) {
      cQuery.complete(results);
    }, onError: (err) {
      cQuery.completeError(err);
    });
    return cQuery.future;
  }

  handleModify(Reply reply) {
    Map affected = new Map.from({
      'rowsAffected': reply.attributes['rowsAffected']
    });
    return affected;
  }

  handleDBCall(Map params, List<ResultSet> resultSets, Completer cHandle) {
    if (params == null) {
      params = new Map();
    }

    done(results) {
      List args = [params];
      args.addAll(results);
      cHandle.complete(args);
    }

    doneWithError(Error e) {
      cHandle.completeError(e);
    }

    if (!_autoFetch) {
      done(resultSets);
    }

    Future fReadLobs = readLobs(getLobColumnNames(), params);
    fReadLobs.then((val) {
      Future fFetch = fetchAll(resultSets, false);
      fFetch.then((results) {
        done(results);
      }, onError: (Error e) {
        doneWithError(e);
      });
    }, onError: (Error e) {
      doneWithError(e);
    });
  }

  ResultSet _createResultSet(var rs) {
    return new ResultSet(_connection, rs);
  }

  List<ResultSet> createResultSets(List resultSets) {
    if (resultSets == null) {
      resultSets = new List();
    }
    // handle missing resultSet metadata
    if (_resultSetMetadata != null && resultSets.length > 0) {
      if (resultSets[0]['metadata'] == null) {
        resultSets[0]['metadata'] = _resultSetMetadata;
      }
    }
    List<ResultSet> rsList = new List<ResultSet>();
    for (int i = 0; i < resultSets.length; i++) {
      rsList.add(_createResultSet(resultSets[i]));
    }
    return rsList;
  }

  Future fetchAll(List resultSets, [combineResultsets = true]) {
    List results = new List();
    Completer cFetchall = new Completer();

    next(int i) {
      handleFetch(rows) {
        results.add(rows);
        next(i + 1);
      }
      ;

      if (i == resultSets.length) {
        List finalResult = new List();
        if (combineResultsets) {
          for (int i = 0; i < results.length; i++) {
            finalResult.addAll(results[i]);
          }
        } else {
          finalResult = results;
        }
        return cFetchall.complete(finalResult);
      } else {
        Future ftch = resultSets[i].fetch();
        ftch.then((var rows) {
          handleFetch(rows);
        })
        .catchError((err) {
          return cFetchall.completeError(err);
        });
      }
    }

    next(0);
    return cFetchall.future;
  }

  Map createOutputParameters(outputParams) {
    if (_parameterMetadata != null && outputParams != null) {
      Reader r = new Reader(outputParams.buffer, this);
      Parser p = new Parser(_parameterMetadata);
      return p.parseFunction('name', r);
    }
    return null;
  }

  Future readLobs(List<String> keys, Map params) {
    Completer cReadLobs = new Completer();
    next(i) {
      if (i == keys.length) {
        cReadLobs.complete(null);
      } else {
        String name = keys[i];
        var lob = params[name];
        if (!(lob is Lob)) {
          next(i + 1);
        }

        Future fLobRead = lob.read();
        fLobRead.then((lobVal) {
          params[name] = lobVal;
          next(i + 1);
        }, onError: (Error e) {
          cReadLobs.completeError(e);
        });
      }
    }
    next(0);
    return cReadLobs.future;
  }

}
