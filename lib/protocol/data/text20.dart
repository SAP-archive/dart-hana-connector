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

library protocol.data.text20;

import "dart:typed_data";
import "package:Connector/protocol/request/part.dart";
import 'package:Connector/util/cesu8_coding.dart';
import 'package:Connector/util/util.dart';

class Text20 {
  read(Part part) {
    return decodeCESU8(part.buffer.sublist(1));
  }

  Part write(Part part, var value, {int remainingSize: 0}) {
    if (value == null) {
      value = this;
    }
    if (part == null) {
      part = new Part(null, null);
    }

    part.argumentCount = getArgumentCount(value);
    part.buffer = createBuffer(' ' + value);
    return part;
  }

  int getByteLength(Uint8List value) {
    return value.lengthInBytes + 1;
  }

  int getArgumentCount(var value) {
    return 1;
  }
}
