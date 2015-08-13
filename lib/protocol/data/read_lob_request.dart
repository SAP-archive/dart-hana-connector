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

library protocol.data.read_lob_request;

import 'dart:typed_data';
import 'package:Connector/protocol/request/part.dart';
import 'package:Connector/util/util.dart';
import 'package:Connector/protocol/reply/replypart.dart';

class ReadLobRequest {

  static const READ_LOB_REQUEST_LENGTH = 24;

  Part write(Part part, Map req, {int remainingSize: 0}) {
    int offset = 0;
    part = (part == null) ? {} : part;
    req = (req == null) ? this : req;

    List buffer = new List();
    if (req['locatorId'] is Uint8List) {
      buffer.insertAll(offset, req['locatorId'].sublist(0, 8));
    } else {
      writeInt64LE(buffer, req['locatorId']);
    }
    offset += 8;
    writeInt64LE(buffer, req['offset']);
    offset += 8;
    writeInt32LE(buffer, req['length']);
    offset += 4;
    for (int i = offset; i < READ_LOB_REQUEST_LENGTH; i++) {
      buffer.insert(i, 0);
    }
    part.argumentCount = getArgumentCount(req);
    part.buffer = new Uint8List.fromList(buffer);
    return part;
  }

  Map read(ReplyPart part) {
    Uint8List buffer = part.buffer;
    List locatorId = new List();
    locatorId.addAll(buffer.sublist(0, 8));
    return {
      'locatorId': new Uint8List.fromList(locatorId),
      'offset': readInt64LE(buffer, 8),
      'length': readInt32LE(buffer, 16)
    };
  }

  int getByteLength(var req) {
    return 24;
  }

  int getArgumentCount(var req) {
    return 1;
  }
}
