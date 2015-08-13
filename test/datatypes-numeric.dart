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

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

import 'package:Connector/client/client.dart';
import 'package:Connector/test_manager.dart';

void main() {
  String tableName = getTableName('NUMERIC_TYPES');
  useVMConfiguration();
  TestConnection tc = getConnection();
  Client conn = tc.client;
  tc.future.then((int status) {
    group("Numeric Type", () {
      setUp(() {
        return setupDb(conn,
            'CREATE COLUMN TABLE ' + tableName + ' ('+
                'INTEGER_TEST INTEGER, ' +
                'TINYINT_TEST TINYINT, '+
                'SMALLINT_TEST SMALLINT, '+
                'BIGINT_TEST BIGINT, '+
                'DOUBLE_TEST DOUBLE, '+
                'REAL_TEST REAL, '+
                'FLOAT_TEST FLOAT, '+
                'DECIMAL_TEST DECIMAL, '+
                'SMALLDECIMAL_TEST SMALLDECIMAL)',
            'INSERT INTO ' + tableName + ' VALUES ('+
                '5, '+
                '5, '+
                '5, '+
                '5223372036854775807, '+
                '12.5123123, '+
                '10.153122901916504, '+
                '9.123123168945312, '+
                '1512312.56, '+
                '1512312.568)');
      });
      
      tearDown(() {
        return tearDownDb(conn, 'DROP TABLE ' + tableName);
      });

      test("INTEGER", () {
        rowValidate(conn,
            "SELECT INTEGER_TEST AS VAL FROM " + tableName,
            5);
      });  

      test("TINYINT", () {
        rowValidate(conn,
            "SELECT TINYINT_TEST AS VAL FROM " + tableName, 
            5);
      });
      
      test("SMALLINT", () {
        rowValidate(conn,
            "SELECT SMALLINT_TEST AS VAL FROM " + tableName, 
            5);
      }); 

      test("BIGINT", () {
        rowValidate(conn,
            "SELECT BIGINT_TEST AS VAL FROM " + tableName, 
            5223372036854775807);
      }); 

      test("DOUBLE", () {
        rowValidate(conn,
            "SELECT DOUBLE_TEST AS VAL FROM " + tableName,
            12.5123123);
      });      

      test("REAL", () {
        rowValidate(conn,
            "SELECT REAL_TEST AS VAL FROM " + tableName,
            10.153122901916504);
      });
      
      test("FLOAT", () {
        rowValidate(conn,
            "SELECT FLOAT_TEST AS VAL FROM " + tableName,
            9.123123168945312);
      });
      
      test("DECIMAL", () {
        rowValidate(conn,
            "SELECT DECIMAL_TEST AS VAL FROM " + tableName,
            1512312.56);
      });
      
      test("SMALLDECIMAL", () {
        rowValidate(conn,
            "SELECT SMALLDECIMAL_TEST AS VAL FROM " + tableName,
            1512312.568);
      });  
    });
  });
}
