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

library protocol.lob;

import 'dart:async';
import "dart:math" as math;
import 'dart:typed_data';

import 'package:Connector/protocol/common/lob_source_type.dart';
import 'package:Connector/protocol/lob_descriptor.dart';
import 'package:Connector/protocol/common/type_code.dart';
import 'package:Connector/util/cesu8_coding.dart';

class Lob {
  static final DEFAULT_READ_SIZE = math.pow(2, 17);
  static final MAX_READ_SIZE = math.pow(2, 18);

  var _locatorId;
  bool _finished;
  Function _readLob;
  bool _running;
  int _offset;
  int _readSize;
  var _data;
  int _lobType;

  List _chunks;
  int _chunksLength;
  Completer _completer;
  Completer dataRead;

  bool _isCreateReadStream = false;
  StreamController _streamController;

  Lob(readLob, LobDescriptor ld, Map options) {
    _locatorId = ld.locatorId;
    _finished = false;
    _readLob = readLob;
    _running = null;
    _offset = 0;

    if (options == null) {
      options = new Map();
    }

    _readSize = (options['readSize'] == null) ? Lob.DEFAULT_READ_SIZE : options['readSize'];
    _data = (ld.chunk != null) ? ld : null;
    _lobType = ld.lobType;
  }

  Future createReadStream() {
    _isCreateReadStream = true;
    _streamController = new StreamController(onResume: resume, onPause: pause, onListen: resume, onCancel: pause);
    return read();
  }

  Future read() {
    _completer = new Completer();
    if (_running != null) {
      _completer.completeError(new StateError('Lob invalid state error'));
    }
    readData();
    return _completer.future;
  }

  void pause() {
    _running = false;
  }

  void resume() {
    if (_running != null && (_running || _finished)) {
      return;
    }
    _running = true;
    if (_data != null) {
      handleData(_data);
      _data = null;
    } else {
      sendReadLob();
    }
  }

  void sendReadLob() {
    Map op = new Map();
    op['locatorId'] = _locatorId;
    op['offset'] = _offset + 1;
    op['length'] = _readSize;
    _readLob(op, receiveData);
  }

  void receiveData(reply) {
    if (reply is Error) {
      _running = false;
      _completer.completeError(reply);
    } else {
      var data = reply.attributes['readLobReply'];
      if (_running) {
        handleData(data);
      } else {
        _data = data;
      }
    }
  }

  void handleData(data) {
    int size;
    try {
      size = data.size;
    } catch (e) {
      size = _readSize;
    }
    if (data.chunk is Uint8List) {
      _offset += size;
      onChunkData(data.chunk);
    }

    if (data.isLast()) {
      _finished = true;
      _running = false;
      onEnd();
    }

    if (_running) {
      sendReadLob();
    }
  }

  void onEnd() {
    if (_isCreateReadStream) {
      _completer.complete(_streamController.stream);
      _streamController.close();
    } else {
      List res = new List();
      for (int i = 0; i < _chunks.length; i++) {
        res.addAll(_chunks[i]);
      }
      if (_lobType == LobSourceType.CLOB.index || _lobType == LobSourceType.NCLOB.index) {
        try {
          return _completer.complete(decodeCESU8(res));  
        } catch (err) {
          return _completer.completeError(new StateError(err.toString()));
        }
      } else {
        _completer.complete(res);
      }
    }
  }

  void readData() {
    _chunksLength = 0;
    _chunks = [];
    resume();
  }

  void onChunkData(chunk) {
    if (_isCreateReadStream) {
      if (_lobType == LobSourceType.CLOB.index || _lobType == LobSourceType.NCLOB.index) {
        _streamController.add(decodeCESU8(chunk)); // add to the stream
      } else {
        _streamController.add(chunk); // add to the stream
      }
    } else {
      _chunks.add(chunk);
      _chunksLength += chunk.length;
    }
  }

  static bool isLobType(var column) {
    List<int> blobTypes = [TypeCode.BLOB.index, TypeCode.LOCATOR.index, TypeCode.CLOB.index, TypeCode.NCLOB.index, TypeCode.NLOCATOR.index, TypeCode.TEXT.index];
    return (blobTypes.contains(column.dataType));
  }
}
