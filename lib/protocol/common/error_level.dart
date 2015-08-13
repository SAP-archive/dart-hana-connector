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

library protocol.common.error_level;

class ErrorLevel {
  final int index;
  final String _name;
  const ErrorLevel(this.index, this._name);
  String toString() => '$ErrorLevel.$_name';
  
  static const ErrorLevel WARNING = const ErrorLevel(0, 'WARNING');
  static const ErrorLevel ERROR = const ErrorLevel(1, 'ERROR');
  static const ErrorLevel FATAL = const ErrorLevel(2, 'FATAL');
  
  static const List<ErrorLevel> values = const <ErrorLevel>[WARNING, ERROR, FATAL];
}