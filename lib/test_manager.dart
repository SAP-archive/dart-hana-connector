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

library Connector;

import 'dart:async';
import 'dart:math';

import 'package:Connector/client/client.dart';
import 'package:Connector/util/cesu8_coding.dart';
import 'package:unittest/unittest.dart';

export 'package:Connector/test_manager.dart';

TestConnection getConnection() {
  Map connectOptions = {
    "user": "username",
    "password": "password"
  };
  Map init = {
    "host": "hostIP",
    "port": 12345
  };

  Client c = new Client(init);
  Future f = c.connect(connectOptions);
  return new TestConnection(c, f);
}

String getTableName(String table) {
  return 'DARTTEST.' + table + new Random().nextInt(100).toString();
}

void lobValidate(conn, String sql, var expected, [bool cesu8Decode = false]) {
  Future res = conn.exec(sql);
  res.then((var resRow) {
    var val = resRow[0]['VAL'];
    if (cesu8Decode) {
      expect(decodeCESU8(val), equals(expected));
    } else {
      expect(val, equals(expected));
    }
  });
  expect(res, completes);
}

void rowSizeValidate(conn, String sql, int expected) {
  Future res = conn.exec(sql);
  res.then((var rows) {
    expect(rows, hasLength(expected));
  });
  expect(res, completes);
}

void rowValidate(conn, String sql, var expected) {
  Future res = conn.exec(sql);
  res.then((var rows) {
    expect(rows[0]['VAL'], equals(expected));
  });
  expect(res, completes);
}

Future setupDb(Client conn, String createCmd, String postCreateCmd, [bool execOnError = false]) {
  Completer co = new Completer();
  conn.exec(createCmd).then((val) {
    if (postCreateCmd == null) {
      co.complete();
    } else {
      conn.exec(postCreateCmd).then((val) {
        co.complete();
      });
    }
  }, onError: (error) {
    if (execOnError) {
      conn.exec(postCreateCmd).then((val) {
        co.complete();
      });
    } else {
      co.complete();
    }
  });
  return co.future;
}

void sqlSimpleIntValidate(conn, String sql, int expected) {
  Future res = conn.exec(sql);
  res.then((var rows) {
    expect(rows, equals(expected));
  });
  expect(res, completes);
}

void sqlSimpleStringValidate(conn, String sql, String expected) {
  Future res = conn.exec(sql);
  res.then((var rows) {
    expect(rows, equals(expected));
  });
  expect(res, completes);
}

Future tearDownDb(Client conn, String cmd) {
  Completer co = new Completer();
  conn.exec(cmd).then((val) {
    co.complete();
  }, onError: (error) {
    co.complete(); // ignore
  });
  return co.future;
}

class TestConnection {
  Client client;
  Future future;
  TestConnection(this.client, this.future);
}
