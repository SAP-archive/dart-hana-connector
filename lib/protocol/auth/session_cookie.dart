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

library protocol.auth.session_cookie;

import "dart:typed_data";
import "package:Connector/util/util.dart";

class SessionCookie {
  Map _options;
  Uint8List _termId;
  Uint8List _rawSessionCookie;
  Uint8List _sessionCookie;

  SessionCookie(options) {
    _options = (options != null) ? options : new Map();
    _termId = createBuffer(clientId());
    _rawSessionCookie = options['sessionCookie'];
    
    int length = _rawSessionCookie.length + _termId.length;
    
    _sessionCookie = new Uint8List(length);
    _sessionCookie.addAll(_rawSessionCookie);
    _sessionCookie.addAll(_termId);
  }
  
  Uint8List get sessionCookie {
    return _sessionCookie;
  }
  
  Uint8List initialData() {
    return _sessionCookie;
  }
  
  Uint8List finalData() {
    return new Uint8List(0);
  }
}
