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

library protocol.data.int32;

import "dart:typed_data";
import "package:Connector/protocol/common/part_kind.dart";
import "package:Connector/util/util.dart";
import 'package:Connector/protocol/reply/replypart.dart';
import 'package:Connector/protocol/request/part.dart';

class Int32 {
  read(ReplyPart part) {
    if (part.argumentCount == 1) {
      return readInt32LE(part.buffer, 0);
    }

    int offset = 0;
    Uint8List buffer = part.buffer;
    List<int> args = [];

    for (var i = 0; i < part.argumentCount; i++) {
      int x = readInt32LE(buffer, offset);
      args.add(x);
      offset += 4;
    }
    return args;
  }

  Part write(Part part, int value, {int remainingSize: 0}) {
    if (part == null) {
      part = new Part(PartKindEnum.inst.NIL, 0);
    }
    part.argumentCount = getArgumentCount(value);
    List<int> bList = new List<int>();
    writeInt32LE(bList, value);
    part.buffer = new Uint8List.fromList(bList);
    return part;
  }

  int getByteLength(int value) {
    return 4;
  }

  int getArgumentCount(int value) {
    return 1;
  }
}
