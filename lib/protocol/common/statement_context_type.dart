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

library protocol.common.statement_context_type;

import "package:Connector/protocol/common/statement_context.dart";
import "package:Connector/protocol/common/type_code.dart";
import 'dart:mirrors';

class StatementContextTypeEnum {
  static final StatementContextTypeEnum inst = new StatementContextTypeEnum();
  
  Map<StatementContextType, String> LOOKUP = new Map<StatementContextType, String>();
  Map<String, StatementContextType> ENUMLOOKUP = new Map<String, StatementContextType>();

  final STATEMENT_SEQUENCE_INFO = new StatementContextType(TypeCode.BSTRING);
  final SERVER_EXECUTION_TIME = new StatementContextType(TypeCode.INT);
  
  StatementContextTypeEnum() {
    InstanceMirror im = reflect(this);
    ClassMirror cm = im.type;
    
    for (var m in cm.declarations.values) {
      Symbol s = m.simpleName;
      String name = MirrorSystem.getName(s);
      if (name != 'StatementContextTypeEnum' && name != 'inst' && 
          name != 'ENUMLOOKUP' && name != 'LOOKUP') {
        LOOKUP[im.getField(s).reflectee] = name;
        ENUMLOOKUP[name] = im.getField(s).reflectee;
      }
    }
  }
}

class StatementContextType {
  TypeCode typeCode;
  StatementContextType(this.typeCode);
}