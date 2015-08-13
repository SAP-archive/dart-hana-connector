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

library protocol.common.protocol_common.constants;

import "dart:math" as math;
import 'package:Connector/protocol/common/connect_option.dart';
import 'package:Connector/protocol/common/type_code.dart';
import 'package:Connector/protocol/common/data_format_version.dart';
import 'package:Connector/protocol/common/distribution_protocol_version.dart';

class Constants {
  static final int PACKET_HEADER_LENGTH = 32;
  static final int SEGMENT_HEADER_LENGTH = 24;
  static final int PART_HEADER_LENGTH = 16;
  static final int MAX_PACKET_SIZE = math.pow(2, 17);
  static final int MAX_RESULT_SET_SIZE = math.pow(2, 20);
  
  static final List<ConnectionEntry> DEFAULT_CONNECT_OPTIONS = [
    new ConnectionEntry(ConnectOption.CLIENT_LOCALE, 'en_US', TypeCode.STRING),
    new ConnectionEntry(ConnectOption.COMPLETE_ARRAY_EXECUTION, true, TypeCode.BOOLEAN),
    new ConnectionEntry(ConnectOption.DATA_FORMAT_VERSION2, 
        DataFormatVersion.COMPLETE_DATATYPE_SUPPORT, TypeCode.INT),
    new ConnectionEntry(ConnectOption.DATA_FORMAT_VERSION, 
        DataFormatVersion.COMPLETE_DATATYPE_SUPPORT, TypeCode.INT),
    new ConnectionEntry(ConnectOption.DISTRIBUTION_PROTOCOL_VERSION, 
        DistributionProtocolVersion.BASE, TypeCode.INT),
    new ConnectionEntry(ConnectOption.SELECT_FOR_UPDATE_SUPPORTED, false, TypeCode.BOOLEAN),
    new ConnectionEntry(ConnectOption.ROW_AND_COLUMN_OPTIMIZED_FORMAT, true, TypeCode.BOOLEAN)
  ]; 
}

class ConnectionEntry {
  ConnectOption name;
  var value;
  TypeCode type;
  
  ConnectionEntry(this.name, this.value, this.type);
}