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
  useVMConfiguration();
  TestConnection tc = getConnection();
  Client conn = tc.client;
  tc.future.then((int status) {
    print('Running high volume result tests, this may take time..');
    group("Limit Tests", () {
      test("100 rows VARCHAR", () {
        rowSizeValidate(conn,
            "SELECT BUKRS FROM SAPTYE.BSEG LIMIT 100",
            100);
      });

      test("1000 rows VARCHAR", () {
        rowSizeValidate(conn,
            "SELECT BUKRS FROM SAPTYE.BSEG LIMIT 1000", 1000);
      });      

      test("100,000 rows VARCHAR", () {
        rowSizeValidate(conn,
            "SELECT BUKRS FROM SAPTYE.BSEG LIMIT 100000", 100000);
      }); 

      test("1,000,000 rows VARCHAR", () {
        rowSizeValidate(conn,
            "SELECT BUKRS FROM SAPTYE.BSEG LIMIT 1000000", 1000000);
      }); 

      test("335 columns, LIMIT 10", () {
        rowSizeValidate(conn,
            "SELECT * FROM SAPTYE.BSEG LIMIT 10", 10);
      });
      
      test("335 columns, LIMIT 1,000", () {
        rowSizeValidate(conn,
            "SELECT * FROM SAPTYE.BSEG LIMIT 1000", 1000);
      });
      
      test("335 columns, LIMIT 10,000", () {
        rowSizeValidate(conn,
            "SELECT * FROM SAPTYE.BSEG LIMIT 10000", 10000);
      });
      
    });
  });
}
