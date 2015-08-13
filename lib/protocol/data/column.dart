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

library protocol.data.column;

import "package:Connector/protocol/common/parameter_mode.dart";

class Column {
  static final int READONLY = ParameterMode.READONLY.value;
  static final int AUTO_INCREMENT = ParameterMode.AUTO_INCREMENT.value;
  static final int MANDATORY = ParameterMode.MANDATORY.value;

  int mode;
  int dataType;
  int fraction;
  int length;
  String tableName;
  String schemaName;
  String columnName;
  String columnDisplayName;

  Column(this.mode, this.dataType, this.fraction, this.length);

  bool isReadOnly() {
    return (mode & READONLY > 0);
  }

  bool isMandatory() {
    return (mode & MANDATORY > 0);
  }

  bool isAutoIncrement() {
    return (mode & AUTO_INCREMENT > 0);
  }
}
