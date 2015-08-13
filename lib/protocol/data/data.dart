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

library protocol.data.data;

import 'dart:mirrors';
import "package:Connector/protocol/common/part_kind.dart";
import "package:Connector/protocol/data/fields.dart";
import "package:Connector/protocol/data/multilineoptions.dart";
import "package:Connector/protocol/data/options.dart";
import "package:Connector/protocol/data/text20.dart";
import "package:Connector/protocol/data/text.dart";
import "package:Connector/protocol/data/default_data.dart";
import "package:Connector/protocol/data/binary.dart";
import "package:Connector/protocol/data/result_set_metadata.dart";
import 'package:Connector/protocol/data/Int32.dart';
import 'package:Connector/protocol/data/transaction_flags.dart';
import 'package:Connector/protocol/data/parameter_metadata.dart';
import 'package:Connector/protocol/data/parameters.dart';
import 'package:Connector/protocol/data/sqlerror.dart';
import 'package:Connector/protocol/data/read_lob_request.dart';
import 'package:Connector/protocol/data/read_lob_reply.dart';
import 'package:Connector/protocol/data/write_lob_reply.dart';

class Data {

  static Map dataMap = {
    PartKindEnum.inst.AUTHENTICATION: Fields,
    PartKindEnum.inst.COMMAND: Text,
    PartKindEnum.inst.CLIENT_ID: Text20,
    PartKindEnum.inst.CONNECT_OPTIONS: Options,
    PartKindEnum.inst.COMMIT_OPTIONS: Options,
    PartKindEnum.inst.ERROR: SQLError,
    PartKindEnum.inst.FETCH_OPTIONS: Options,
    PartKindEnum.inst.FETCH_SIZE: Int32,
    PartKindEnum.inst.TRANSACTION_ID: Binary,
    PartKindEnum.inst.TOPOLOGY_INFORMATION: MultiLineOptions,
    PartKindEnum.inst.PARAMETERS: Parameters,
    PartKindEnum.inst.PARAMETER_METADATA: ParameterMetadata,
    PartKindEnum.inst.RESULT_SET_ID: Binary,
    PartKindEnum.inst.RESULT_SET: DefaultData,
    PartKindEnum.inst.OUTPUT_PARAMETERS: DefaultData,
    PartKindEnum.inst.RESULT_SET_METADATA: ResultSetMetadata,
    PartKindEnum.inst.ROWS_AFFECTED: Int32,
    PartKindEnum.inst.READ_LOB_REQUEST: ReadLobRequest,
    PartKindEnum.inst.READ_LOB_REPLY: ReadLobReply,
    PartKindEnum.inst.WRITE_LOB_REQUEST: DefaultData,
    PartKindEnum.inst.WRITE_LOB_REPLY : WriteLobReply,
    PartKindEnum.inst.SESSION_CONTEXT: Options,
    PartKindEnum.inst.STATEMENT_CONTEXT: Options,
    PartKindEnum.inst.STATEMENT_ID: Binary,
    PartKindEnum.inst.PARTITION_INFORMATION: DefaultData,
    PartKindEnum.inst.TRANSACTION_FLAGS: TransactionFlags,
    PartKindEnum.inst.TABLE_NAME: Text
  };

  static getDataType(PartKind pKind) {
    if (dataMap.containsKey(pKind)) {
      return reflectClass(dataMap[pKind]).newInstance(new Symbol(''), []).reflectee;
    } else {
      print("No matching data type for Partkind - " + pKind.value.toString() + ". Using default data type.");
      return new DefaultData();
    }
  }
}
