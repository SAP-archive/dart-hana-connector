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
import "dart:mirrors";
import 'dart:convert';

import 'package:Connector/protocol/common/normalized_type_code.dart';
import 'package:Connector/protocol/common/type_code.dart';
import 'package:Connector/protocol/common/lob_options.dart';
import "package:Connector/util/cesu8_coding.dart";
import "package:Connector/util/util.dart";

class Writer {
  static final Map<int, String> WRITE_FUNCTIONS = {
    TypeCode.INT.index         : 'writeInt',
    TypeCode.TINYINT.index     : 'writeTinyInt',
    TypeCode.SMALLINT.index    : 'writeSmallInt',
    TypeCode.BIGINT.index      : 'writeBigInt',
    TypeCode.DOUBLE.index      : 'writeDouble',
    TypeCode.REAL.index        : 'writeReal',
    TypeCode.DECIMAL.index     : 'writeDecimal',
    TypeCode.STRING.index      : 'writeString',
    TypeCode.NSTRING.index     : 'writeNString',
    TypeCode.DATE.index        : 'writeDate',
    TypeCode.TIME.index        : 'writeTime',
    TypeCode.TIMESTAMP.index   : 'writeTimestamp',
    TypeCode.NCLOB.index       : 'writeNClob',
    TypeCode.TEXT.index        : 'writeNClob',
    TypeCode.BLOB.index        : 'writeBlob',
    TypeCode.CLOB.index        : 'writeClob',
    TypeCode.BINARY.index      : 'writeBinary',
  };

  var _types;
  List _lobs;
  List _buffers;
  int _bytesWritten;
  int _argumentCount;
  StreamSubscription _subscription = null;
  Completer _writeLobRequestCompleter = null;

  static const int FINALIZE_PARAMETERS = 1;
  static const int FINALIZE_WRITE_LOB_REQUEST = 2;

  Writer(types) {
    _types = types.map(normalizeType).toList();
    _lobs = [];
    clear();
  }

  normalizeType(type) {
    ClassMirror cm = reflectClass(NormalizedTypeCodeEnum);
    String s = TypeCode.values[type].toString();
    s = s.substring(s.indexOf('.')+1);
    return cm.getField(new Symbol(s)).reflectee.index;
  }

  void clear() {
    _buffers = [];
    _bytesWritten = 0;
    _argumentCount = 0;
  }

  int get length {
    return _bytesWritten;
  }

  setValues(values) {
    _lobs = [];
    clear();
    for (var i = 0; i < values.length; i++) {
      add(_types[i], values[i]);
    }
  }

  void add(type, value) {
    if (value == null) {
      pushNull(type);
    } else {
      InstanceMirror im = reflect(this);
      var symbol = new Symbol(WRITE_FUNCTIONS[type]);
      try {
        im.invoke(symbol, [value]);
      } catch (e) {
        throw (new StateError("ERROR: Invalid parameter datatype or datatype not supported!"));
      }
    }
  }

  void pushNull(type) {
    ByteBuffer buffer = new Uint8List(5).buffer;
    ByteData bdata = new ByteData.view(buffer);
    bdata.setUint8(0, normalizeType(type) | 0x80);
    push(bdata);
  }

  void push(ByteData buffer) {
    _bytesWritten += buffer.lengthInBytes;
    _buffers.add(buffer);
  }

  void pushLob(bufferList, value) {
    ByteData bufferData = new ByteData.view(bufferList.buffer);
    push(bufferData);
    Stream stream;
    if (value is Uint8List) {
      stream = new Stream.fromIterable(value);
    } else if (value is ByteBuffer) {
      Uint8List valueList = new Uint8List.view(value);
      stream = new Stream.fromIterable(valueList);
    } else if (value is List) {
      Uint8List valueList = new Uint8List.fromList(value);
      stream = new Stream.fromIterable(valueList);
    } else if (value is Stream) {
      stream = value;
    } else if (value is String) {
      // create a stream from String
      StreamController streamController = new StreamController();
      streamController.add(encodeToCESU8(value));
      stream = streamController.stream;
      streamController.close();
    } else {
      throw new Exception('Invalid lob value');
    }
    if (stream != null) {
      Map lobEntry = {
        'stream': stream,
        'header': bufferList,
        'locatorId': new List(8)
      };
      _lobs.add(lobEntry);
    }
  }
  
  ByteData getBufferData(type, values) {
    ByteBuffer buffer;
    ByteData bdata;
    
    int length = values.length;

    if (length <= 245) {
      buffer = new Uint8List(2 + length).buffer;
      bdata = new ByteData.view(buffer);

      bdata.setUint8(0, type);
      bdata.setUint8(1, length);

      for (int i = 0; i < length; i++) {
        bdata.setUint8(2 + i, values[i]);
      }
    } else if (length <= 32767) {
      buffer = new Uint8List(4 + length).buffer;
      bdata = new ByteData.view(buffer);

      bdata.setUint8(0, type);
      bdata.setUint8(1, 246);
      bdata.setUint16(2, length, Endianness.LITTLE_ENDIAN);

      for (int i = 0; i < length; i++) {
        bdata.setUint8(4 + i, values[i]);
      }
    } else {
      buffer = new Uint8List(6 + length).buffer;
      bdata = new ByteData.view(buffer);

      bdata.setUint8(0, type);
      bdata.setUint8(1, 247);
      bdata.setUint32(2, length, Endianness.LITTLE_ENDIAN);

      for (int i = 0; i < length; i++) {
        bdata.setUint8(6 + i, values[i]);
      }
    }
    return bdata;
  }

  void writeCharacters(value, encoding) {
    int type = encoding == 'ascii' ? TypeCode.STRING.index : TypeCode.NSTRING.index;
    List<int> encoded = new List();

    if (encoding == 'ascii') {
      encoded = ASCII.encode(value);
    } else if (encoding == 'utf8') {
      encoded = encodeToCESU8(value);
    }

    push(getBufferData(type, encoded));
  }

  void writeInt(int value) {
    ByteBuffer buffer = new Uint8List(5).buffer;
    ByteData bdata = new ByteData.view(buffer);

    bdata.setUint8(0, TypeCode.INT.index);
    bdata.setUint32(1, value, Endianness.LITTLE_ENDIAN);
    push(bdata);
  }

  void writeTinyInt(int value) {
    ByteBuffer buffer = new Uint8List(2).buffer;
    ByteData bdata = new ByteData.view(buffer);

    bdata.setUint8(0, TypeCode.TINYINT.index);
    bdata.setUint8(1, value);
    push(bdata);
  }

  void writeSmallInt(int value) {
    ByteBuffer buffer = new Uint8List(3).buffer;
    ByteData bdata = new ByteData.view(buffer);

    bdata.setUint8(0, TypeCode.SMALLINT.index);
    bdata.setUint16(1, value, Endianness.LITTLE_ENDIAN);
    push(bdata);
  }

  void writeBigInt(int value) {
    ByteBuffer buffer = new Uint8List(9).buffer;
    ByteData bdata = new ByteData.view(buffer);

    bdata.setUint8(0, TypeCode.BIGINT.index);
    bdata.setUint64(1, value, Endianness.LITTLE_ENDIAN);
    push(bdata);
  }

  void writeDouble(double value) {
    ByteBuffer buffer = new Uint8List(9).buffer;
    ByteData bdata = new ByteData.view(buffer);

    bdata.setUint8(0, TypeCode.DOUBLE.index);
    bdata.setFloat64(1, value, Endianness.LITTLE_ENDIAN);
    push(bdata);
  }

  void writeReal(double value) {
    ByteBuffer buffer = new Uint8List(5).buffer;
    ByteData bdata = new ByteData.view(buffer);

    bdata.setUint8(0, TypeCode.REAL.index);
    bdata.setFloat32(1, value, Endianness.LITTLE_ENDIAN);
    push(bdata);
  }

  void writeDecimal(double value) {

    ByteBuffer buffer = new Uint8List(17).buffer;
    ByteData bdata = new ByteData.view(buffer);

    String tmp = value.toStringAsExponential();

    var o = {};
    tmp.splitMapJoin((new RegExp(r"([\+\-]){0,1}(\d){1}(?:\.){0,1}([\d]*)(?:[e])(.*)")), onMatch: (m) {

      var mInt = m[2] == '' ? '0' : m[2];
      var mFrac = m[3];
      int exp = int.parse(m[4]);

      o['s'] = m[1] == '-' ? -1 : 1;
      o['m'] = int.parse(mInt + '' + mFrac);
      o['e'] = exp - mFrac.length;

    });

    // fill with 0s
    for (int i = 0; i < 17; i++) {
      bdata.setUint8(i, 0);
    }

    bdata.setUint8(0, TypeCode.DECIMAL.index);

    if (o['m'].bitLength > 64) {
      print(">64!");
    } else {
      bdata.setUint64(1, o['m'], Endianness.LITTLE_ENDIAN);
    }

    var EXP_BIAS = 6176;
    var e = EXP_BIAS + o['e'];

    var e0 = e << 1;
    e0 &= 0xfe;
    e0 |= bdata.getUint8(14) & 0x01;
    bdata.setUint8(15, e0);

    var e1 = e >> 7;
    if (o['s'] < 0) {
      e1 |= 0x80;
    }
    bdata.setUint8(16, e1);

    push(bdata);
  }

  void writeString(value) {
    writeCharacters(value, 'ascii');
  }

  void writeNString(value) {
    writeCharacters(value, 'utf8');
  }
  
  void writeDate(DateTime time) {
    ByteBuffer buffer = new Uint8List(5).buffer;
    ByteData bdata = new ByteData.view(buffer);

    bdata.setUint8(0, TypeCode.DATE.index);
    bdata.setUint16(1, time.year, Endianness.LITTLE_ENDIAN);
    bdata.setUint8(2, bdata.getUint8(2) | 0x80);
    bdata.setUint8(3, time.month - 1);
    bdata.setUint8(4, time.day);
    push(bdata);
  }

  void writeTime(DateTime time) {
    ByteBuffer buffer = new Uint8List(5).buffer;
    ByteData bdata = new ByteData.view(buffer);

    bdata.setUint8(0, TypeCode.TIME.index);
    bdata.setUint8(1, time.hour | 0x80);
    bdata.setUint8(2, time.minute);
    bdata.setUint16(3, (time.second * 1000 + time.millisecond), Endianness.LITTLE_ENDIAN); // HANA expects milliseconds
    push(bdata);
  }

  void writeTimestamp(DateTime time) {
    ByteBuffer buffer = new Uint8List(9).buffer;
    ByteData bdata = new ByteData.view(buffer);

    bdata.setUint8(0, TypeCode.TIMESTAMP.index);
    bdata.setUint16(1, time.year, Endianness.LITTLE_ENDIAN);
    bdata.setUint8(2, bdata.getUint8(2) | 0x80);
    bdata.setUint8(3, time.month - 1);
    bdata.setUint8(4, time.day);
    bdata.setUint8(5, time.hour | 0x80);
    bdata.setUint8(6, time.minute);
    bdata.setUint16(7, (time.second * 1000 + time.millisecond), Endianness.LITTLE_ENDIAN); // HANA expects milliseconds

    push(bdata);
  }

  writeNClob(value) {
    Uint8List bufferList = new Uint8List(10);
    ByteBuffer buffer = bufferList.buffer;
    ByteData bufferData = new ByteData.view(buffer);
    for (int i = 0; i < 10; i++) {
      bufferData.setUint8(i, 0x00);
    }
    bufferData.setUint8(0, TypeCode.NCLOB.index);
    if (value is String) {
      value = encodeToCESU8(value);
    }
    pushLob(bufferList, value);
  }

  writeBlob(value) {
    Uint8List bufferList = new Uint8List(10);
    ByteBuffer buffer = bufferList.buffer;
    ByteData bufferData = new ByteData.view(buffer);
    for (int i = 0; i < 10; i++) {
      bufferData.setUint8(i, 0x00);
    }
    bufferData.setUint8(0, TypeCode.BLOB.index);
    pushLob(bufferList, value);
  }

  writeClob(value) {
    Uint8List bufferList = new Uint8List(10);
    ByteBuffer buffer = bufferList.buffer;
    ByteData bufferData = new ByteData.view(buffer);
    for (int i = 0; i < 10; i++) {
      bufferData.setUint8(i, 0x00);
    }
    bufferData.setUint8(0, TypeCode.NCLOB.index);
    if (value is String) {
      value = ASCII.encode(value);
    }

    pushLob(bufferList, value);
  }
  
  void writeBinary(ByteBuffer value) {
    push(getBufferData(TypeCode.BINARY.index, new Uint8List.view(value)));
  }
  
  getParameters(int bytesAvailable, Function callBackFunction) {

    Completer c = new Completer();

    c.future.then((val) {
      if (val is Error) {
        callBackFunction(val);
      } else {
        ByteBuffer buffer = new Uint8List(_bytesWritten).buffer;
        ByteData bdata = new ByteData.view(buffer);

        int offset = 0;
        for (int i = 0; i < _buffers.length; i++) {
          for (int j = 0; j < _buffers[i].lengthInBytes; j++) {
            bdata.setUint8(offset, _buffers[i].getUint8(j));
            offset++;
          }
        }

        clear();
        callBackFunction(new Uint8List.view(bdata.buffer));
      }
    });

    var bytesRemaining = bytesAvailable - _bytesWritten;
    finalizeParameters(bytesRemaining, c);
  }

  void update(writeLobReply) {
    var stream, locatorId;
    for (var i = 0; i < _lobs.length; i++) {
      locatorId = writeLobReply[i];
      stream = _lobs[i]['stream'];
      if (locatorId is Uint8List && stream is Stream) {
        _lobs[i]['header'] = null;
        _lobs[i]['locatorId'] = locatorId;
      }
    }
  }

  onerror(err, Completer com) {
    return com.complete(err);
  }

  finalize(Uint8List headerList, Completer com, int lastDataPosition, int bytesRemaining) {
    // update lob options in header
    headerList[lastDataPosition] |= LobOptions.LAST_DATA.value;
    // remove current lob from stack
    _lobs.removeAt(0);
    
    _writeLobRequestCompleter = null;
    _subscription = null;
    
    finalizeParameters(bytesRemaining, com);
  }

  onreadable(Stream stream, Uint8List headerList, int bytesRemaining, Completer com) {

    // remaining chunk after 1st request
    List remainingChunk = new List();
    int type = Writer.FINALIZE_PARAMETERS;
    
    handleChunk(Uint8List chunk, int lengthStartPosition, bool fromStreamListen) {
      if (remainingChunk.length != 0 && fromStreamListen) {
        remainingChunk.addAll(chunk);
        chunk = new Uint8List.fromList(remainingChunk);
        remainingChunk.clear();
      }
      
      if (bytesRemaining < chunk.length) {
        Uint8List lastChunk = new Uint8List(bytesRemaining);
        lastChunk.setRange(0, bytesRemaining, chunk);
        remainingChunk.addAll(chunk.sublist(bytesRemaining));
        chunk = lastChunk;
      }

      // update lob length in header
      var length = readInt32LE(headerList, lengthStartPosition);
      length += chunk.length;
  
      Uint8List numList = new Uint8List(4);
      ByteData bData = new ByteData.view(numList.buffer);
      bData.setUint32(0, length, Endianness.LITTLE_ENDIAN);
      headerList.setRange(lengthStartPosition, lengthStartPosition + 4, numList);

      // push chunk
      push(new ByteData.view(chunk.buffer));
      bytesRemaining -= chunk.length;
    }

    _subscription = stream.listen((chunk) {
      if (chunk is int) {
        chunk = new Uint8List.fromList([chunk]);
      } else if (chunk is List) {
        chunk = new Uint8List.fromList(chunk);
      }
      int lengthStartPosition = (type == Writer.FINALIZE_PARAMETERS) ? 2 : 17;

      if (type == Writer.FINALIZE_WRITE_LOB_REQUEST) {

        if (_lobs.length == 0 || bytesRemaining == 0) {
          _writeLobRequestCompleter = null;
          _subscription.cancel();
          return com.complete(null);
        }
        headerList = getHeaderList();
        bytesRemaining -= headerList.length;
      }

      handleChunk(chunk, lengthStartPosition, true);

      // stop appending if there is no remaining space
      if (bytesRemaining == 0) {
        type = Writer.FINALIZE_WRITE_LOB_REQUEST;
        _subscription.pause(writeLobRequestFuture());
        _writeLobRequestCompleter.future.then((val) {
          bytesRemaining = val['bytesRemaining'];
          com = val['completer'];
        });
        return com.complete(null);
      }
    }, onError: (err) {
      onerror(err, com);
    }, onDone: () {
      while (remainingChunk.length > 0) {
        if (headerList.length == 10) {
          headerList = getHeaderList();
        }
        handleChunk(new Uint8List.fromList(remainingChunk), 17, false);
      }
   
      finalize(headerList, com, ((type == Writer.FINALIZE_PARAMETERS) ? 1 : 8), bytesRemaining);
    });
  }

  Future writeLobRequestFuture() {
    _writeLobRequestCompleter = new Completer();
    return _writeLobRequestCompleter.future;
  }

  finalizeParameters(int bytesRemaining, Completer com) {

    if (_lobs.length == 0 || bytesRemaining == 0) {
      return com.complete(null);
    }
    // set reabable stream
    Stream stream = _lobs[0]['stream'];

    // set lob header
    Uint8List headerList = _lobs[0]['header'];
    ByteBuffer buffer = headerList.buffer;
    ByteData header = new ByteData.view(buffer); // of type ByteData

    // update lob options in header
    header.setUint8(1, LobOptions.DATA_INCLUDED.value);

    // update lob position in header
    var position = _bytesWritten + 1;

    Uint8List numList = new Uint8List(4);
    ByteData bData = new ByteData.view(numList.buffer);
    bData.setUint32(0, position, Endianness.LITTLE_ENDIAN);
    headerList.setRange(6, 10, numList);

    return onreadable(stream, headerList, bytesRemaining, com);
  }

  Uint8List getHeaderList() {

    // set lob header
    Uint8List headerList = new Uint8List(21);
    ByteBuffer header = headerList.buffer;
    ByteData headerData = new ByteData.view(header);

    // set locatorId
    headerList.setRange(0, 8, _lobs[0]['locatorId']);

    // update lob options in header
    headerData.setUint8(8, LobOptions.DATA_INCLUDED.value);

    // offset 0 means append
    for (int i = 9; i < 17; i++) {
      headerData.setUint8(i, 0x00);
    }

    // length
    Uint8List numList = new Uint8List(4);
    ByteData bData = new ByteData.view(numList.buffer);
    bData.setInt32(0, 0, Endianness.LITTLE_ENDIAN);
    headerList.setRange(17, 21, numList);

    // push header
    push(headerData);

    // increase count
    _argumentCount += 1;

    return headerList;
  }

  finalizeWriteLobRequest(int bytesRemaining, Completer com) {
    _writeLobRequestCompleter.complete({
      'bytesRemaining': bytesRemaining,
      'completer': com
    });
    _subscription.resume();
  }

  getWriteLobRequest(int bytesRemaining, Function callbackFunc) {
    Completer com = new Completer();
    com.future.then((err) {
      if (err != null) {
        return callbackFunc(err);
      }

      ByteBuffer buffer = new Uint8List(_bytesWritten).buffer;
      ByteData bdata = new ByteData.view(buffer);
      int offset = 0;
      for (int i = 0; i < _buffers.length; i++) {
        for (int j = 0; j < _buffers[i].lengthInBytes; j++) {
          bdata.setUint8(offset, _buffers[i].getUint8(j));
          offset++;
        }
      }

      Map part = {
        'argumentCount': _argumentCount,
        'buffer': new Uint8List.view(bdata.buffer)
      };
      clear();
      callbackFunc(part);
    });

    clear();
    finalizeWriteLobRequest(bytesRemaining, com);
  }

  bool get finished {
    return _lobs.length == 0 && _buffers.length == 0;
  }
}
