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

library protocol.common.enumbase;

import "dart:mirrors";

class EnumBase {
  Map<int, String> LOOKUP = new Map<int, String>();
  Map<int, Object> ENUMLOOKUP = new Map<int, Object>();
  
  EnumBase() {
    String clazz = this.runtimeType.toString();
    InstanceMirror im = reflect(this);
    ClassMirror cm = im.type;

    for (var m in cm.declarations.values) {
      Symbol s = m.simpleName;
      String name = MirrorSystem.getName(s);
      if (name != clazz && name != 'inst' && name != 'ENUMLOOKUP' && name != 'LOOKUP') {
        LOOKUP[im.getField(s).reflectee.value] = name;
        ENUMLOOKUP[im.getField(s).reflectee.value] = im.getField(s).reflectee;
      }
    }
  }
}
