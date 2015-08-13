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

library protocol.common.transaction_flag;

class TransactionFlag{
  final int index;
  final String _name;
  const TransactionFlag(this.index, this._name);
  String toString() => '$TransactionFlag.$_name';
  
  static const TransactionFlag ROLLED_BACK = const TransactionFlag(0, 'ROLLED_BACK');
  static const TransactionFlag COMMITTED = const TransactionFlag(1, 'COMMITTED');
  static const TransactionFlag NEW_ISOLATION_LEVEL = const TransactionFlag(2, 'NEW_ISOLATION_LEVEL');
  static const TransactionFlag DDL_COMMIT_MODE_CHANGED = const TransactionFlag(3, 'DDL_COMMIT_MODE_CHANGED');
  static const TransactionFlag WRITE_TRANSACTION_STARTED = const TransactionFlag(4, 'WRITE_TRANSACTION_STARTED');
  static const TransactionFlag NO_WRITE_TRANSACTION_STARTED = const TransactionFlag(5, 'NO_WRITE_TRANSACTION_STARTED');
  static const TransactionFlag SESSION_CLOSING_TRANSACTION_ERROR = const TransactionFlag(6, 'SESSION_CLOSING_TRANSACTION_ERRROR');
  
  static const List<TransactionFlag> values = const <TransactionFlag>[ROLLED_BACK, COMMITTED, NEW_ISOLATION_LEVEL, DDL_COMMIT_MODE_CHANGED, WRITE_TRANSACTION_STARTED, NO_WRITE_TRANSACTION_STARTED, SESSION_CLOSING_TRANSACTION_ERROR];
}