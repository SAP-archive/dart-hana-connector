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

library protocol.data.multilineoptions;

import "dart:typed_data";
import "package:Connector/protocol/reply/replypart.dart";
import "package:Connector/protocol/data/options.dart";
import "package:Connector/util/util.dart";
import 'package:Connector/protocol/request/part.dart';
import 'package:Connector/protocol/common/part_kind.dart';

class MultiLineOptions {
  Options opt = new Options();

  List<List<int>> read(ReplyPart part) {
    int offset = 0;
    Uint8List buffer = part.buffer;
    List<List<int>> lines = [];

    for (var i = 0; i < part.argumentCount; i++) {
      int numberOfOptions = readInt16LE(buffer, offset);
      offset += 2;
      List<int> options = [];
      offset = opt.readInternal(options, numberOfOptions, buffer, offset: offset);
      lines.add(options);
    }
    return lines;
  }

  Part write(Part part, List<List> lines) {
    var offset = 0;
    if (part == null) {
      part = new Part(PartKindEnum.inst.NIL, 0);
    }

    List buffer = [];
    for (var i = 0; i < lines.length; i++) {
      Part p = opt.write(new Part(PartKindEnum.inst.NIL, 0), lines[i]);
      writeInt16LE(buffer, p.argumentCount);
      offset += 2;
      buffer.addAll(p.buffer);
      offset += p.buffer.length;
    }

    part.argumentCount = getArgumentCount(lines);
    part.buffer = new Uint8List.fromList(buffer);
    return part;
  }

  int getByteLength(List<List> lines) {
    int byteLength = 0;
    for (int i = 0; i < lines.length; i++) {
      byteLength += 2 + opt.getByteLength(lines[i]);
    }
    return byteLength;
  }

  int getArgumentCount(List<List> lines) {
    return lines.length;
  }
}
