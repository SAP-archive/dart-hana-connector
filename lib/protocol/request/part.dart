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

library protocol.request.part;

import "package:Connector/protocol/common/part_kind.dart";
import "package:Connector/util/util.dart";
import 'dart:typed_data';

class Part {
  static const PART_HEADER_LENGTH = 16;
  
  PartKind kind = PartKindEnum.inst.NIL;
  int attributes = 0;
  int argumentCount = 0;
  var module = null;
  var args = null;
  Uint8List buffer = null;
  
  Part(this.kind, this.attributes, {this.argumentCount : 0});
  
  extend(other) {
    if (other['kind'] != PartKindEnum.inst.NIL && other['kind'] != null) {
      kind = other['kind'];
    }
    if (other['attributes'] != null) {
      attributes = other['attributes'];
    }
    if (other['argumentCount'] != null) {
      argumentCount = other['argumentCount'];
    }
    if (other['module'] != null) {
      module = other['module'];
    }
    if (other['buffer'] != null) {
      buffer = other['buffer'];
    }
  }
  
  int get byteLength {
    return alignLength(buffer.length, 8);
  }
  
  Uint8List toBuffer(size) {
    List<int> buffer = new List<int>();
    int byteLength = alignLength(this.buffer.length, 8);
    
    // Part kind, specifies nature of part data
    // Further attributes of part
    buffer.add(kind.value);
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
        buffer.insert(PART_HEADER_LENGTH + i, 0);
      }
    }
    return new Uint8List.fromList(buffer);
  }
}
