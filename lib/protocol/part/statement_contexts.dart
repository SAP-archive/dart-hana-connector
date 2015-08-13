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

library protocol.part.statement_context;

import "package:Connector/protocol/part/abstract_options.dart";
import "package:Connector/util/util.dart";
import 'package:Connector/protocol/common/constants.dart';
import 'package:Connector/protocol/common/statement_context.dart';
import 'package:Connector/protocol/common/statement_context_type.dart';
import 'dart:typed_data';

class StatementContexts extends AbstractOptions {  
  // Information on the statement sequence within the transaction
  Uint8List statementSequenceInfo = null;
  // Time for statement execution on the server in nano seconds
  int serverExecutionTime = 0;
  
  StatementContexts() : super() {
    PROPERTYNAMES = StatementContextEnum.inst.LOOKUP;
    TYPES = StatementContextTypeEnum.inst.ENUMLOOKUP;
    KEYS = [
      StatementContextEnum.inst.STATEMENT_SEQUENCE_INFO
    ];
  }
  
  int get size {
    int statementSequenceInfoLength = (statementSequenceInfo != null) ?
      statementSequenceInfo.length : 10;

    return Constants.PART_HEADER_LENGTH + alignLength(4 +
      statementSequenceInfoLength, 8);
  }
}
