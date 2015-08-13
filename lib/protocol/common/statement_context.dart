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

library protocol.common.statement_context;

import 'dart:mirrors';
import 'package:Connector/protocol/reply/reply.dart';
import 'package:Connector/protocol/result/reader.dart';
import 'package:Connector/protocol/common/read_function.dart';

class StatementContextEnum {
  static final StatementContextEnum inst = new StatementContextEnum();

  Map<int, String> LOOKUP = new Map<int, String>();
  Map<int, StatementContext> ENUMLOOKUP = new Map<int, StatementContext>();

  final STATEMENT_SEQUENCE_INFO = new StatementContext(1);
  final SERVER_EXECUTION_TIME = new StatementContext(2);
  
  StatementContextEnum() {
    InstanceMirror im = reflect(this);
    ClassMirror cm = im.type;
    
    for (var m in cm.declarations.values) {
      Symbol s = m.simpleName;
      String name = MirrorSystem.getName(s);
      if (name != 'StatementContextEnum' && name != 'inst' && 
          name != 'ENUMLOOKUP' && name != 'LOOKUP') {
        LOOKUP[im.getField(s).reflectee.value] = name;
        ENUMLOOKUP[im.getField(s).reflectee.value] = im.getField(s).reflectee;
      }
    }
  }
}

class StatementContext {
  int value;
  StatementContext(this.value);
  
  static List read(Reply reply) {
    return reply.attributes['statementContext'].map((Map c) {
      
      var value = c['value'];
      if (value is List) {
        Reader reader = new Reader(value, null);
        InstanceMirror im = reflect(reader);
        Symbol readFn = new Symbol(ReadFunction.inst.readFunc[c['type'].value]);
        
        try {
          value = im.getField(readFn).reflectee();
        } catch (e) {
          print('error when parsing value $e');
        }
      }
      
      return {
        'value': value,
        'name' : StatementContextEnum.inst.LOOKUP[c['name']]
      };
    }).toList();
  }
}