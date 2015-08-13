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

library protocol.data.fields;

import "dart:typed_data";
import "package:Connector/protocol/request/part.dart";
import "package:Connector/protocol/common/part_kind.dart";
import "package:Connector/util/util.dart";

class Fields {

  // This read gets called by both Request/Reply parts
  List<List<int>> read(var part) {
    int offset = 0;
    Uint8List buffer = part.buffer;
    List<List<int>> fields = [];

    var numberOfFields = readUInt16LE(buffer, offset);
    offset += 2;

    for (var i = 0; i < numberOfFields; i++) {
      int fieldLength = buffer[offset];
      offset += 1;
      if (fieldLength > 245) {
        fieldLength = readUInt16LE(buffer, offset);
        offset += 2;
      }

      fields.add(buffer.sublist(offset, offset + fieldLength));
      offset += fieldLength;
    }
    return fields;
  }

  // fields is a list of string and Uint8List;
  Part write(Part part, List fields, {remainingSize: 0}) {
    if (part == null) {
      part = new Part(PartKindEnum.inst.NIL, 0);
    }

    int byteLength = getByteLength(fields);
    List<int> buffer = new List<int>();
    writeInt16LE(buffer, fields.length);

    for (var i = 0; i < fields.length; i++) {
      var field = fields[i];
      String clazzName = className(field);
      Uint8List data;

      if (clazzName == 'Uint8Array') { // Uint8List
        data = field;
      } else if (clazzName == 'GrowableList') { // List<int>
        data = new Uint8List.fromList(field);
      } else {
        data = createBuffer(field);
      }

      var dataLength = data.length;
      if (dataLength <= 245) {
        buffer.add(dataLength);
      } else {
        buffer.add(0xf6);
        writeInt16LE(buffer, dataLength);
      }

      for (int j = 0; j < data.length; j++) {
        buffer.add(data[j]);
      }
    }
    part.argumentCount = getArgumentCount(fields);
    part.buffer = new Uint8List.fromList(buffer);
    return part;
  }

  int getByteLength(List fields) {
    int byteLength = 2;
    for (int i = 0; i < fields.length; i++) {
      int fieldLength = getByteLengthOfField(fields[i]);
      if (fieldLength <= 245) {
        byteLength += fieldLength + 1;
      } else {
        byteLength += fieldLength + 3;
      }
    }
    return byteLength;
  }

  int getArgumentCount(List fields) {
    return 1;
  }

  int getByteLengthOfField(var field) {
    if (field is Uint8List) {
      return field.length;
    } else if (field is List) {
      return getByteLength(field);
    }
    return field.length;
  }
}
