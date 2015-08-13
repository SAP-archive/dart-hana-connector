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

library protocol.lob_descriptor;

import 'dart:typed_data';
import 'package:Connector/protocol/common/lob_options.dart';
import 'package:Connector/protocol/common/lob_source_type.dart';
import 'package:Connector/util/cesu8_coding.dart';

class LobDescriptor {

  Uint8List _locatorId;
  int _options;
  Uint8List _chunk;
  int _size;
  int _lobType;

  LobDescriptor(int type, Uint8List locatorId, int options, Uint8List chunk) {
    this._locatorId = locatorId;
    this._options = options;
    if (chunk is Uint8List) {
      this._chunk = chunk;
      if (type == LobSourceType.CLOB.index || type == LobSourceType.NCLOB.index) {
        this._size = decodeCESU8(chunk).length;
      } else {
        this._size = chunk.length;
      }
    } else {
      this._chunk = null;
      this._size = 0;
    }
    _lobType = type;
  }
  
  int get size {
    return _size;
  }
  
  int get lobType {
    return _lobType;
  }
  
  Uint8List get chunk {
    return _chunk;
  }

  Uint8List get locatorId {
    return _locatorId;
  }
  
  bool isLast() {
    return !!(_options & LobOptions.LAST_DATA.value != 0);
  }
}
