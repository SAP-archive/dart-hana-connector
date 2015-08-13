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

library protocol.data.sqlerror;

import 'dart:typed_data';
import 'package:Connector/util/util.dart';
import 'package:Connector/protocol/common/error_level.dart';
import 'package:Connector/protocol/reply/replypart.dart';

class SQLError extends Error {

  String message;
  var code;
  var sqlState;
  int level;
  int position;
  bool fatal;

  String toString() => "Error ($code) $message ${fatal ? " (fatal)" : ""}";

  SQLError read(ReplyPart part) {
    return _read(part.buffer);
  }

  SQLError _read(Uint8List buffer, [int offset = 0]) {
    code = readInt32LE(buffer, offset);
    offset += 4;
    position = readInt32LE(buffer, offset);
    offset += 4;
    var length = readInt32LE(buffer, offset);
    offset += 4;
    level = buffer[offset].toSigned(8);
    if (level == ErrorLevel.FATAL.index) {
      fatal = true;
    }
    offset += 1;
    sqlState = readString(buffer, offset, offset + 5);
    offset += 5;
    message = readString(buffer, offset, offset + length);
    offset += alignLength(length, 8);

    return new SQLError(message: message, code: code, position: position, level: level, sqlState: sqlState, fatal: fatal);
  }

  int getByteLength(var err) {
    return 18 + err.lengthInByte;
  }

  int getArgumentCount(var err) {
    return 1;
  }

  SQLError({String this.message, var this.code, int this.position, int this.level, var this.sqlState, bool this.fatal: false});
}
