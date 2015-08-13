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

library protocol.common.data_format_version;

class DataFormatVersion {
  static const BASE_FORMAT = const DataFormatVersion._(0);
  static const COMPLETE_DATATYPE_SUPPORT = const DataFormatVersion._(1);
  static const EXTENDED_DATE_TIME_SUPPORT = const DataFormatVersion._(3);
  static const LEVEL4 = const DataFormatVersion._(4);

  final int value;
  const DataFormatVersion._(this.value);
}