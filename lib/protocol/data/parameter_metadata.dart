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

library protocol.data.parameter_metadata;

import 'dart:typed_data';
import 'dart:convert';
import 'package:Connector/protocol/common/parameter_mode.dart';
import 'package:Connector/protocol/common/io_type.dart';
import 'package:Connector/protocol/reply/replypart.dart';
import 'package:Connector/util/util.dart';

class ParameterMetadata {

  List<Parameter> read(ReplyPart part) {
    List<Parameter> params = new List<Parameter>();
    int paramsLen = part.argumentCount;
    _read(params, paramsLen, part.buffer, 0);
    return params;
  }

  int _read(List params, int paramsLen, Uint8List buffer, [int offset = 0]) {
    int textOffset = offset + paramsLen * 16;
    for (var i = 0; i < paramsLen; i++) {
      params.add(new Parameter(buffer, offset, textOffset));
      offset += 16;
    }
    return offset;
  }
}

class Parameter {
  int mode;
  int dataType;
  int ioType;
  int length;
  int fraction;
  String name;

  Parameter(Uint8List buffer, int offset, int textOffset) {
    mode = buffer[offset];
    dataType = buffer[offset + 1];
    ioType = buffer[offset + 2];
    int nameOffset = readInt32LE(buffer, offset + 4);
    if (nameOffset < 0) {
      name = null;
    } else {
      int start = textOffset + nameOffset;
      int length = buffer[start];
      start += 1;
      name = UTF8.decode(buffer.sublist(start, start + length));
    }
    length = readInt16LE(buffer, offset + 8);
    fraction = readInt16LE(buffer, offset + 10);
  }

  bool isReadOnly() {
    return mode & ParameterMode.READONLY.value != 0;
  }

  bool isMandatory() {
    return mode & ParameterMode.MANDATORY.value != 0;
  }

  bool isAutoIncrement() {
    return mode & ParameterMode.AUTO_INCREMENT.value != 0;
  }

  bool isInputParameter() {
    return ioType == IoType.INPUT.value || ioType == IoType.IN_OUT.value;
  }

  bool isOutputParameter() {
    return ioType == IoType.OUTPUT.value || ioType == IoType.IN_OUT.value;
  }
}
