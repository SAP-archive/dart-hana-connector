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

library protocol.connection.message_buffer;

import 'package:Connector/protocol/common/constants.dart';
import "package:Connector/util/util.dart";
import "dart:typed_data";

class MessageBuffer {
  int _length = 0;
  Map header;
  List _data;

  bool isReady() {
    return (header != null) && (_length >= header['length']);
  }
  
  int get length {
    return _length;
  }

  void push(Uint8List chunk) {
    if (chunk == null || chunk.length == 0) {
      return;
    }
    _length += chunk.length;
    if (_data == null) {
      _data = new Uint8List.fromList(chunk);
    } else {
      List newData = _data.toList(growable: true);
      newData.addAll(chunk);
      _data = new Uint8List.fromList(newData);
    }
    if (header == null && _length >= Constants.PACKET_HEADER_LENGTH) {
      readHeader();
    }
  }

  List getData() {
    return (_data is List) ? new Uint8List.fromList(_data) : _data;
  }

  void readHeader() {
    List buffer = getData();
    header = {
      'sessionId': readUInt64LE(buffer, 0),
      'packetCount': readUInt32LE(buffer, 8),
      'length': readUInt32LE(buffer, 12)
    };
    _data = buffer.sublist(Constants.PACKET_HEADER_LENGTH);
    _length -= Constants.PACKET_HEADER_LENGTH;
  }

  void clear() {
    _length = 0;
    header = null;
    _data = null;
  }
}
