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
import 'package:Connector/protocol/common/function_code.dart';
import 'package:Connector/protocol/common/segment_kind.dart';
import 'package:Connector/test_manager.dart';

void main() {
  String tableName = getTableName('TATEST2');
  useVMConfiguration();
  Completer com = new Completer();
  
  // Transaction Test: execute with autocommit false, and discconect connection
  TestConnection tc3 = getConnection();
  Client conn3 = tc3.client;
  Completer comp = new Completer();
    
  TestConnection tc2 = getConnection();
  Client conn2 = tc2.client;
          
  tc3.future.then((int status3) {
    
    execute_test() {
      Future res0 = conn3.exec("INSERT INTO " + tableName + " VALUES('testX')");
      res0.then((reply) {
        expect(reply['rowsAffected'], equals(1));
      });
          
      Future res1 = conn2.exec("INSERT INTO " + tableName + " VALUES('testZ')");
      res1.then((reply) {
        expect(reply['rowsAffected'], equals(1));
      });
      
      Future res2 = conn3.exec('SELECT * FROM ' + tableName);
      res2.then((var rows) {
        List<String> names = [rows[0]['NAME'], rows[1]['NAME']];
        expect(names.contains('testX'), equals(true));
        expect(names.contains('testZ'), equals(true));
      });
                
      tc2.future.then((int status2) {
        conn2.autoCommit = false;
        Future result = conn2.exec(
            "INSERT INTO " + tableName + " VALUES('test')");
        result.then((reply) {
          expect(reply['rowsAffected'], equals(1));
          Future res = conn2.exec('SELECT * FROM ' + tableName);
          res.then((var rows) {
            List<String> names 
              = [rows[0]['NAME'], rows[1]['NAME'], rows[2]['NAME']];
            expect(names.contains('testX'), equals(true));
            expect(names.contains('testZ'), equals(true));
            expect(names.contains('test'), equals(true));
            comp.complete();
          });
          expect(res, completes);
        });
        expect(result, completes);
      });

      comp.future.then((val) {
        conn2.disconnect();
        conn2.close();
        Future res0 = conn3.exec('SELECT * FROM ' + tableName);
        res0.then((var rows) {
          expect(rows.length, equals(2));
          List<String> names = [rows[0]['NAME'], rows[1]['NAME']];
          expect(names.contains('testX'), equals(true));
          expect(names.contains('testZ'), equals(true));
          conn3.disconnect();
          conn3.close();
          com.complete();
        });
      });
    }
  
    conn2.exec('CREATE COLUMN TABLE ' + tableName + ' (NAME VARCHAR(100))')
    .then((status) {
      execute_test();
    }, onError: (err) {
      conn2.exec('DROP TABLE ' + tableName).then((status) {
        conn2.exec('CREATE COLUMN TABLE ' + tableName + ' (NAME VARCHAR(100))')
        .then((status) {
          execute_test();
        });
      });
    });
      
  });
  
  com.future.then((completeStatus) {  
    // start testing only after previous tests are done
    TestConnection tc = getConnection();
    Client conn = tc.client;
    tc.future.then((int status) {

      group("Transaction Tests", () {
  
        setUp(() {
          return setupDb(conn, 
              'DROP TABLE ' + tableName, 
              'CREATE COLUMN TABLE ' + tableName + ' (NAME VARCHAR(100))', 
              true);
        });
      
        test("execute - setAutoCommit(false)", () {
          conn.autoCommit = false;
          Completer com = new Completer();
          Future result = conn.exec(
              "INSERT INTO " + tableName + " VALUES('test')");
          result.then(expectAsync((reply) {
            expect(reply['rowsAffected'], equals(1));
            Future res = conn.exec('SELECT * FROM ' + tableName);
            res.then(expectAsync((var rows) {
              expect(rows[0]['NAME'], equals('test'));
              com.complete();
            }));
            expect(res, completes);
          }));
          expect(result, completes);
  
          com.future.then(expectAsync((val) {
            TestConnection myTc = getConnection();
            Client myConn = myTc.client;
            myTc.future.then(expectAsync((status) {
              Future res = myConn.exec('SELECT * FROM ' + tableName);
              res.then(expectAsync((var rows) {
                expect(rows.isEmpty, equals(true)); // setAutoCommit was false
                myConn.disconnect();
                myConn.close();
              }));
              expect(res, completes);
            }));
          }));
        });

        test("execute and commit", () {
          conn.autoCommit = false;
          Future result = conn.exec(
              "INSERT INTO " + tableName + " VALUES('test')");
          Future commitresult = conn.commit();
  
          result.then((reply) {
            expect(reply['rowsAffected'], equals(1));
          });
          expect(result, completes);
  
          commitresult.then((reply) {
            // check if commit comes back
            expect(reply.functionCode, equals(FunctionCode.COMMIT.index));
            expect(reply.kind, equals(SegmentKind.REPLY.index));
            Future res = conn.exec('SELECT * FROM ' + tableName);
            res.then((var rows) {
              expect(rows[0]['NAME'], equals('test'));
            });
            expect(res, completes);
          });
          expect(commitresult, completes);
        });

        test("execute and rollback", () {
          conn.autoCommit = false;
          Future result = conn.exec(
              "INSERT INTO " + tableName + " VALUES('test')");
          Future rollbackresult = conn.rollback();
  
          result.then((reply) {
            expect(reply['rowsAffected'], equals(1));
          });
          expect(result, completes);
  
          rollbackresult.then((reply) {
            expect(reply.functionCode, equals(FunctionCode.ROLLBACK.index));
            expect(reply.kind, equals(SegmentKind.REPLY.index));
            Future res = conn.exec('SELECT * FROM ' + tableName);
            res.then((var rows) {
              expect(rows.isEmpty, equals(true));
            });
            expect(res, completes);
          });
          expect(rollbackresult, completes);
        });

        test('multiple executes and commit', () {
          conn.autoCommit = false;
          Future result1 = conn.exec(
              "INSERT INTO " + tableName + " VALUES('test1')");
          Future result2 = conn.exec(
              "INSERT INTO " + tableName + " VALUES('test2')");
          Future result3 = conn.exec(
              "INSERT INTO " + tableName + " VALUES('test3')");
          Future commitresult = conn.commit();
  
          result1.then((reply) => expect(reply['rowsAffected'], equals(1)));
          result2.then((reply) => expect(reply['rowsAffected'], equals(1)));
          result3.then((reply) => expect(reply['rowsAffected'], equals(1)));
  
          commitresult.then((reply) {
            // check if commit comes back
            expect(reply.functionCode, equals(FunctionCode.COMMIT.index));
            expect(reply.kind, equals(SegmentKind.REPLY.index));
            Future res = conn.exec('SELECT * FROM ' + tableName);
            res.then((var rows) {
              expect(rows[0]['NAME'], equals('test1'));
              expect(rows[1]['NAME'], equals('test2'));
              expect(rows[2]['NAME'], equals('test3'));
            });
            expect(res, completes);
          });
          expect(result1, completes);
          expect(result2, completes);
          expect(result3, completes);
          expect(commitresult, completes);
        });

        test("multiple executes and commits/rollback", () {
          conn.autoCommit = false;
          Future result1 = conn.exec(
              "INSERT INTO " + tableName + " VALUES('test1')");
          Future result2 = conn.exec(
              "INSERT INTO " + tableName + " VALUES('test2')");
          Future rollbackresult = conn.rollback();
          Future result3 = conn.exec(
              "INSERT INTO " + tableName + " VALUES('test3')");
          Future commitresult = conn.commit();
  
          result1.then((reply) => expect(reply['rowsAffected'], equals(1)));
          result2.then((reply) => expect(reply['rowsAffected'], equals(1)));
          result3.then((reply) => expect(reply['rowsAffected'], equals(1)));
  
          rollbackresult.then((reply) {
            expect(reply.functionCode, equals(FunctionCode.ROLLBACK.index));
            expect(reply.kind, equals(SegmentKind.REPLY.index));
          });
  
          commitresult.then((reply) {
            // check if commit comes back
            expect(reply.functionCode, equals(FunctionCode.COMMIT.index));
            expect(reply.kind, equals(SegmentKind.REPLY.index));
            Future res = conn.exec('SELECT * FROM ' + tableName);
            res.then((var rows) {
              expect(rows[0]['NAME'], equals('test3'));
            });
            expect(res, completes);
          });
          expect(result1, completes);
          expect(result2, completes);
          expect(result3, completes);
          expect(rollbackresult, completes);
          expect(commitresult, completes);
        });
      
        tearDown(() {
          return tearDownDb(conn, 'DROP TABLE ' + tableName);
        });
        
        test("execute - setAutoCommit(true)", () {
          conn.autoCommit = true;
          Completer com = new Completer();
          Future result = conn.exec(
              "INSERT INTO " + tableName + " VALUES('test')");
          result.then((reply) {
            expect(reply['rowsAffected'], equals(1));
            Future res = conn.exec('SELECT * FROM ' + tableName);
            res.then((var rows) {
              expect(rows[0]['NAME'], equals('test'));
              com.complete();
            });
            expect(res, completes);
          });
          expect(result, completes);
  
          com.future.then((val) {
            TestConnection myTc2 = getConnection();
            Client myConn2 = myTc2.client;
            myTc2.future.then((status) {
              Future res = myConn2.exec('SELECT * FROM ' + tableName);
              res.then((var rows) {
                expect(rows[0]['NAME'], equals('test'));
                myConn2.disconnect();
                myConn2.close();
              });
              expect(res, completes);
            });
          });
        });
      
      });
    
    });
  });
}
