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

library protocol.auth.saml;

import "dart:convert";
import "dart:typed_data";

class SAML {
  final String _name = 'SAML';
  String _assertion;
  String _user;
  Uint8List _sessionCookie;

  String get name {
    return _name;
  }
  
  String get user {
    return _user;
  }
  
  Uint8List get sessionCookie {
    return _sessionCookie;
  }
  
  SAML(Map options) {
    _assertion = (options.containsKey('assertion')) ? options['assertion'] :
        options['password'];
  }

  initialData() {
    return _assertion;
  }

  initialize(Uint8List buffer) {
    _user = UTF8.decode(buffer);
  }

  finalData() {
    return new Uint8List(0);
  }

  finalize(buffer) {
    _sessionCookie = buffer;
  }
}
