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

import 'package:Connector/protocol/common/type_code.dart';
//import "dart:mirrors";

class NormalizedTypeCodeEnum{
//  static final NormalizedTypeCodeEnum inst = new NormalizedTypeCodeEnum();
//  
//  Map<int, String> LOOKUP = new Map<int, String>();
//  Map<int, TypeCode> ENUMLOOKUP = new Map<int, TypeCode>();
  
  static final TINYINT = TypeCode.TINYINT;
  static final SMALLINT = TypeCode.SMALLINT;
  static final INT = TypeCode.INT;
  static final BIGINT = TypeCode.BIGINT;
  static final DOUBLE = TypeCode.DOUBLE;
  static final REAL = TypeCode.REAL;                
  static final DECIMAL = TypeCode.DECIMAL;
  static final STRING = TypeCode.STRING;
  static final VARCHAR1 = TypeCode.STRING;
  static final VARCHAR2 = TypeCode.STRING;
  static final CHAR = TypeCode.STRING;
  static final SHORTTEXT = TypeCode.STRING;
  static final ALPHANUM = TypeCode.STRING;
  static final NCHAR = TypeCode.NSTRING;
  static final NVARCHAR = TypeCode.NSTRING;
  static final NSTRING = TypeCode.NSTRING;
  static final BINARY = TypeCode.BINARY;
  static final VARBINARY = TypeCode.BINARY;
  static final BSTRING = TypeCode.BINARY;
  static final BLOB = TypeCode.BLOB;
  static final LOCATOR = TypeCode.BLOB;
  static final CLOB = TypeCode.CLOB;
  static final NCLOB = TypeCode.NCLOB;
  static final NLOCATOR = TypeCode.NCLOB;
  static final TEXT = TypeCode.NCLOB;
  static final DATE = TypeCode.DATE;
  static final TIME = TypeCode.TIME;
  static final TIMESTAMP = TypeCode.TIMESTAMP;
  static final DAYDATE = TypeCode.DAYDATE;
  static final SECONDTIME = TypeCode.SECONDTIME;
  static final LONGDATE = TypeCode.LONGDATE;
  static final SECONDDATE = TypeCode.SECONDDATE;

  
//  NormalizedTypeCodeEnum() {
//      InstanceMirror im = reflect(this);
//      ClassMirror cm = im.type;
//      
//      for (var m in cm.declarations.values) {
//        Symbol s = m.simpleName;
//        String name = MirrorSystem.getName(s);
//        if (name != 'NormalizedTypeCodeEnum' && name != 'inst' && 
//            name != 'ENUMLOOKUP' && name != 'LOOKUP') {
//          LOOKUP[im.getField(s).reflectee.value] = name;
//          ENUMLOOKUP[im.getField(s).reflectee.value] = im.getField(s).reflectee;
//        }
//      }
//    }
  
}