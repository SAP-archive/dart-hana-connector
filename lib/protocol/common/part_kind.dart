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

library protocol.common.part_kind;

import "package:Connector/protocol/common/enum_base.dart";

class PartKindEnum extends EnumBase {
  static final PartKindEnum inst = new PartKindEnum();

  final NIL = new PartKind(0);
  final COMMAND = new PartKind(3);
  final RESULT_SET = new PartKind(5);
  final ERROR = new PartKind(6);
  final STATEMENT_ID = new PartKind(10);
  final TRANSACTION_ID = new PartKind(11);
  final ROWS_AFFECTED = new PartKind(12);
  final RESULT_SET_ID = new PartKind(13);
  final TOPOLOGY_INFORMATION = new PartKind(15);
  final TABLE_LOCATION = new PartKind(16);
  final READ_LOB_REQUEST = new PartKind(17);
  final READ_LOB_REPLY = new PartKind(18);
  final TABLE_NAME = new PartKind(19);
  final COMMAND_INFO = new PartKind(27);
  final WRITE_LOB_REQUEST = new PartKind(28);
  final WRITE_LOB_REPLY = new PartKind(30);
  final PARAMETERS = new PartKind(32);
  final AUTHENTICATION = new PartKind(33);
  final SESSION_CONTEXT = new PartKind(34);
  final CLIENT_ID = new PartKind(35);
  final STATEMENT_CONTEXT = new PartKind(39);
  final PARTITION_INFORMATION = new PartKind(40);
  final OUTPUT_PARAMETERS = new PartKind(41);
  final CONNECT_OPTIONS = new PartKind(42);
  final COMMIT_OPTIONS = new PartKind(43);
  final FETCH_OPTIONS = new PartKind(44);
  final FETCH_SIZE = new PartKind(45);
  final PARAMETER_METADATA = new PartKind(47);
  final RESULT_SET_METADATA = new PartKind(48);
  final FIND_LOB_REQUEST = new PartKind(49);
  final FIND_LOB_REPLY = new PartKind(50);
  final CLIENT_INFO = new PartKind(57);
  final TRANSACTION_FLAGS = new PartKind(64);
}

class PartKind {
  int value;
  PartKind(this.value);
}

