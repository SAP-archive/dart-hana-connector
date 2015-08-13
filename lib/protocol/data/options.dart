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

library protocol.data.options;

import "dart:typed_data";
import "package:Connector/protocol/reply/replypart.dart";
import "package:Connector/protocol/common/type_code.dart";
import "package:Connector/util/cesu8_coding.dart";
import "package:Connector/util/util.dart";
import 'package:Connector/protocol/request/part.dart';
import 'package:Connector/protocol/common/part_kind.dart';

class Options {

  List read(ReplyPart part, [properties = null]) {
    List options = [];
    readInternal(options, part.argumentCount, part.buffer, offset: 0);
    if (properties != null && properties is Map) {
      toObject(options, properties);
    }
    return options;
  }

  Map toObject(List options, Map properties) {
    Map obj = new Map();
    options.forEach((option) {
      var name = option['name'];
      if (properties.containsKey(name)) {
        String propertyName = toCamelCase(properties[name]);
        obj[propertyName] = option['value'];
      }
    });
    return obj;
  }

  int readInternal(List options, int count, Uint8List buffer, {int offset: 0}) {
    for (int i = 0; i < count; i++) {
      TypeCode tcode = TypeCode.values[buffer[offset + 1]];
      Map option = new Map();
      option['name'] = buffer[offset];
      option['type'] = tcode;
      offset += 2;

      if (option['type'] == TypeCode.BOOLEAN) {
        option['value'] = (buffer[offset] == 1);
        offset += 1;
      } else if (option['type'] == TypeCode.INT) {
        option['value'] = readInt32LE(buffer, offset);
        offset += 4;
      } else if (option['type'] == TypeCode.BIGINT) {
        option['value'] = readInt64LE(buffer, offset);
        offset += 8;
      } else if (option['type'] == TypeCode.DOUBLE) {
        option['value'] = readDoubleLE(buffer, offset);
        offset += 8;
      } else if (option['type'] == TypeCode.STRING) {
        int length = readInt16LE(buffer, offset);
        offset += 2;
        option['value'] = decodeCESU8(buffer.sublist(offset, offset + length));
        offset += length;
      } else if (option['type'] == TypeCode.BSTRING) {
        int length = readInt16LE(buffer, offset);
        offset += 2;
        option['value'] = new Uint8List.fromList(buffer.sublist(offset, offset + length));
        offset += length;
      }
      options.add(option);
    }
    return offset;
  }

  write(Part part, List options, {int remainingSize: 0}) {
    var offset = 0;
    if (part == null) {
      part = new Part(PartKindEnum.inst.NIL, 0);
    }
    if (options == null) {
      options = [];
    }

    var byteLength = getByteLength(options);
    var buffer = [];

    for (var i = 0; i < options.length; i++) {
      Map option = options[i];
      buffer.add(option['name']);
      buffer.add(option['type'].index);

      if (option['type'] == TypeCode.BOOLEAN) {
        buffer.add((option['value'] == true) ? 1 : 0);
      } else if (option['type'] == TypeCode.INT) {
        writeInt32LE(buffer, option['value']);
      } else if (option['type'] == TypeCode.BIGINT) {
        writeInt64LE(buffer, option['value']);
      } else if (option['type'] == TypeCode.DOUBLE) {
        writeDoubleLE(buffer, option['value']);
      } else if (option['type'] == TypeCode.STRING) {
        List<int> encoded = encodeToCESU8(option['value']);
        writeInt16LE(buffer, encoded.length);
        buffer.addAll(encoded);
      } else if (option['type'] == TypeCode.BSTRING) {
        List<int> encoded = option['value'];
        writeInt16LE(buffer, encoded.length);
        buffer.addAll(encoded);
      }
    }
    part.argumentCount = options.length;
    part.buffer = new Uint8List.fromList(buffer);
    return part;
  }

  int getByteLength(List options) {
    int byteLength = 0;
    for (var i = 0; i < options.length; i++) {
      var option = options[i];

      if (option['type'] == TypeCode.BOOLEAN) {
        byteLength += 3;
      } else if (option['type'] == TypeCode.INT) {
        byteLength += 6;
      } else if (option['type'] == TypeCode.BIGINT) {
        byteLength += 10;
      } else if (option['type'] == TypeCode.DOUBLE) {
        byteLength += 10;
      } else if (option['type'] == TypeCode.STRING) {
        List<int> encoded = encodeToCESU8(option['value']);
        byteLength += 4 + encoded.length;
      } else if (option['type'] == TypeCode.BSTRING) {
        List<int> encoded = option['value'];
        byteLength += 4 + encoded.length;
      }
    }
    return byteLength;
  }

  int getArgumentCount(List options) {
    return options.length;
  }
}
