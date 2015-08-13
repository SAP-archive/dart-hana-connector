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
    group("Select Tests", () {
      
      test("Dummy", () {
        rowValidate(conn,
            "SELECT 5 AS VAL, 6 AS VAL2 FROM DUMMY " + 
            "UNION ALL " + 
            "SELECT 3 AS VAL, 4 AS VAL2 FROM DUMMY",
            5);
      });      
    });
  });
}
