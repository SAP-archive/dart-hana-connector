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

library protocol.reply.segment;

import "dart:typed_data";
import "package:Connector/protocol/common/constants.dart";
import "package:Connector/protocol/common/function_code.dart";
import "package:Connector/protocol/common/segment_kind.dart";
import "package:Connector/protocol/reply/reply.dart";
import "package:Connector/protocol/reply/replypart.dart";
import "package:Connector/util/util.dart";

class Segment {
  int _kind;
  int _functionCode;
  List<ReplyPart> _parts = new List<ReplyPart>();
  
  Segment([kind, functionCode]) {
    _kind = (kind == null) ? SegmentKind.INVALID.index : kind;
    _functionCode = (functionCode == null) ? FunctionCode.NIL.index : functionCode;
  }
  
  int get kind {
    return _kind;
  }
  
  void push(ReplyPart part) {
    _parts.add(part);
  }

  String inspect() {
    List lines = [];
    String kindName = SegmentKind.values[_kind].toString();
    String fcodeName = FunctionCode.values[_functionCode].toString();
    
    lines.add('{\n');
    lines.add('  kind: SegmentKind.' + kindName + ',\n');
    lines.add('  functionCode: FunctionCode.' + fcodeName + ',\n');
    lines.add('  parts: [\n');
    
    List pList = new List();
    
    for (var i = 0; i < _parts.length; i++) {
      ReplyPart p = _parts[i];
      pList.add(p.inspect({"indentOffset": 4}));
    }
    
    lines.add(pList.join(',\n') + '\n');
    lines.add('  ]\n');
    lines.add('}\n');
    return lines.join('');
  }

  static Segment createSegment(Uint8List buffer, int offset) {
    var segment = new Segment();
    segment.readSegment(buffer, offset: offset);
    return segment;
  }

  int readSegment(Uint8List buffer, {int offset : 0}) {
    int numberOfParts = readInt16LE(buffer, offset+8);
    _kind = buffer[offset + 12].toSigned(8);
    _functionCode = readInt16LE(buffer, offset + 14);
    
    offset += Constants.SEGMENT_HEADER_LENGTH;
    
    for (int i = 0; i < numberOfParts; i++) {
      var part = new ReplyPart();
      offset = part.readPart(buffer, offset);
      push(part);
    }
    return offset;
  }
  
  Uint8List toBuffer({int size : 0}) {
    if (size == 0){ 
      size = Constants.MAX_PACKET_SIZE - Constants.PACKET_HEADER_LENGTH;
    }
    
    int remainingSize = size - Constants.SEGMENT_HEADER_LENGTH;
    int length = Constants.SEGMENT_HEADER_LENGTH;
    
    List<int> pList = new List<int>();
    for (int i = 0; i < _parts.length; i++) {
      ReplyPart p = _parts[i];
      var buffer = p.toBuffer(remainingSize);
      remainingSize -= buffer.length;
      length += buffer.length;
      pList.add(buffer);
    }

    List<int> header = new List<int>();
    
    // Length of the segment, including the header
    writeInt32LE(header, length);
    
    // Offset of the segment within the message buffer
    writeInt32LE(header, 0);
    
    // Number of contained parts
    writeInt16LE(header, _parts.length);
    
    // Number of segment within packet
    writeInt16LE(header, 1);
    
    // Segment kind
    header.add(_kind);

    // Filler
    header.add(0);
    
    // Function code
    writeInt16LE(header, _functionCode);
    
    // Filler
    for (int i = 0; i < Constants.SEGMENT_HEADER_LENGTH; i++) {
      header.add(0);
    }
    
    header.addAll(pList);
    return new Uint8List.fromList(header);
  }
  
  getPart(kind) {
    List<ReplyPart> parts = new List<ReplyPart>();
    
    for (int i = 0; i < _parts.length; i++) {
      if (_parts[i] == kind) {
        parts.add(_parts[i]);
      }
    }
    
    return (parts.isEmpty) ? null : (parts.length == 1) ? parts[0] : parts;
  }
  

  Reply getReply() {
    var reply = new Reply(_kind, _functionCode);
    for (var i = 0; i < _parts.length; i++) {
      reply.add(_parts[i]);
    }
    return reply;
  }
}
