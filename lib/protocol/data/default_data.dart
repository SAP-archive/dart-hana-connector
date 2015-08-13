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

library protocol.data.default_data;

import "package:Connector/protocol/reply/replypart.dart";
import 'package:Connector/protocol/request/part.dart';

class DefaultData {
  ReplyPart read(ReplyPart part) {
    return part;
  }

  write(Part part, Map sourcePart, {int remainingSize: 0}) {
    return part.extend(sourcePart);
  }

  int getByteLength(ReplyPart part) {
    return part.getByteLength();
  }

  int getArgumentCount(Map part) {
    return part['argumentCount'];
  }
}
