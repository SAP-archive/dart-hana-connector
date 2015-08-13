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
import 'dart:io';

import 'package:unittest/unittest.dart';
import 'package:unittest/vm_config.dart';

import 'package:Connector/client/client.dart';
import 'package:Connector/test_manager.dart';

void main() {
  String tableName;
  useVMConfiguration();
  TestConnection tc = getConnection();
  Client conn = tc.client;
  tc.future.then((int status) {
    var textInput = 'text Lorem ipsum dolor sit amet, consectetur adipiscing '+
        'elit. Mauris quis magna ut tortor pulvinar elementum iaculis at '+
        'ante. Aenean egestas dolor non auctor auctor. Vivamus faucibus '+
        'tellus libero. Pellentesque tristique volutpat magna. Vestibulum '+
        'ante ipsum primis in faucibus orci luctus et ultrices posuere '+
        'cubilia Curae; Mauris tortor eros, luctus a risus quis, pharetra '+
        'cursus metus. Sed eu aliquet mauris. Morbi varius, quam a semper '+
        'auctor, erat ipsum faucibus erat, sit amet vehicula diam purus vel '+
        'purus. Mauris id venenatis nibh, at aliquam dolor. Ut eu vestibulum '+
        'odio. Duis hendrerit odio massa, in blandit velit tempor ac. Nulla '+
        'facilisi. In est lacus, vehicula sit amet sem sed, interdum '+
        'consequat felis. Etiam molestie commodo dui, ac accumsan diam '+
        'elementum dictum. Morbi bibendum eleifend augue. Curabitur orci '+
        'ante, pulvinar vel pellentesque id, facilisis at leo. Sed est mi, '+
        'malesuada eu mi vel, dictum hendrerit justo. In tincidunt metus '+
        'tortor, eu aliquet purus fermentum non. Vestibulum enim arcu, '+
        'scelerisque quis nibh id, pharetra auctor lectus. Donec id ante non '+
        'nunc posuere gravida. Duis egestas tincidunt porttitor. Aenean eget '+
        'velit at lorem rhoncus tincidunt in ac erat. Aenean id hendrerit '+
        'magna. Etiam semper, ligula vitae ornare semper, mi turpis gravida '+
        'eros, ut vehicula urna leo vel quam. In at vestibulum ligula. '+
        'Maecenas semper mauris in commodo congue.';
    
    group("LOB Type", () {
      setUp(() {
        tableName = getTableName('LOB_TYPES');
        return setupDb(conn, 
            'CREATE COLUMN TABLE ' + tableName + ' (' + 
                'TEST_BLOB BLOB, ' + 
                'TEST_CLOB CLOB, ' + 
                'TEST_NCLOB NCLOB, ' + 
                'TEST_TEXT TEXT)', 
             "INSERT INTO " + tableName + " VALUES(" + 
                "TO_BLOB(TO_BINARY('abcde'))," + 
                "TO_CLOB('clob abcde fghij klmno pqrst uvwxy z'), " + 
                "'मला चॉकलेट आइस्क्रीम आवडीचे आहे', '" +
                textInput + "')" );
      });

      tearDown(() {
        return tearDownDb(conn, 'DROP TABLE ' + tableName);
      });

      test("TEXT", () {
        lobValidate(conn, 
            "SELECT TEST_TEXT AS VAL FROM " + tableName, 
            textInput);
      });

      test("CLOB", () {
        lobValidate(conn, 
            "SELECT TEST_CLOB AS VAL FROM " + tableName, 
            'clob abcde fghij klmno pqrst uvwxy z');
      });

      test("NCLOB", () {
        lobValidate(conn, 
            "SELECT TEST_NCLOB AS VAL FROM " + tableName, 
            'मला चॉकलेट आइस्क्रीम आवडीचे आहे');
      });

      test("BLOB", () {
        lobValidate(conn, 
            "SELECT TEST_BLOB AS VAL FROM " + tableName, 
            'abcde', 
            true); // true cesu8 decode
      });
      
      setUp(() {
        tableName = getTableName('BLOB_IMG_TEST');
      });
      
      tearDown(() {
        return tearDownDb(conn, 'DROP TABLE ' + tableName);
      });
      
      Future setupLobTestCases() {
        Stream<List<int>> stream = new File('bigImgSample.png').openRead();
        Completer co = new Completer();
        setupDb(conn, 
          'DROP TABLE ' + tableName, 
          'CREATE COLUMN TABLE ' + tableName + ' (' + 
              'IMAGE BLOB)', 
           true).then((val) {
          Future prep = conn.prepare(
              "INSERT INTO " + tableName + " (IMAGE) VALUES (?)");
          prep.then(expectAsync((ps) {
            Future res = ps.exec(stream);
            res.then(expectAsync((result) {
               co.complete();
            }));
          }));
        });
        return co.future;
      }
      
      test("BLOB-IMAGE (Streaming result and "+
                "using read() to fetch LOB value)", () {
        File imgFile = new File('sirAlex.jpg');
        Future res = conn.exec(
            "SELECT IMAGE AS VAL FROM DARTTEST.BLOB_IMAGE_TEST", 
            fetchResultForStreaming: true);
        res.then(expectAsync((var resultSet) {
          List rsData = new List();
          StreamSubscription subscription = resultSet.createArrayStream()
              .listen((data) {
            rsData.addAll(data);
          }, 
          onError: (error) => print("Errorwhile listening to stream"), 
          onDone: expectAsync(() {
            Future res2 = rsData[0]['VAL'].read();
            res2.then(expectAsync((val) {
              imgFile.writeAsBytesSync(val);
              imgFile.exists().then(expectAsync((exists) {
                expect(exists, equals(true));
                imgFile.length().then(expectAsync((len) {
                  expect(len, equals(743880));
                  imgFile.delete();
                }));
              }));
              expect(res2, completes);
            }));
          }));
          expect(res, completes);
        }));
      });

      test("BLOB-IMAGE (Streaming result and streaming the LOB value "+
                "as well using createReadStream())", () {
        File imgFile = new File('sirAlex2.jpg');
        Future res = conn.exec(
            "SELECT IMAGE AS VAL FROM DARTTEST.BLOB_IMAGE_TEST", 
            fetchResultForStreaming: true);
        res.then(expectAsync((var resultSet) {
          List rsData = new List();
          StreamSubscription subscription = resultSet.createArrayStream()
              .listen((data) {
            rsData.addAll(data);
          },
          onError: (error) => print("Errorwhile listening to stream"), 
          onDone: expectAsync(() {
            // Calling createReadStream on Lob object returned
            Future dataStreamRes = rsData[0]['VAL'].createReadStream();
            dataStreamRes.then(expectAsync((stream) {
              // subscribe to the streams events
              stream.listen((chunks) {
                imgFile.writeAsBytesSync(chunks, mode: FileMode.APPEND);
              }, onError: (err) {
                print('Some Error Occured: $err');
              }, onDone: expectAsync(() {
                imgFile.length().then(expectAsync((len) {
                  expect(len, equals(743880));
                  imgFile.delete();
                  }));
                }));
              }));
            expect(dataStreamRes, completes);
          }));
        }));
        expect(res, completes);
      });
      
    });
  });
}
