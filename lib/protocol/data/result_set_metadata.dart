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

library protocol.data.result_set_metadata;

import "dart:typed_data";
import "dart:mirrors";

import "package:Connector/protocol/reply/replypart.dart";
import "package:Connector/protocol/data/column.dart";
import "package:Connector/util/cesu8_coding.dart";
import "package:Connector/util/util.dart";

class ResultSetMetadata {

  static List<String> COLUMN_NAME_PROPERTIES = ['tableName', 'schemaName', 'columnName', 'columnDisplayName'];

  List<Column> read(ReplyPart part) {
    List columns = new List();
    int columnsListLength = part.argumentCount;
    int offset = 0;
    int textOffset = columnsListLength * 24;
    for (int i = 0; i < columnsListLength; i++) {
      columns.add(readColumn(part.buffer, offset, textOffset));
      offset += 24;
    }
    return columns;
  }

  int getArgumentCount(List columns) {
    return columns.length;
  }

  Column readColumn(Uint8List buffer, int offset, int textOffset) {
    Column column = new Column(buffer[offset].toSigned(8), buffer[offset + 1].toSigned(8), readInt16LE(buffer, offset + 2), readInt16LE(buffer, offset + 4));
    offset += 8;

    for (int i = 0; i < COLUMN_NAME_PROPERTIES.length; i++) {
      String propertyName = COLUMN_NAME_PROPERTIES[i];
      InstanceMirror im = reflect(column);
      int start = readInt32LE(buffer, offset);
      offset += 4;
      if (start < 0) {
        im.setField(new Symbol(propertyName), null);
      } else {
        start += textOffset;
        var length = buffer[start];
        start += 1;
        String buffStr = decodeCESU8(buffer.sublist(start, start + length));
        im.setField(new Symbol(propertyName), buffStr);
      }
    }
    return column;
  }
}
