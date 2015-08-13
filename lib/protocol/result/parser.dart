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

library result.parser;

import 'dart:mirrors';
import 'package:Connector/protocol/result/reader.dart';
import 'package:Connector/protocol/common/type_code.dart';
import 'package:Connector/protocol/common/read_function.dart';

class Parser {
  
  List _metadata;
  Parser(this._metadata);
  
  Map parseFunction(String name, Reader reader) {
      List columns = new List();
      for (int i = 0; i < _metadata.length; i++) {
        var column = _metadata[i];
        var arg;
        if (column.dataType == TypeCode.DECIMAL.index) {
          arg = column.fraction;
        }
        var key;
        if (name is String) {
          key = reflect(column).getField(new Symbol(name)).reflectee;
        } else {
          key = i;
        }
        columns.add({
          'key': key,
          'fname': ReadFunction.inst.readFunc[column.dataType],
          'arg': arg
        });
      }

      Map obj = new Map();
      for (int i = 0; i < columns.length; i++) {
        Map column = columns[i];
        InstanceMirror im = reflect(reader);
        List args = new List();
        if (column['arg'] != null) {
          args.add(column['arg']);
        }
        obj[column['key']] = im.invoke(new Symbol(column['fname']), args).reflectee;
      }
      return obj;
    }
}