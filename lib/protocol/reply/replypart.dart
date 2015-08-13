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

library protocol.reply.replypart;

import "package:Connector/protocol/common/part_kind.dart";
import "package:Connector/util/util.dart";
import "package:Connector/protocol/common/constants.dart";
import 'dart:typed_data';

class ReplyPart {
  static final PART_HEADER_LENGTH = Constants.PART_HEADER_LENGTH;
  static const BIG_ARGUMENT_COUNT_INDICATOR = -1;
  PartKind kind;
  int attributes;
  int argumentCount;
  Uint8List buffer;
  String encoding;

  ReplyPart({kind, attributes, argumentCount, buffer, encoding}) {
    this.kind = (kind != null) ? kind : PartKindEnum.inst.NIL;
    this.attributes = attributes != null ? attributes : 0;
    this.argumentCount = argumentCount != null ? argumentCount : 0;
    if (buffer is String) {
      this.buffer = createBuffer(buffer);
    } else {
      this.buffer = buffer;
    }
  }
  
  extend(ReplyPart other) {
    if (other.kind != PartKindEnum.inst.NIL) {
      kind = other.kind;
    }
    if (other.attributes != 0) {
      attributes = other.attributes;
    }
    if (other.argumentCount != 0) {
      argumentCount = other.argumentCount;
    }
    if (other.encoding != null) {
      encoding = other.encoding;
    }
    if (other.buffer != null) {
      buffer = other.buffer;
    }
  }
  
  getByteLength() {
    int byteLength = PART_HEADER_LENGTH;
    if (buffer is Uint8List) {
      byteLength += alignLength(buffer.length, 8);
    }
    return byteLength;
  }
  
  ReplyPart createPart(Uint8List buffer, int offset) {
    ReplyPart part = new ReplyPart();
    part.readPart(buffer, offset);
    return part;
  }

  int readPart(Uint8List buffer, int offset) {
    offset = (offset != null) ? offset : 0;
    kind = PartKindEnum.inst.ENUMLOOKUP[buffer[offset]];
    attributes = buffer[offset + 1];
    argumentCount = readInt16LE(buffer, offset + 2);
    if (argumentCount == BIG_ARGUMENT_COUNT_INDICATOR) {
      argumentCount = readInt32LE(buffer, offset + 4);
    }
    int length = readInt32LE(buffer, offset + 8);
    offset += PART_HEADER_LENGTH;
    
    if (length > 0) {
      int maxLimit = (offset + length > buffer.length) ? buffer.length : offset + length;
      List targetBuffer = buffer.sublist(offset, maxLimit);
      this.buffer = new Uint8List.fromList(targetBuffer);
      offset += alignLength(length, 8);
    }
    return offset;
  }
  
  toBuffer(size) {
    int byteLength = alignLength(this.buffer.length, 8);
    List<int> buffer = new List<int>();

    // Part kind, specifies nature of part data
    buffer.add(kind.value);
    // Further attributes of part
    buffer.add(attributes);
    // Argument count, number of elements in part data.
    writeInt16LE(buffer, argumentCount);
    // Argument count, number of elements in part data (only for some part kinds).
    writeInt32LE(buffer, 0);
    // Length of part buffer in bytes
    writeInt32LE(buffer, this.buffer.length);
    // Length in packet remaining without this part.
    writeInt32LE(buffer, size);
    buffer.addAll(this.buffer);
    if (this.buffer.length < byteLength) {
      for (int i = this.buffer.length; i < byteLength; i++) {
        buffer[PART_HEADER_LENGTH + i] = 0;
      }
    }
    return new Uint8List.fromList(buffer);
  }
  
  inspect(Map options) {
    List lines = new List();
    if (options == null) {
      options = new Map();
    }
    
    int indentOffset = (options['indentOffset'] == null) 
        ? 0 : options['indentOffset'];
    String offset = '';
    for (int i = 0; i < indentOffset; i++) {
      offset += ' ';
    }
    
    String kindName = PartKindEnum.inst.LOOKUP[kind.value];
    lines.add(offset + '{\n');
    lines.add(offset + '  kind: PartKind.' + kindName + ',\n');
    lines.add(offset + '  argumentCount: ' + argumentCount.toString() + ',\n');
    lines.add(offset + '  attributes: ' + attributes.toString() + ',\n');
    if (buffer is Uint8List) {
      int length = buffer.length;
      int start = 0, end;
      String chunk = '';
      List hexstr = new List();
      while (start < length) {
        end = start + 32 > length ? length : start + 32;
        List sublist = buffer.sublist(start, end);
        chunk = sublist.join();
        hexstr.add(offset + '    \'' + chunk + '\'');
        start = end;
      }
      lines.add(offset + '  buffer: new Buffer(\n');
      lines.add(hexstr.join(' +\n') + ', \'hex\')\n');
    } else {
      lines.add(offset + '  buffer: null\n');
    }
    lines.add(offset + '}');
    return lines.join('');
  }
}
