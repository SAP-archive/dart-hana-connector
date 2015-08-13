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

library protocol.result.reader;

import 'dart:typed_data';
import 'package:Connector/util/cesu8_coding.dart';
import 'package:Connector/util/util.dart';
import 'package:Connector/protocol/common/lob_options.dart';
import 'package:Connector/protocol/lob_descriptor.dart';

class Reader {
  Uint8List _buffer;
  int _offset;
  var _lobFactory;
  
  Reader(this._buffer, this._lobFactory) {
    _offset = 0;
  }

  bool hasMore() {
    return _offset < _buffer.length;
  }

  int readTinyInt() {
    if (_buffer[_offset++] == 0x00) {
      return null;
    }
    int value = _buffer[_offset];
    _offset += 1;
    return value;
  }

  int readSmallInt() {
    if (_buffer[_offset++] == 0x00) {
      return null;
    }
    int value = readInt16LE(_buffer, _offset);
    _offset += 2;
    return value;
  }

  int readInt() {
    if (_buffer[_offset++] == 0x00) {
      return null;
    }
    int value = readInt32LE(_buffer, _offset);
    _offset += 4;
    return value;
  }

  int readBigInt() {
    if (_buffer[_offset++] == 0x00) {
      return null;
    }
    int value = readInt64LE(_buffer, _offset);
    _offset += 8;
    return value;
  }

  readString() {
    return readBytes('cesu8');
  }

  readBinary() {
    return readBytes();
  }

  readBytes([String encoding = null]) {
    int length = _buffer[_offset++];
    switch (length) {
    case 0xff:
      return null;
    case 0xf6:
      length = readUInt16LE(_buffer, _offset);
      _offset += 2;
      break;
    case 0xf7:
      length = readUInt32LE(_buffer, _offset);
      _offset += 4;
      break;
    }
    var value;
    if (encoding != null) {
      if (encoding == 'cesu8') {
        int maxLimit = (_offset + length > _buffer.length) ? _buffer.length : _offset + length;
        value = decodeCESU8(_buffer.sublist(_offset, maxLimit));
      }
    } else {
      value = new List.from([], growable: true);
      int maxLimit = (_offset + length > _buffer.length) ? _buffer.length : _offset + length;
      value.addAll(_buffer.sublist(_offset, maxLimit));
      value = new Uint8List.fromList(value);
    }
    _offset += length;
    return value;
  }

  String readDate() {
    int high = _buffer[_offset + 1];
    // msb not set ==> null
    if (high & 0x80 == 0) {
      _offset += 4;
      return null;
    }
    int year = _buffer[_offset];
    _offset += 2;
    int month = _buffer[_offset] + 1;
    _offset += 1;
    int day = _buffer[_offset];
    _offset += 1;
    // msb set ==> not null
    // unset msb and second most sb
    high &= 0x3f;
    year |= high << 8;
    return intToString(year, pad: 4) + '-' +
      intToString(month, pad: 2) + '-' +
      intToString(day, pad: 2);
  }

  String readTime() {
    int hour = _buffer[_offset];
    // msb not set ==> null
    if (hour & 0x80 == 0) {
      _offset += 4;
      return null;
    }
    int min = _buffer[_offset + 1];
    _offset += 2;
    int msec = readUInt16LE(_buffer, _offset);
    _offset += 2;
    // msb set ==> not null
    // unset msb
    hour &= 0x7f;
    return intToString(hour, pad: 2) + ':' +
        intToString(min, pad: 2) + ':' +
        intToString((msec/1000).floor(), pad: 2);
  }

  String readTimestamp() {
    String date = readDate();
    String time = readTime();
    if (date != null) {
      if (time != null) {
        return date + 'T' + time;
      }
      return date + 'T00:00:00';
    }
    
    return (time != null) ? '0001-01-01T' + time : null;
  }

  readDayDate() {
    int value = readUInt32LE(_buffer, _offset);
    _offset += 4;
    return (value == 3652062 || value == 0)  ? null : value - 1;
  }

  int readSecondTime() {
    int value = readUInt32LE(_buffer, _offset);
    _offset += 4;
    return (value == 86402 || value == 0) ? null : value - 1;
  }

  int readSecondDate() {
    int value = readUInt64LE(_buffer, _offset);
    _offset += 8;
    return (value == 315538070401 || value == 0) ? null :value - 1;
  }

  int readLongDate() {
    var value = readUInt64LE(_buffer, _offset);
    _offset += 8;
    if (value == '3155380704000000001' || value == 0) {
      return null;
    }
    if (value is String) {
      int index = value.length - 7;
      return value.substring(0, index) + intToString((value.substring(index) as int) - 1);
    } else {
      return value - 1;
    }
  }

  readBLob() {
    return readLob(1);
  }

  readCLob() {
    return readLob(2);
  }

  readNCLob() {
    return this.readLob(3);
  }

  readLob(int type) {
    if (type == null) {
      type = _buffer[_offset];
    }
    _offset += 1;
    
    int options = _buffer[_offset];
    _offset += 1;
    
    if (options & LobOptions.NULL_INDICATOR.value != 0) {
      return null;
    }
    _offset += 2;
    
    int charLength = readInt64LE(_buffer, _offset);
    _offset += 8;
    
    int byteLength = readInt64LE(_buffer, _offset);
    _offset += 8;
    
    Uint8List locatorId = _buffer.sublist(_offset, _offset + 8);
    _offset += 8;
    
    int maxLimit = (_buffer.length < _offset + 4) ? _buffer.length : _offset + 4;
    int chunkLength = readInt32LE(_buffer.sublist(_offset, maxLimit), 0);
    _offset += 4;
    
    Uint8List chunk = null;
    if (chunkLength > 0) {
      chunk = _buffer.sublist(_offset, _offset + chunkLength);
      _offset += chunkLength;
    } else {
      chunk = new Uint8List.fromList([]);
    }
    
    return _lobFactory.createLob(new LobDescriptor(type, locatorId, options, chunk));
  }

  double readDouble() {
    if (_buffer[_offset] == 0xff &&
      _buffer[_offset + 1] == 0xff &&
      _buffer[_offset + 2] == 0xff &&
      _buffer[_offset + 3] == 0xff &&
      _buffer[_offset + 4] == 0xff &&
      _buffer[_offset + 5] == 0xff &&
      _buffer[_offset + 6] == 0xff &&
      _buffer[_offset + 7] == 0xff) {
      _offset += 8;
      return null;
    }
    _offset += 8;
    return new ByteData.view(_buffer.buffer).getFloat64(_offset - 8, Endianness.LITTLE_ENDIAN);
  }

  double readFloat() {
    if (_buffer[_offset] == 0xff &&
      _buffer[_offset + 1] == 0xff &&
      _buffer[_offset + 2] == 0xff &&
      _buffer[_offset + 3] == 0xff) {
      _offset += 4;
      return null;
    }
    _offset += 4;
    return new ByteData.view(_buffer.buffer).getFloat32(_offset - 4, Endianness.LITTLE_ENDIAN);
  }
  
  double readDecimal([int fraction = 0]) {
    var value;
    if (fraction > 34) {
      value = readDecFloat(_buffer, _offset);
    } else {
      value = readDecFixed(_buffer, _offset, fraction);
    }
    _offset += 16;
    return value;
  }
}
