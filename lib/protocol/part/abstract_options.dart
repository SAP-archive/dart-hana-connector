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

import "package:Connector/util/util.dart";
import "dart:mirrors";

class AbstractOptions {
  List KEYS;
  Map TYPES;
  Map<int, String> PROPERTYNAMES;

  List<Map> getOptions() {
    List<Map> options = new List<Map>();
    for (var i= 0; i < KEYS.length; i++) {
      var name = KEYS[i];
      String propertyName = toCamelCase(PROPERTYNAMES[name.value]);
      InstanceMirror im = reflect(this).getField(new Symbol(propertyName));
      var value = (im.hasReflectee) ? im.reflectee : null;
      var type = (TYPES.containsKey(name)) ? TYPES[name] : TYPES[PROPERTYNAMES[name.value]].typeCode;
      options.add({
        'name': name.value,
        'value': value,
        'type': type
      });
    }
    return options;
  }

  void setOptions(var options) {
    if (!(options is List)) {
      return;
    }
    
    for (int t = 0; t < options.length; t++) {
      if (options[t] is Map) {
        var name = options[t]['name'];
        if (PROPERTYNAMES.containsKey(name)) {
          String propertyName = toCamelCase(PROPERTYNAMES[name]);
          InstanceMirror im = reflect(this).setField(new Symbol(propertyName), options[t]['value']);
        }
      }
    }
  }
}
