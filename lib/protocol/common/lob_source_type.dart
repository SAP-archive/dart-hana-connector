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

library protocol.common.lob_source_type;

class LobSourceType {
  final int index;
  final String _name;
  const LobSourceType(this.index, this._name);
  String toString() => '$LobSourceType.$_name';
  
  static const LobSourceType UNKNOWN = const LobSourceType(0, 'UNKNOWN');
  static const LobSourceType BLOB = const LobSourceType(1, 'BLOB');
  static const LobSourceType CLOB = const LobSourceType(2, 'CLOB');
  static const LobSourceType NCLOB = const LobSourceType(3, 'NCLOB');
  
  static const List<LobSourceType> values = const <LobSourceType>[UNKNOWN, BLOB, CLOB, NCLOB];
}