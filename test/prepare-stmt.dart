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

import 'dart:async';

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

import 'package:Connector/client/client.dart';
import 'package:Connector/test_manager.dart';

void main() {
  String tableName = getTableName('PREPARE_STMT_TEST');
  useVMConfiguration();
  TestConnection tc = getConnection();
  Client conn = tc.client;
  tc.future.then((int status) {
    group("Prepare Statement Tests", () {

      sqlExec(sql1, sql2, argList, test, {positive: true, exception: null}) {
        Future prep = conn.prepare(sql1);
        prep.then((ps) {
          try {
            Future res = ps.exec(argList);
            res.then((result) {
              Future res2 = conn.exec(sql2);
              res2.then((rows) {
                test(rows);
              });

              if (positive) {
                expect(res2, completes);
              }
            }, onError: (e) {
              if (exception != null) {
                expect(e, exception);
              }
            });
            if (positive) {
              expect(res, completes);
            }
          } catch (e) {
            if (exception != null) {
              expect(e, exception);
            }
          }
        }, onError: (e) {
          expect(e.code, equals(270));
        });

        if (positive) {
          expect(prep, completes);
        }
      }

      setUp(() {
        return setupDb(conn, 
            'DROP TABLE ' + tableName, 
            'CREATE COLUMN TABLE ' + tableName + ' (' + 
                'INTEGER_TEST INTEGER, ' + 
                'TINYINT_TEST TINYINT, ' + 
                'SMALLINT_TEST SMALLINT, ' + 
                'BIGINT_TEST BIGINT, ' + 
                'DOUBLE_TEST DOUBLE, ' + 
                'REAL_TEST REAL, ' + 
                'FLOAT_TEST FLOAT, ' + 
                'DATE_TEST DATE, ' + 
                'TIME_TEST TIME, ' + 
                'TIMESTAMP_TEST TIMESTAMP, ' + 
                'VARCHAR_TEST VARCHAR(100), ' + 
                'SHORTTEXT_TEST SHORTTEXT(100), ' + 
                'NVARCHAR_TEST NVARCHAR(100), ' + 
                'ALPHANUM_TEST ALPHANUM(100))', 
             true);
      });
      
      tearDown(() {
        return tearDownDb(conn, 'DROP TABLE ' + tableName);
      });

      test("INSERT (Positive Test)", () {
        test_insert(rows) {
          expect(rows[0]['INTEGER_TEST'], equals(21));
          expect(rows[0]['VARCHAR_TEST'], equals('Wayne'));
        }
        sqlExec("INSERT INTO " + tableName + 
                    "(INTEGER_TEST, VARCHAR_TEST) VALUES (?, ?)", 
                "SELECT * FROM " + tableName, 
                [21, 'Wayne'], 
                test_insert);
      });

      test("INSERT (Negative Test - Incorrect Input DataType)", () {
        sqlExec("INSERT INTO " + tableName + " VALUES (?, ?)", 
                "SELECT * FROM " + tableName, 
                '21', 
                'Error', 
                positive: false);
      });

      test("INSERT (Negative Test - Incorrect Input DataType)", () {
        sqlExec("INSERT INTO " + tableName + " VALUES (?, ?)", 
                "SELECT * FROM " + tableName, 
                ['21', 'Wayne'], 
                'Error', 
                positive: false);
      });

      test("INSERT (Negative Test - Incorrect Number of Input Parameters)",() {
        sqlExec("INSERT INTO " + tableName + " VALUES (?, ?)", 
                "SELECT * FROM " + tableName, 
                ['21', 'Wayne', 'Bill'], 
                'Error', 
                positive: false);
      });

      test("BULK INSERT (Positive Test)", () {
        test_bulk_insert(rows) {
          expect(rows[0]['INTEGER_TEST'], equals(21));
          expect(rows[0]['VARCHAR_TEST'], equals('Wayne'));
          expect(rows[1]['INTEGER_TEST'], equals(22));
          expect(rows[1]['VARCHAR_TEST'], equals('White'));
        }
        sqlExec("INSERT INTO " + tableName + 
                    "(INTEGER_TEST, VARCHAR_TEST) VALUES (?, ?)", 
                "SELECT * FROM " + tableName, 
                [[21, 'Wayne'], [22, 'White']], 
                test_bulk_insert);
      });

      test("BULK INSERT (Negative Test - " + 
                    "Inconsistent Number of Input Parameters)", () {
        sqlExec("INSERT INTO " + tableName + 
                    "(INTEGER_TEST, VARCHAR_TEST) VALUES (?, ?)", 
                "SELECT * FROM " + tableName, 
                [[21, 'Wayne'], [210, 'Will', 22, 'Turner']], 
                'Error', 
                positive: false, 
                exception: isRangeError);
      });
    });
  });
}
