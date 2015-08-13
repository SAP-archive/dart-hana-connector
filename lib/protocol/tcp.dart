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

library protocol.tcp;

import 'dart:async';
import 'dart:io';

Future<RawSocket> connect(Map options) {
    options['allowHalfOpen'] = false;

  if (options.containsKey('key') || options.containsKey('cert') || options.containsKey('ca') || options.containsKey('pfx')) {
    // conn = tls.connect;
    return null; // TOFIX
  } else {
    return RawSocket.connect(options['host'], options['port']);
  }
}
