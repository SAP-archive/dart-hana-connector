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

import 'dart:async';

void main() {

  useVMConfiguration();
  TestConnection tc = getConnection();
  Client client = tc.client;
  tc.future.then((int status) {
    group("Stream Tests", () {

      test("Stream", () {
        Future exec = client.exec("SELECT * FROM SAPTYE.BSEG LIMIT 2000", 
            fetchResultForStreaming: true);
        Completer c = new Completer();
        List allRows = [];

        chunk_received(chunk) {
          allRows.addAll(chunk);
        }

        exec.then((rows) {
          StreamSubscription subscription 
           = rows.createArrayStream().listen((data) {
            chunk_received(data);
          }, 
          onError: (error) => print("Errorwhile listening to stream"), 
          onDone: expectAsync(() {
            rows.close();
            expect(allRows, hasLength(2000));
            c.complete();
          }));
        });

        expect(c.future, completes);
        expect(exec, completes);
      });

      test("Pause/resume", () {
        Completer c = new Completer();
        List allRows = [];
        int chunkCount = 0;

        chunk_received(chunk) {
          allRows.addAll(chunk);
          chunkCount++;
        }

        Future exec = client.exec("SELECT * FROM SAPTYE.BSEG LIMIT 2000", 
            fetchResultForStreaming: true);
        exec.then(expectAsync((resultSet) {
          Stream stream = resultSet.createArrayStream();
          StreamSubscription subscription;
          subscription = stream.listen((data) {
            chunk_received(data);
            if (chunkCount == 1) {
              subscription.pause();
              new Timer(const Duration(seconds: 2), 
                  expectAsync(subscription.resume));
            }
          }, 
          onError: (error) => print("Errorwhile listening to stream"), 
          onDone: expectAsync(() {
            resultSet.close();
            expect(allRows, hasLength(2000));
            c.complete();
          }));
        }));
        expect(c.future, completes);
        expect(exec, completes);
      });

    });
  });
}
