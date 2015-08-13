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
  String tableName = getTableName('CHARSTRING_TYPES');
  useVMConfiguration();
  TestConnection tc = getConnection();
  Client conn = tc.client;
  tc.future.then((int status) {
    group("Char String Type", () {
      setUp(() {
        return setupDb(conn, 
            'CREATE COLUMN TABLE ' + tableName + ' ('+
                'VARCHAR_TEST VARCHAR(100), '+
                'SHORTTEXT_TEST SHORTTEXT(100), '+
                'NVARCHAR_TEST NVARCHAR(100), '+
                'ALPHANUM_TEST ALPHANUM(100))', 
            "INSERT INTO " + tableName + " VALUES ("+
                "'Test', "+
                "'Lorem ipsum dolor sit amet.', "+
                "'मला चॉकलेट आइस्क्रीम आवडीचे आहे', "+
                "'A day has 24 hours and an hour has 60 minutes')");
      });

      tearDown(() {
        return tearDownDb(conn, 'DROP TABLE ' + tableName);
      });

      test("VARCHAR", () {
        rowValidate(conn,
            "SELECT VARCHAR_TEST AS VAL FROM " + tableName,
            'Test');
      });

      test("NVARCHAR", () {
        rowValidate(conn,
            "SELECT NVARCHAR_TEST AS VAL FROM " + tableName, 
            'मला चॉकलेट आइस्क्रीम आवडीचे आहे');
      });

      test("ALPHANUM", () {
        rowValidate(conn,
            "SELECT ALPHANUM_TEST AS VAL FROM " + tableName, 
            'A day has 24 hours and an hour has 60 minutes');
      });

      test("SHORTTEXT", () {
        rowValidate(conn,
            "SELECT SHORTTEXT_TEST AS VAL FROM " + tableName, 
            'Lorem ipsum dolor sit amet.');
      });
    });
  });
}
