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

library protocol.reply.reply;

import "package:Connector/util/util.dart";
import "package:Connector/protocol/common/part_kind.dart";
import "package:Connector/protocol/data/data.dart";
import "package:Connector/protocol/reply/replypart.dart";

class Reply {
  int _kind;
  int _functionCode;
  List _resultSets = new List();
  Map _attributes = new Map();
  
  Reply(this._kind, this._functionCode);
  
  int get kind {
    return _kind;
  }

  int get functionCode {
    return _functionCode;
  }

  List get resultSets {
    return _resultSets;
  }
  
  Map get attributes {
    return _attributes;
  }

  void addResultSetFragment(name, value) {
    var resultSet = (_resultSets.isNotEmpty) ?
      _resultSets[_resultSets.length - 1] : null;
    
    if (name == 'resultSet') {
      name = 'data';
    } else if (name == 'resultSetId') {
      name = 'id';
    } else if (name == 'resultSetMetadata') {
      name = 'metadata';
    }
    
    if (resultSet == null || resultSet[name] != null) {
      resultSet = new Map();
      resultSet[name] = value;
      _resultSets.add(resultSet);
    } else {
      resultSet[name] = value;
    }
    
    
  }
  
  void add(ReplyPart part) {
    String name = toCamelCase(PartKindEnum.inst.LOOKUP[part.kind.value]);
    var value = Data.getDataType(PartKindEnum.inst.ENUMLOOKUP[part.kind.value]).read(part);
    
    if (name.startsWith('resultSet') || name == 'tableName') {
      addResultSetFragment(name, value);
    } else {
      if (_attributes.containsKey(name) == false) {
        _attributes[name] = value;
      } else if (_attributes[name] is List) {
        _attributes[name].add(value);
      } else {
        var existingValue = _attributes[name];
        _attributes[name] = [existingValue, value]; 
      }
    }
  }
}



