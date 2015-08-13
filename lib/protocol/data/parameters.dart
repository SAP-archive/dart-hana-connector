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

library protocol.data.parameters;

import 'dart:typed_data';
import 'package:Connector/protocol/request/part.dart';

class Parameters {

  Part write(Part part, value, {int remainingSize: 0}) {
    if (value == null) {
      value = this;
    }
    if (part == null) {
      part = new Part(null, null);
    }
    if (value is Uint8List) {
      part.argumentCount = 1;
      part.buffer = value;
      return part;
    }
    if (value is List) {
      part.argumentCount = value.length;
      List buffer = new List();
      for (int i = 0; i < value.length; i++) {
        buffer.addAll(value[i]);
      }
      part.buffer = new Uint8List.fromList(buffer);
      return part;
    }
    return part;
  }

  int getByteLength(var value) {
    if (value is List) {
      int byteLength = 0;
      for (int i = 0; i < value.length; i++) {
        byteLength += value[i].length;
      }
      return byteLength;
    } else if (value is Uint8List) {
      return value.lengthInBytes;
    }
    return 0;
  }

  int getArgumentCount(var value) {
    if (value is List) {
      return value.length;
    }
    if (value is Uint8List) {
      return 1;
    }
    return 0;
  }
}
