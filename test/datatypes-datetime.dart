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
  String tableName = getTableName('DATETIME_TYPES');
  useVMConfiguration();
  TestConnection tc = getConnection();
  Client conn = tc.client;
  tc.future.then((int status) {
    group("Date Time Type", () {
      setUp(() {
        return setupDb(conn, 
            'CREATE COLUMN TABLE ' + tableName + ' ('+
                'DATE_TEST DATE, '+
                'TIME_TEST TIME, '+
                'TIMESTAMP_TEST TIMESTAMP, '+
                'SECONDDATE_TEST SECONDDATE)', 
            "INSERT INTO " + tableName + " VALUES ("+
                "'2014-07-01', "+
                "'09:28:03', "+
                "'2014-07-01T09:28:03', "+
                "'2014-07-01 09:28:03')");
      });

      tearDown(() {
        return tearDownDb(conn, 'DROP TABLE ' + tableName);
      });

      test("DATE", () {
        rowValidate(conn,
            "SELECT DATE_TEST AS VAL FROM " + tableName,
            '2014-07-01');
      });

      test("TIME", () {
        rowValidate(conn,
            "SELECT TIME_TEST AS VAL FROM " + tableName,
            '09:28:03');
      });

      test("TIMESTAMP", () {
        rowValidate(conn,
            "SELECT TIMESTAMP_TEST AS VAL FROM " + tableName, 
            '2014-07-01T09:28:03');
      });

      test("SECONDDATE", () {
        rowValidate(conn,
            "SELECT SECONDDATE_TEST AS VAL FROM " + tableName, 
            '2014-07-01T09:28:03');
      });
    });
  });
}
