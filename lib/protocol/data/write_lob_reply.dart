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

library protocol.data.write_lob_reply;

import 'dart:typed_data';
import 'package:Connector/protocol/reply/replypart.dart';

class WriteLobReply {

  WriteLobReply() {
  }

  List read(ReplyPart part) {
    int offset = 0;
    Uint8List buffer = part.buffer;
    
    var args = [];
    for (var i = 0; i < part.argumentCount; i++) {
      args.add(buffer.sublist(offset, offset + 8));
      offset += 8;
    }
    return args;
  }

  int getArgumentCount(args) {
    return args.length;
  }
}