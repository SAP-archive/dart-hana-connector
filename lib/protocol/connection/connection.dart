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

library protocol.connection.connection;

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:Connector/protocol/auth/auth.dart';
import 'package:Connector/protocol/auth/manager.dart';
import 'package:Connector/protocol/common/constants.dart';
import 'package:Connector/protocol/common/part_kind.dart';
import 'package:Connector/protocol/common/segment_kind.dart';
import 'package:Connector/protocol/connection/connection_state.dart';
import 'package:Connector/protocol/connection/message_buffer.dart';
import 'package:Connector/protocol/execute_task.dart';
import 'package:Connector/protocol/part/connect_options.dart';
import 'package:Connector/protocol/part/statement_contexts.dart';
import 'package:Connector/protocol/reply/reply.dart';
import 'package:Connector/protocol/reply/segment.dart' as ReplySegment;
import 'package:Connector/protocol/request/request.dart';
import 'package:Connector/protocol/request/segment.dart' as RequestSegment;
import 'package:Connector/protocol/tcp.dart' as tcp;
import 'package:Connector/protocol/transaction.dart';
import 'package:Connector/util/queue.dart';
import 'package:Connector/util/util.dart';

class Connection {
  static final MAX_AVAILABLE_SIZE = Constants.MAX_PACKET_SIZE - Constants.PACKET_HEADER_LENGTH - Constants.SEGMENT_HEADER_LENGTH - Constants.PART_HEADER_LENGTH;

  String _clientId;
  ConnectOptions _connectOptions = new ConnectOptions();

  Map _settings = new Map();
  Transaction _transaction;
  ConnectionState _state;
  RawSocket _socket;
  StatementContexts _statementContext;
  AuthManager _authManager;
  Completer _connectionCompleter;
  MessageBuffer _packet = new MessageBuffer();
  TaskQueue _queue = new TaskQueue();

  Connection(Map settings) {
    _clientId = clientId();
    if (settings != null) {
      _settings.addAll(settings);
    }

    _state = new ConnectionState();
    _transaction = new Transaction();
  }

  set connectionCompleter(Completer c) {
    _connectionCompleter = c;
  }

  TaskQueue get queue {
    return _queue;
  }

  Future open(Map options) {
    return tcp.connect(options);
  }

  void connect(RawSocket socket, Map connectOptions) {
    _socket = socket;
    AuthManager authManager = createAuthManager(connectOptions);
    _authManager = authManager;
    RequestSegment.Segment req = Request.authenticate({
      'authentication': authManager.initialData()
    });
    _queue.schedule(send, authReceive, positionalArgs: [req]);
  }

  void close() {
    if (_queue.isEmpty) {
      destroy();
    } else {
      _queue.schedule(destroy, null);
    }
  }

  void destroy() {
    _queue.clear();
    if (_socket != null) {
      _socket.close();
    }
  }

  void disconnect() {
    RequestSegment.Segment req = Request.disconnect();
    _queue.schedule(send, onReplyDisconnect, positionalArgs: [req]);
  }

  void onReplyDisconnect(Reply reply) {
    _statementContext = null;
    _state = new ConnectionState();
  }

  void onData(var chunk) {
    _packet.push(chunk);
    if (_packet.isReady()) {
      if (_state.sessionId != _packet.header['sessionId']) {
        _state.sessionId = _packet.header['sessionId'];
        _state.packetCount = -1;
      }
      List buffer = _packet.getData();
      _packet.clear();
      _state.messageType = null;
      receive(new Uint8List.fromList(buffer));
    }
  }

  void receive(Uint8List buffer) {
    ReplySegment.Segment segment = ReplySegment.Segment.createSegment(buffer, 0);
    Reply reply = segment.getReply();
    setStatementContext(reply.attributes['statementContext']);
    setTransactionFlags(reply.attributes['transactionFlags']);
    if (segment.kind == SegmentKind.ERROR.index) {
      _queue.onComplete(reply.attributes['error']);
    } else {
      _queue.onComplete(reply);
    }
  }

  void authReceive(Reply reply) {
    _authManager.initialize(reply.attributes['authentication']);
    RequestSegment.Segment authReq = Request.connect({
      'authentication': _authManager.finalData(),
      'clientId': _clientId,
      'connectOptions': _connectOptions.getOptions()
    });
    _queue.schedule(send, connReceive, positionalArgs: [authReq]);
  }

  void connReceive(reply) {
    if (reply is Error) {
      return _connectionCompleter.completeError(reply);
    }

    if (reply.attributes['connectOptions'] is List) {
      _connectOptions.setOptions((reply.attributes['connectOptions']));
    }

    _authManager.finalize(reply.attributes['authentication']);
    _settings['user'] = _authManager.getUserFromServer();
    if (_authManager.getSessionCookie() != null) {
      _settings['sessionCookie'] = _authManager.getSessionCookie();
    }
    _connectionCompleter.complete(1);
  }

  set autoCommit(bool c) {
    _transaction.autoCommit = c;
  }

  bool get autoCommit {
    return _transaction.autoCommit;
  }

  void setStatementContext(List options) {
    if (options != null && options.length > 0) {
      if (_statementContext == null) {
        _statementContext = new StatementContexts();
      }
      _statementContext.setOptions(options);
    } else {
      _statementContext = null;
    }
  }

  void setTransactionFlags([List flags = null]) {
    if (flags != null) {
      Map params = {};
      flags.forEach((item) {
        params.addAll(item);
      });
      _transaction.setFlags(params);
    }
  }

  void send(message) {

    if (_statementContext != null) {
      message.unshift(PartKindEnum.inst.STATEMENT_CONTEXT, _statementContext.getOptions());
    }

    int size = Constants.MAX_PACKET_SIZE - Constants.PACKET_HEADER_LENGTH;
    Uint8List buffer = message.toBuffer(size);
    List<int> packet = new List<int>();

    _state.messageType = message.messageType;
    // Increase packet count
    _state.packetCount++;
    // Session identifier
    writeInt64LE(packet, _state.sessionId);
    // Packet sequence number in this session
    // Packets with the same sequence number belong to one request / reply pair
    writeInt32LE(packet, _state.packetCount);
    // Used space in this packet
    writeInt32LE(packet, buffer.length);
    // Total space in this packet
    writeInt32LE(packet, size);
    // Number of segments in this packet
    writeInt16LE(packet, 1);
    // Filler
    for (int i = packet.length; i < Constants.PACKET_HEADER_LENGTH; i++) {
      packet.add(0);
    }
    packet.addAll(buffer);
    // Write request packet to socket
    if (_socket != null) {
      _socket.write(new Uint8List.fromList(packet));
    }
  }

  void executeDirect(Map options, Function callbackFunc) {
    options['autoCommit'] = _transaction.autoCommit;
    options['holdCursorsOverCommit'] = _settings['holdCursorsOverCommit'];
    options['scrollableCursor'] = _settings['scrollableCursor'];
    _queue.schedule(send, callbackFunc, positionalArgs: [Request.executeDirect(options)]);
  }

  void fetchNext(Function callbackFunc, Map options) {
    options['autoCommit'] = _transaction.autoCommit;
    _queue.schedule(send, callbackFunc, positionalArgs: [Request.fetchNext(options)]);
  }

  void prepare(Map options, Function callbackFunc) {
    options['holdCursorsOverCommit'] = _settings['holdCursorsOverCommit'];
    options['scrollableCursor'] = _settings['scrollableCursor'];
    _queue.schedule(send, callbackFunc, positionalArgs: [Request.prepare(options)]);
  }

  void execute(Function callbackFunc, [Map options = null]) {
    if (options == null) {
      options = new Map();
    }

    options['autoCommit'] = _transaction.autoCommit;
    options['holdCursorsOverCommit'] = _settings['holdCursorsOverCommit'];
    options['scrollableCursor'] = _settings['scrollableCursor'];
    if (options['parameters'].isEmpty) {
      _queue.schedule(send, callbackFunc, positionalArgs: [Request.execute({
          'autoCommit': _transaction.autoCommit,
          'holdCursorsOverCommit': _settings['holdCursorsOverCommit'],
          'scrollableCursor': _settings['scrollableCursor'],
          'statementId': options['statementId'],
          'parameters': new Uint8List.fromList([])
        })]);
    } else {
      ExecuteTask et = new ExecuteTask(this, options);
      et.run(callbackFunc);
    }
  }

  void commit(Map options, Function callbackFunc) {
    _queue.schedule(send, callbackFunc, positionalArgs: [Request.commit(options)]);
  }

  void rollback(Map options, Function callbackFunc) {
    _queue.schedule(send, callbackFunc, positionalArgs: [Request.rollback(options)]);
  }

  void readLob(Function callbackFunc, Map options) {
    if (options['locatorId'] != null) {
      options = {
        'readLobRequest': options
      };
    }
    options['autoCommit'] = _transaction.autoCommit;
    _queue.schedule(send, callbackFunc, positionalArgs: [Request.readLob(options)]);
  }

  int getAvailableSize() {
    var availableSize = MAX_AVAILABLE_SIZE;
    if (_statementContext != null) {
      availableSize -= _statementContext.size;
    }
    return availableSize;
  }

  writeLob(Function callbackFunc, Map options) {
    return queue.schedule(send, callbackFunc, positionalArgs: [Request.writeLob(options)]);
  }

  dropStatement(Completer c, Map options) {
    return queue.schedule(send, c.complete, positionalArgs: [Request.dropStatementId(options)]);
  }

}
