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

library protocol.common.protocol_common.connect_option;

class ConnectOption {
  static Map<int, String> LOOKUP = new Map<int, String>();
  
  static final CONNECTION_ID = createEnum('CONNECTION_ID', 1);
  static final COMPLETE_ARRAY_EXECUTION = createEnum('COMPLETE_ARRAY_EXECUTION', 2);
  static final CLIENT_LOCALE = createEnum('CLIENT_LOCALE', 3);
  static final SUPPORTS_LARGE_BULK_OPERATIONS = createEnum('SUPPORTS_LARGE_BULK_OPERATIONS', 4);
  static final LARGE_NUMBER_OF_PARAMETERS_SUPPORT = createEnum('LARGE_NUMBER_OF_PARAMETERS_SUPPORT', 10);
  static final SYSTEM_ID = createEnum('SYSTEM_ID', 11);
  static final DATA_FORMAT_VERSION = createEnum('DATA_FORMAT_VERSION', 12);
  static final SELECT_FOR_UPDATE_SUPPORTED = createEnum('SELECT_FOR_UPDATE_SUPPORTED', 14);
  static final CLIENT_DISTRIBUTION_MODE = createEnum('CLIENT_DISTRIBUTION_MODE', 15);
  static final ENGINE_DATA_FORMAT_VERSION = createEnum('ENGINE_DATA_FORMAT_VERSION', 16);
  static final DISTRIBUTION_PROTOCOL_VERSION = createEnum('DISTRIBUTION_PROTOCOL_VERSION', 17);
  static final SPLIT_BATCH_COMMANDS = createEnum('SPLIT_BATCH_COMMANDS', 18);
  static final USE_TRANSACTION_FLAGS_ONLY = createEnum('USE_TRANSACTION_FLAGS_ONLY', 19);
  static final ROW_AND_COLUMN_OPTIMIZED_FORMAT = createEnum('ROW_AND_COLUMN_OPTIMIZED_FORMAT', 20);
  static final IGNORE_UNKNOWN_PARTS = createEnum('IGNORE_UNKNOWN_PARTS', 21);
  static final DATA_FORMAT_VERSION2 = createEnum('DATA_FORMAT_VERSION2', 23);

  final int value;
  const ConnectOption._(this.value);
  
  static ConnectOption createEnum(name, val) {
    LOOKUP[val] = name;
    return new ConnectOption._(val);
  }  
}
