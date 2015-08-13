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

import "dart:async";
import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

import 'package:Connector/client/client.dart';
import 'package:Connector/test_manager.dart';

void main() {
  String tableName = getTableName('DMLTEST');
  useVMConfiguration();
  TestConnection tc = getConnection();
  Client conn = tc.client;
  tc.future.then((int status) {
    group("DML Tests", () {
      sqlExec(sql1, sql2, id, name) {
        Future res = conn.exec(sql1);
        res.then((var rows) {
          Future res2 = conn.exec(sql2);
          res2.then((var rows) {
            expect(rows[0]['ID'], equals(id));
            expect(rows[0]['NAME'], equals(name));
          });
          expect(res2, completes);
        });
        expect(res, completes);
      }

      setUp(() {
        return setupDb(conn, 'DROP TABLE ' + tableName, 
            'CREATE TABLE ' + tableName + ' (ID INT, NAME VARCHAR(50))', true);
      });

      test("INSERT", () {
        sqlExec("INSERT INTO " + tableName + " VALUES (21, 'Wayne')", 
            "SELECT * FROM " + tableName, 21, 'Wayne');
      });

      setUp(() {});

      test("UPDATE", () {
        sqlExec("UPDATE " + tableName + " SET ID=22 WHERE NAME = 'Wayne'", 
            "SELECT * FROM " + tableName, 22, 'Wayne');
      });

      tearDown(() {
        return tearDownDb(conn, 'DROP TABLE ' + tableName);
      });

      test("DELETE", () {
        Future res = conn.exec(
            "DELETE FROM " + tableName + " WHERE NAME='Wayne'");
        res.then((var rows) {
          Future res2 = conn.exec("SELECT * FROM " + tableName);
          res2.then((var rows) {
            expect(rows, isEmpty);
          });
          expect(res2, completes);
        });
        expect(res, completes);
      });
    });
  });
}
