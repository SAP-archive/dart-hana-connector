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

library protocol.common.function_code;

class FunctionCode {
  final int index;
    final String _name;
    const FunctionCode(this.index, this._name);
    String toString() => '$FunctionCode.$_name';
    
    static const FunctionCode NIL = const FunctionCode(0, 'NIL');
    static const FunctionCode DDL = const FunctionCode(1, 'DDL');
    static const FunctionCode INSERT = const FunctionCode(2, 'INSERT');
    static const FunctionCode UPDATE = const FunctionCode(3, 'UPDATE');
    static const FunctionCode DELETE = const FunctionCode(4, 'DELETE');
    static const FunctionCode SELECT = const FunctionCode(5, 'SELECT');
    static const FunctionCode SELECT_FOR_UPDATE = const FunctionCode(6, 'SELECT_FOR_UPDATE');
    static const FunctionCode EXPLAIN = const FunctionCode(7, 'EXPLAIN');
    static const FunctionCode DB_PROCEDURE_CALL = const FunctionCode(8, 'DB_PROCEDURE_CALL');
    static const FunctionCode DB_PROCEDURE_CALL_WITH_RESULT = const FunctionCode(9, 'DB_PROCEDURE_CALL_WITH_RESULT');
    static const FunctionCode FETCH = const FunctionCode(10, 'FETCH');
    static const FunctionCode COMMIT = const FunctionCode(11, 'COMMIT');
    static const FunctionCode ROLLBACK = const FunctionCode(12, 'ROLLBACK');
    static const FunctionCode SAVEPOINT = const FunctionCode(13, 'SAVEPOINT');
    static const FunctionCode CONNECT = const FunctionCode(14, 'CONNECT');
    static const FunctionCode WRITE_LOB = const FunctionCode(15, 'WRITE_LOB');
    static const FunctionCode READ_LOB = const FunctionCode(16, 'READ_LOB');
    static const FunctionCode PING = const FunctionCode(17, 'PING');
    static const FunctionCode DISCONNECT = const FunctionCode(18, 'DISCONNECT');
    static const FunctionCode CLOSE_CURSOR = const FunctionCode(19, 'CLOSE_CURSOR');
    static const FunctionCode FIND_LOB = const FunctionCode(20, 'FIND_LOB');
    static const FunctionCode ABAP_STREAM = const FunctionCode(21, 'ABAP_STREAM');
    static const FunctionCode XA_START = const FunctionCode(22, 'XA_START');
    static const FunctionCode XA_JOIN = const FunctionCode(23, 'XA_JOIN');
    
    static const List<FunctionCode> values = const <FunctionCode>[NIL, DDL, INSERT, UPDATE, DELETE, SELECT, SELECT_FOR_UPDATE, EXPLAIN, DB_PROCEDURE_CALL, DB_PROCEDURE_CALL_WITH_RESULT, FETCH, COMMIT, ROLLBACK, SAVEPOINT, CONNECT, WRITE_LOB, READ_LOB, PING, DISCONNECT, CLOSE_CURSOR, FIND_LOB, ABAP_STREAM, XA_START, XA_JOIN];
    
}
