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

library protocol.common.message_type;

class MessageType {
  static Map<int, String> LOOKUP = new Map<int, String>();
  
  static final NIL = createEnum('NIL', 0);
  static final EXECUTE_DIRECT = createEnum('EXECUTE_DIRECT', 2);
  static final PREPARE = createEnum('PREPARE', 3);
  static final ABAP_STREAM = createEnum('ABAP_STREAM', 4);
  static final XA_START = createEnum('XA_START', 5);
  static final XA_JOIN = createEnum('XA_JOIN', 6);
  static final EXECUTE = createEnum('EXECUTE', 13);
  static final READ_LOB = createEnum('READ_LOB', 16);
  static final WRITE_LOB = createEnum('WRITE_LOB', 17);
  static final FIND_LOB = createEnum('FIND_LOB', 18);
  static final PING = createEnum('PING', 25);
  static final AUTHENTICATE = createEnum('AUTHENTICATE', 65);
  static final CONNECT = createEnum('CONNECT', 66);
  static final COMMIT = createEnum('COMMIT', 67);
  static final ROLLBACK = createEnum('ROLLBACK', 68);
  static final CLOSE_RESULT_SET = createEnum('CLOSE_RESULT_SET', 69);
  static final DROP_STATEMENT_ID = createEnum('DROP_STATEMENT_ID', 70);
  static final FETCH_NEXT = createEnum('FETCH_NEXT', 71);
  static final DISCONNECT = createEnum('DISCONNECT', 77);
  static final EXECUTE_ITAB = createEnum('EXECUTE_ITAB', 78);
  static final FETCH_NEXT_ITAB = createEnum('FETCH_NEXT_ITAB', 79);
  static final INSERT_NEXT_ITAB = createEnum('INSERT_NEXT_ITAB', 80);
  static final BATCH_PREPARE = createEnum('BATCH_PREPARE', 81);
  
  final int value;
  MessageType(this.value);
  
  static createEnum(name, val) {
    LOOKUP[val] = name;
    return new MessageType(val);
  }
}
