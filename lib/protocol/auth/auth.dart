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

library protocol.auth;

import "dart:typed_data";

import "package:Connector/protocol/auth/manager.dart";

List<String> SECURE_AUTH_KEYS = ['pfx', 'key', 'cert', 'ca', 'passphrase', 'rejectUnauthorized', 'secureProtocol'];
List<String> SESSION_KEYS = ['user', 'password', 'assertion', 'sessionCookie'];
List<Uint8List> HANDSHAKE_BUFFER = [0xff, 0xff, 0xff, 0xff, 4, 20, 0x00, 4, 1, 0x00, 0x00, 1, 1, 1];

createAuthManager(Map options) {
  return new AuthManager(options);
}