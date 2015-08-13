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

library protocol.data.binary;

import "dart:typed_data";
import 'package:Connector/protocol/reply/replypart.dart';
import 'package:Connector/protocol/request/part.dart';

class Binary {
  Uint8List read(ReplyPart part) {
    return part.buffer;
  }

  Part write(Part part, Uint8List value, {int remainingSize: 0}) {
    part.argumentCount = getArgumentCount(value);
    part.buffer = value;
    return part;
  }

  int getByteLength(Uint8List value) {
    return value.length;
  }

  int getArgumentCount(Uint8List value) {
    return 1;
  }
}
