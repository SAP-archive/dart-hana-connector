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

library protocol.common.result_set_attributes;

class ResultSetAttributes {

  static const LAST = const ResultSetAttributes(1);
  static const NEXT = const ResultSetAttributes(2);
  static const FIRST = const ResultSetAttributes(4);
  static const ROW_NOT_FOUND = const ResultSetAttributes(8);
  static const CLOSED = const ResultSetAttributes(16);
    
  final int value;
  const ResultSetAttributes(this.value);
}
