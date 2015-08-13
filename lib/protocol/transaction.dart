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

library protocol.transaction;

import 'package:Connector/protocol/data/sqlerror.dart';
import 'package:Connector/protocol/common/error_level.dart';

class Transaction {
  bool _autoCommit;
  String kind = 'none';
  SQLError _error = null; // Where is _error used?

  Transaction() :
    _autoCommit = true;
  
  set autoCommit(bool c) {
    _autoCommit = c;
  }
  
  bool get autoCommit {
    return _autoCommit;
  }
  
  void setFlags(Map flags) {
    if (flags['committed'] != null || flags['rolledBack'] != null) {
      kind = 'none';
    }
    if (flags['writeTransactionStarted'] != null) {
      kind = 'write';
    }
    if (flags['noWriteTransactionStarted'] != null) {
      kind = 'read';
    }
    if (flags['sessionClosingTransactionErrror'] != null) {
      _error = new SQLError(
        message: 'A transaction error occured that implies the session must be terminated.',
        code: 'EHDBTH',
        level: ErrorLevel.FATAL.index,
        fatal: true
      );
    }
  }
}