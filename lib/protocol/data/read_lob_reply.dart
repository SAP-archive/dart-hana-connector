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

library protocol.data.read_lob_reply;

import 'dart:typed_data';
import 'package:Connector/protocol/reply/replypart.dart';
import 'package:Connector/util/util.dart';
import 'package:Connector/protocol/common/lob_options.dart';

class ReadLobReply {

  Uint8List locatorId;
  int options;
  Uint8List chunk;

  ReadLobReply({Uint8List locatorId, int options, Uint8List chunk}) {
    this.locatorId = locatorId;
    this.options = options;
    this.chunk = chunk;
  }

  ReadLobReply read(ReplyPart part) {
    int offset = 0;
    Uint8List buffer = part.buffer;

    Uint8List locatorId = buffer.sublist(offset, offset + 8);
    offset += 8;
    int options = buffer[offset];
    offset += 1;
    int length = readInt32LE(buffer, offset);
    offset = 16;
    Uint8List chunk = buffer.sublist(offset, offset + length);
    offset += length;
    return new ReadLobReply(locatorId: locatorId, options: options, chunk: chunk);
  }

  int getByteLength(List chunk) {
    return 16 + chunk.length;
  }

  int getArgumentCount(var value) {
    return 1;
  }

  bool isNull() {
    return (options & LobOptions.NULL_INDICATOR.value != 0);
  }

  bool isDataIncluded() {
    return (options & LobOptions.DATA_INCLUDED.value != 0);
  }

  bool isLast() {
    return (options & LobOptions.LAST_DATA.value != 0);
  }
}
