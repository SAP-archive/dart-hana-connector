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

library client.client;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:Connector/protocol/auth/auth.dart';
import 'package:Connector/protocol/connection/connection.dart';
import 'package:Connector/protocol/data/sqlerror.dart';
import 'package:Connector/protocol/result/result.dart';
import 'package:Connector/protocol/statement.dart';
import 'package:Connector/util/util.dart';

class Client {
  static const INITIALIZATIONREPLYLENGTH = 8;
  
  Map _settings = {};
  Connection _connection;
  RawSocket _socket;
  Map _protocolVersion;
  Map _connectOptions = new Map();

  Client(Map options) {
    _settings = new Map();
    _settings.addAll(options);
    _settings.addAll({
      'fetchSize': 1024,
      'holdCursorsOverCommit': true,
      'scrollableCursor': true,
      'autoReconnect': false
    });
    _connection = createConnection(_settings);
  }

  Connection createConnection(settings) {
    return new Connection(settings);
  }

  set autoCommit(bool c) {
    _connection.autoCommit = c;
  }

  bool get autoCommit {
    return _connection.autoCommit;
  }

  Future commit() {
    Completer commitCompleter = new Completer();
    
    void callbackOnCommit(reply) {
      if (reply is Error) {
        Future f = rollback();
        f.then((reply) {
          SQLError commitError = new SQLError(message: 'There was an error on commit. Transaction has been rolled back', code: 'EHDBCOMMIT');
          commitCompleter.completeError(commitError);  
        });
      } else {
        commitCompleter.complete(reply);
      }
    }
    
    _connection.commit({}, callbackOnCommit);
    return commitCompleter.future;
  }

  Future rollback() {
    Completer rollbackCompleter = new Completer();
    
    void callbackOnRollback(reply) {
      if (reply is Error) {
        rollbackCompleter.completeError(reply);
      } else {
        rollbackCompleter.complete(reply);
      }
    }
    
    _connection.rollback({}, callbackOnRollback);
    return rollbackCompleter.future;
  }

  Future connect(Map options) {
    var completer = new Completer();
    _connection.connectionCompleter = completer;
    Map openOptions = {
      "host": _settings["host"],
      "port": _settings["port"]
    };

    for (String key in SECURE_AUTH_KEYS) {
      if (_settings.containsKey(key)) {
        openOptions[key] = _settings[key];
      }
    }
    openOptions.addAll(options);

    for (String key in SESSION_KEYS) {
      if (_settings.containsKey(key)) {
        _connectOptions[key] = _settings[key];
      }
    }
    _connectOptions.addAll(options);
    Future future = _connection.open(openOptions);
    future.then((socket) {
      this._socket = socket;
      socket.write(HANDSHAKE_BUFFER);
      
      socket.listen((event) {
        switch (event) {
          case RawSocketEvent.READ:
            var buffer = socket.read();
            if (_protocolVersion == null) {
              //Reply would contain Initialization string
              _handleProtocolVersion(buffer);
            } else {
              _connection.onData(buffer);
            }
        }
      });
    },
    onError: (err) {
      if (err is Exception) {
        completer.completeError(new StateError(err.toString()));
      } else {
        completer.completeError(err);
      }
    });
    return completer.future;
  }
    
  Future exec(String command, {Map options, bool fetchResultForStreaming: false}) {
    Completer execCompleter = new Completer();
    Map defaults = {'autoFetch' : !fetchResultForStreaming};
    _executeDirect(defaults, command, execCompleter, options: options);
    return execCompleter.future;
  }

  Future execute(String command, {Map options}) {
    return exec(command, options: options, fetchResultForStreaming: true);
  }
  
  void _executeDirect(Map defaults, String command, Completer completer, {Map options}) {
    if (options is Map) {
      options.addAll(defaults);
    } else {
      options = defaults;
    }
    Map executeOptions = {
      'command': command,
    };

    Result result = new Result(_connection, options);
    
    void handleExecuteDirectReply(reply) {
      if (reply is Error) {
        completer.completeError(reply);
      } else {
        Future fRes = result.handle(reply);
        fRes.then((var rep) {
          completer.complete(rep);
        }, onError: (Error e) {
          completer.completeError(e);
        });
      }
    }
    
    _connection.executeDirect(executeOptions, handleExecuteDirectReply);    
  }

  Future prepare(String command, {Map options}) {
    var completer = new Completer();
    Map pOptions = new Map();
    if (options != null) {
      pOptions.addAll(options);
    }
    pOptions['command'] = command;
    
    void callbackOnPrepare(reply) {
      if (reply is Error) {
        completer.completeError(reply);
      } else {
        Statement statement = new Statement(_connection);
        Statement s = statement.handle(reply);
        completer.complete(s);
      }
    }
    
    _connection.prepare(pOptions, callbackOnPrepare);
    return completer.future;
  }

  void close() {
    _connection.close();
  }

  void disconnect() {
    _connection.disconnect();
  }

  void _handleProtocolVersion(var buffer) {
    if (buffer.length < INITIALIZATIONREPLYLENGTH) {
      throw new StateError('Invalid initialization reply. Error Code: EHDBINIT');
    }
    Map initializationReply = _getInitializationReplyInfo(buffer);
    _protocolVersion = initializationReply['protocolVersion'];
    _connection.connect(_socket, _connectOptions);
  }

  static Map<String, Map> _getInitializationReplyInfo(Uint8List buffer) {
    Map productVersion = {
      'major': buffer[0],
      'minor': readUInt16LE(buffer, 1)
    };
    Map protocolVersion = {
      'major': buffer[3],
      'minor': readUInt16LE(buffer, 4)
    };
    return {
      'productVersion': productVersion,
      'protocolVersion': protocolVersion
    };
  }
}
