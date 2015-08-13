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

library protocol.request.segment;

import 'dart:typed_data';
import "package:Connector/protocol/common/constants.dart";
import "package:Connector/protocol/common/message_type.dart";
import 'package:Connector/protocol/common/part_kind.dart';
import 'package:Connector/protocol/common/segment_kind.dart';
import 'package:Connector/protocol/data/data.dart';
import "package:Connector/protocol/request/part.dart";
import 'package:Connector/util/util.dart';


class Segment {
  static final int MAX_SEGMENT_SIZE = 
      Constants.MAX_PACKET_SIZE - Constants.PACKET_HEADER_LENGTH;
  
  MessageType _messageType;
  int _commitImmediately = 0;
  int _commandOptions;
  List<Part> _parts = [];

  Segment(this._messageType, this._commitImmediately, this._commandOptions);
  
  MessageType get messageType {
    return _messageType;
  }
  
  Part addPart(Part part) {
    _parts.add(part);
    return part;
  }

  Part push(PartKind kind, args) {
    Part p = new Part(kind, 0);
    p.args = args;
    return addPart(p);
  }
  
  void add(kind, args) {
    if (args != null) {
      if (className(kind) == 'PartKind') {
        Part p = new Part(kind, 0);
        p.args = args;
        _parts.add(p);
      } else if (kind is Map) {
        Part p = new Part(kind['kind'], 0);
        p.module = kind['module'];
        p.args = args;
        _parts.add(p);
      }
    }
  }
  
  Part unshift(kind, args) {
    Part p = new Part(kind, 0);
    p.args = args;
    _parts.insert(0, p);
    return p;
  }

  Uint8List toBuffer(int size) {
    if (size == null) {
      size = Segment.MAX_SEGMENT_SIZE;
    }
    
    int remainingSize = size - Constants.SEGMENT_HEADER_LENGTH;
    int length = Constants.SEGMENT_HEADER_LENGTH;
    
    List<Uint8List> buffers = new List<Uint8List>();
    
    for (var i = 0; i < _parts.length; i++) {
      Uint8List buffer = partToBuffer(_parts[i], remainingSize);
      remainingSize -= buffer.length;
      length += buffer.length;
      buffers.add(buffer);
    }
    
    var header = new List<int>();

    // Length of the segment, including the header
    writeInt32LE(header, length);    
    
    // Offset of the segment within the message buffer
    writeInt32LE(header, 0);

    // Number of contained parts
    writeInt16LE(header, _parts.length);
    
    // Number of segment within packet
    writeInt16LE(header, 1);
    
    // Segment kind
    header.add(SegmentKind.REQUEST.index);
    
    // Message type
    header.add(_messageType.value);

    // Whether the command shall be committed
    header.add(_commitImmediately);

    // Command options
    header.add(_commandOptions);

    // Filler
    for (int i = 16; i < Constants.SEGMENT_HEADER_LENGTH; i++) {
      header.add(0);
    }
    buffers.insert(0, new Uint8List.fromList(header));
    
    List total = new List();
    for (int i = 0; i < buffers.length; i++) {
      total.addAll(buffers[i]);
    }
    return new Uint8List.fromList(total);
  }

  partToBuffer(Part pd, int remainingSize) {
    var m = pd.module;
    
    if (m == null) {
      m = Data.getDataType(pd.kind);
    }
    
    var part = new Part(pd.kind, 0);
    part.argumentCount = m.getArgumentCount(pd.args);
    m.write(part, pd.args, remainingSize: remainingSize);
    return part.toBuffer(remainingSize);
  }
}
