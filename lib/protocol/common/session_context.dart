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

library protocol.common.session_context;

class SessionContext {
  final int index;
  final String _name;
  const SessionContext(this.index, this._name);
  String toString() => '$SessionContext.$_name';
  
  static const SessionContext PRIMARY_CONNECTION_ID = const SessionContext(1, 'PRIMARY_CONNECTION_ID');
  static const SessionContext PRIMARY_HOST = const SessionContext(2, 'PRIMARY_HOST');
  static const SessionContext PRIMARY_PORT = const SessionContext(3, 'PRIMARY_PORT');
  static const SessionContext MASTER_CONNECTION_ID = const SessionContext(4, 'MASTER_CONNECTION_ID');
  static const SessionContext MASTER_HOST = const SessionContext(5, 'MASTER_HOST');
  static const SessionContext MASTER_PORT = const SessionContext(6, 'MASTER_PORT');
  
  static const List<SessionContext> values = const <SessionContext>[null, PRIMARY_CONNECTION_ID, PRIMARY_HOST, PRIMARY_PORT, MASTER_CONNECTION_ID, MASTER_HOST, MASTER_PORT];
}