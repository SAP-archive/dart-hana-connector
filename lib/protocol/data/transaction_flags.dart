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

library protocol.data.transaction_flags;

import 'package:Connector/protocol/data/options.dart';
import 'package:Connector/protocol/common/transaction_flag.dart';
import 'package:Connector/protocol/reply/replypart.dart';

class TransactionFlags {
  static Options opt = new Options();
  List read(ReplyPart part) {
    Map<int, String> lookup = new Map.fromIterable(TransactionFlag.values,
        key: (item) => item.index,
        value: (item) => item.toString());
    return opt.read(part, lookup);
  }

  int getByteLength(List options) {
    return opt.getByteLength(options);
  }

  int getArgumentCount(List options) {
    return opt.getArgumentCount(options);
  }
}
