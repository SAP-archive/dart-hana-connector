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

library protocol.part.connect_options;

import "package:Connector/protocol/part/abstract_options.dart";
import "package:Connector/protocol/common/client_distribution_mode.dart";
import "package:Connector/protocol/common/connect_option.dart";
import "package:Connector/protocol/common/connect_option_type.dart";
import "package:Connector/protocol/common/distribution_protocol_version.dart";
import "package:Connector/protocol/common/data_format_version.dart";

class ConnectOptions extends AbstractOptions {
  
  // This field contains the connection ID.
  // It is filled by the server when the connection is established.
  // This number can be used in DISCONNECT / KILL commands for command
  // or session cancellation.
  int connectionId;
  
  // This field is set if array commands continue to process
  // remaining input when detecting an error in an input row.
  // Always set for current client and server.
  bool completeArrayExecution;
  
  // The session locale can be set by the client.
  // The locale is used in language-dependent handling
  // within the SAP HANA database calculation engine.
  String clientLocale;
  
  // This field is set by the server to process array commands.
  bool supportsLargeBulkOperations;
  
  // This field is set by the server to indicate
  // support of a large number of parameters.
  bool largeNumberOfParametersSupport;
  
  // This option is set by the server and filled with the SAPSYSTEMNAME
  // of the connected instance for tracing and supportability purposes.
  String systemId;
  
  // This field is set by the client to indicate that the client is able
  // to handle the special function code for SELECT ... FOR UPDATE commands.
  bool selectForUpdateSupported;
  
  
  // This field is set by the client to indicate the mode for handling
  // statement routing and client distribution.
  // The server sets this field to the appropriate support level
  // depending on the client value and its own configuration.
  //
  // The following values are supported:
  // *  `0` OFF, no routing or distributed transaction handling is done.
  // *  `1` CONNECTION, client can connect to any (master/slave) server
  //        in the topology, and connections are enabled, such that the
  //        connection load on the nodes is balanced.
  // *  `2` STATEMENT, server returns information about which node is preferred
  //        for executing the statement, clients execute on that node,
  //        if possible.
  // *  `3` STATEMENT_CONNECTION, both STATEMENT and CONNECTION level
  int clientDistributionMode;
  
  // The server sets this field to the maximum version it is able to support.
  // The possible values correspond to the `dataFormatVersion` property.
  int engineDataFormatVersion;
  
  // This field is set by the client and indicates
  // the support level in the protocol for distribution features.
  // The server may choose to disable distribution if the support level
  // is not sufficient for the handling.
  // *  `0` BASE Baseline version
  // *  `1` Client handles statement sequence number information
  //        (statement context part handling).
  // `clientDistributionMode` is OFF if a value less than one
  // is returned by the server.
  int distributionProtocolVersion;
  
  // This field is sent by the client and returned by the server
  // if configuration allows splitting batch (array)
  // commands for parallel execution.
  bool splitBatchCommands;
  
  // This field is sent by the server to indicate the client should gather the
  // state of the current transaction only from the `TRANSACTIONFLAGS` command,
  // not from the nature of the command (DDL, UPDATE, and so on).
  bool useTransactionFlagsOnly;
  
  // This field is sent by the server to indicate it ignores unknown parts
  // of the communication protocol instead of raising a fatal error.
  int ignoreUnknownParts;
  
  // The client indicates this set of understood type codes and field formats.
  // The server then defines the value according to its own capabilities,
  // and sends it back. The following values are supported:
  // *  `1` Baseline data type support (SAP HANA SPS 02)
  // *  `4` Baseline data type support (SAP HANA SPS 06)
  //        Support for ALPHANUM, TEXT, SHORTTEXT, LONGDATE, SECONDDATE,
  //        DAYDATE, and SECONDTIME.
  int dataFormatVersion;
  int dataFormatVersion2;
  
  bool rowAndColumnOptimizedFormat;

  ConnectOptions() : super() {
    KEYS = [
      ConnectOption.COMPLETE_ARRAY_EXECUTION,
      ConnectOption.CLIENT_LOCALE,
      ConnectOption.CLIENT_DISTRIBUTION_MODE,
      ConnectOption.DISTRIBUTION_PROTOCOL_VERSION,
      ConnectOption.SELECT_FOR_UPDATE_SUPPORTED,
      ConnectOption.SPLIT_BATCH_COMMANDS,
      ConnectOption.DATA_FORMAT_VERSION,
      ConnectOption.DATA_FORMAT_VERSION2
    ];
    TYPES = ConnectOptionType.map;
    PROPERTYNAMES = ConnectOption.LOOKUP;
    
    clientLocale = 'en_US';
    completeArrayExecution = true;
    selectForUpdateSupported = false;
    clientDistributionMode = ClientDistributionMode.OFF.index;
    distributionProtocolVersion = DistributionProtocolVersion.BASE.index;
    splitBatchCommands = true;
    dataFormatVersion = DataFormatVersion.COMPLETE_DATATYPE_SUPPORT.value;
    dataFormatVersion2 = DataFormatVersion.COMPLETE_DATATYPE_SUPPORT.value;
  }
}