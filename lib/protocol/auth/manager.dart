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

library protocol.auth.manager;

import 'dart:convert';

import "package:Connector/protocol/auth/saml.dart";
import "package:Connector/protocol/auth/scramsha256.dart";
import "package:Connector/protocol/auth/session_cookie.dart";
import "package:Connector/util/util.dart";


class AuthManager {
  String _user;
  var _authMethod;
  List _authMethods = new List();
  
  AuthManager(Map options) {
    if (options == null) {
      options = new Map();
    }
    
    _user = (options.containsKey('user')) ? options['user'] : '';
    
    if (options.containsKey('assertion') || 
        (!options.containsKey('user') && options.containsKey('password'))) {
      _authMethods.add(new SAML(options));
    }
    
    if (options.containsKey('sessionCookie')) {
      _authMethods.add(new SessionCookie(options));
    }
    
    if (options.containsKey('user') && options.containsKey('password')) {
      _authMethods.add(new SCRAMSHA256(options));
    }
    
    if (_authMethods.length == 0) {
      throw new Exception('noAuthMethodFound');
    }
  }
  
  String getUserFromServer() {
    return (_authMethod != null && _authMethod.user != null) ? _authMethod.user : _user;
  }
  
  SessionCookie getSessionCookie() {
    return (_authMethod != null && _authMethod.sessionCookie != null) ?
      _authMethod.sessionCookie : null;
  }
  
  initialData() {
    var fields = [_user];
    
    for (int i = 0; i < _authMethods.length; i++) {
      var a = _authMethods[i];
      fields.add(a.name);
      fields.add(a.initialData());
    }

    return fields;
  }
  

  void initialize(List fields) {
    var initializedMethods = [];
    
    while (fields.length > 0) {
      String name = UTF8.decode(fields.removeAt(0));
      
      var method = getMethod(name);
      var buffer = fields.removeAt(0);
      if (method != null && buffer != null) {
        method.initialize(buffer);
        initializedMethods.add(method);
      }
    }
    
    if (initializedMethods.length == 0) {
      throw new Exception('noAuthMethodFound');
    }
    
    _authMethod = initializedMethods.removeAt(0);
    _authMethods = new List();
  }

  List finalData() {
    var fields = [getUserFromServer()];
    if (_authMethod != null) {
      fields.add(_authMethod.name);
      fields.add(_authMethod.finalData());
    }
    return fields;
  }

  void finalize(List fields) {
    while (fields.length > 0) {
      var name = fields.removeAt(0);
      var buffer = fields.removeAt(0);
      
      if (_authMethod.name == readString(name, 0, name.length)) {
        _authMethod.finalize(buffer);
        break;
      }
    }
  }

  getMethod(name) {
    for (int i = 0; i < _authMethods.length; i++) {
      var method = _authMethods[i];
      if (method.name == name) {
        return method;
      }
    }
    return null;
  }
}
