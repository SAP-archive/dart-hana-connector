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

library protocol.common.protocol_common.connect_option_type;

import "package:Connector/protocol/common/connect_option.dart";
import "package:Connector/protocol/common/type_code.dart";

class ConnectOptionType {
  static final Map<ConnectOption, TypeCode> map = {
    ConnectOption.CONNECTION_ID:TypeCode.INT, 
    ConnectOption.COMPLETE_ARRAY_EXECUTION:TypeCode.BOOLEAN, 
    ConnectOption.CLIENT_LOCALE:TypeCode.STRING, 
    ConnectOption.SUPPORTS_LARGE_BULK_OPERATIONS:TypeCode.BOOLEAN, 
    ConnectOption.LARGE_NUMBER_OF_PARAMETERS_SUPPORT:TypeCode.BOOLEAN, 
    ConnectOption.SYSTEM_ID:TypeCode.STRING, 
    ConnectOption.DATA_FORMAT_VERSION:TypeCode.INT, 
    ConnectOption.SELECT_FOR_UPDATE_SUPPORTED:TypeCode.BOOLEAN, 
    ConnectOption.CLIENT_DISTRIBUTION_MODE:TypeCode.INT, 
    ConnectOption.ENGINE_DATA_FORMAT_VERSION:TypeCode.INT, 
    ConnectOption.DISTRIBUTION_PROTOCOL_VERSION:TypeCode.BOOLEAN, 
    ConnectOption.SPLIT_BATCH_COMMANDS:TypeCode.BOOLEAN, 
    ConnectOption.USE_TRANSACTION_FLAGS_ONLY:TypeCode.BOOLEAN, 
    ConnectOption.ROW_AND_COLUMN_OPTIMIZED_FORMAT:TypeCode.BOOLEAN, 
    ConnectOption.IGNORE_UNKNOWN_PARTS:TypeCode.BOOLEAN, 
    ConnectOption.DATA_FORMAT_VERSION2:TypeCode.INT
  };
}