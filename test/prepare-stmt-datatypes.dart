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
import 'dart:convert';
import 'dart:typed_data';

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

      test_image(var lobObjectValue, int expectedLength) {
        File imgFile = new File('thisruns.jpg');
        imgFile.writeAsBytesSync(lobObjectValue);
        imgFile.exists().then(expectAsync((exists) {
          expect(exists, equals(true));
          imgFile.length().then(expectAsync((len) {
            expect(len, equals(expectedLength));
            imgFile.delete();
          }));
        }));
      }

      setUp(() {
        tableName = getTableName('PREPARE_STMT_TEST');
        return setupDb(conn, 
            'DROP TABLE ' + tableName, 
            'CREATE COLUMN TABLE ' + tableName + ' ('+
                'INTEGER_TEST INTEGER, '+
                'TINYINT_TEST TINYINT, '+
                'SMALLINT_TEST SMALLINT, '+
                'BIGINT_TEST BIGINT, '+
                'DOUBLE_TEST DOUBLE, '+
                'REAL_TEST REAL, '+
                'FLOAT_TEST FLOAT, '+
                'DATE_TEST DATE, '+
                'TIME_TEST TIME, '+
                'TIMESTAMP_TEST TIMESTAMP, '+
                'VARCHAR_TEST VARCHAR(100), '+
                'SHORTTEXT_TEST SHORTTEXT(100), '+
                'NVARCHAR_TEST NVARCHAR(100), '+
                'ALPHANUM_TEST ALPHANUM(100))', 
            true);
      });
      
      tearDown(() {
        return tearDownDb(conn, 'DROP TABLE ' + tableName);
      });

      test("DataTypes", () {
        DateTime now = DateTime.parse("2014-07-17 16:12:45.600");

        test_insert(rows) {
          expect(rows[0]['INTEGER_TEST'], equals(42));
          expect(rows[0]['TINYINT_TEST'], equals(5));
          expect(rows[0]['SMALLINT_TEST'], equals(5));
          expect(rows[0]['BIGINT_TEST'], equals(5223372036854775807));
          expect(rows[0]['DOUBLE_TEST'], equals(12.5123123));
          expect(rows[0]['REAL_TEST'], equals(10.153122901916504));
          expect(rows[0]['FLOAT_TEST'], equals(9.123123168945312));
          expect(rows[0]['DATE_TEST'], equals('2014-07-17'));
          expect(rows[0]['TIME_TEST'], equals('16:12:45'));
          expect(rows[0]['TIMESTAMP_TEST'], equals('2014-07-17T16:12:45'));
          expect(rows[0]['VARCHAR_TEST'], equals('Test'));
          expect(rows[0]['SHORTTEXT_TEST'], 
              equals('Lorem ipsum dolor sit amet.'));
          expect(rows[0]['NVARCHAR_TEST'], 
              equals('मला चॉकलेट आइस्क्रीम आवडीचे आहे'));
          expect(rows[0]['ALPHANUM_TEST'], 
              equals('A day has 24 hours and an hour has 60 minutes'));
        }

        sqlExec("INSERT INTO " + tableName + " VALUES " +
                "(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
            "SELECT * FROM " + tableName + " WHERE INTEGER_TEST = 42",
            [42, 
             5, 
             5, 
             5223372036854775807, 
             12.5123123, 
             10.153122901916504, 
             9.123123168945312, 
             now, 
             now, 
             now, 
             'Test', 
             'Lorem ipsum dolor sit amet.', 
             'मला चॉकलेट आइस्क्रीम आवडीचे आहे', 
             'A day has 24 hours and an hour has 60 minutes'], 
             test_insert);
      });

      setUp(() {
        tableName = getTableName('PREPARE_STMT_TEST2');
        return setupDb(conn, 
            'DROP TABLE ' + tableName, 
            'CREATE COLUMN TABLE ' + tableName + ' (' + 
                'DEC_TEST DECIMAL(30,5), ' + 
                'INTEGER_TEST INTEGER, ' + 
                'BINARY_TEST BINARY(50), ' + 
                'BLOB_TEST BLOB, ' + 
                'CLOB_TEST CLOB, ' + 
                'NCLOB_TEST NCLOB, ' + 
                'TEXT_TEST TEXT)', 
             true);
      });
      
      tearDown(() {
        return tearDownDb(conn, 'DROP TABLE ' + tableName);
      });

      test("DataTypes - BINARY", () {
        ByteBuffer binaryData = new Uint8List.fromList(UTF8.encode('abcde')).buffer;
        
        test_insert(rows) {
          expect(rows[0]['BINARY_TEST'], 
              equals(new Uint8List.view(binaryData)));
        }

        sqlExec(
          "INSERT INTO " + tableName + " (BINARY_TEST) VALUES (?)",
          "SELECT * FROM " + tableName, 
          [binaryData], 
          test_insert);
      });

      test("DataTypes - BLOB IMAGE - LARGE", () {
        test_insert(rows) {
          test_image(rows[0]['BLOB_TEST'], 648914);
        }

        Stream<List<int>> stream = new File('bigImgSample.png').openRead();
        sqlExec(
            "INSERT INTO " + tableName + " (BLOB_TEST) VALUES (?)",
            "SELECT * FROM " + tableName, 
            stream, 
            test_insert);
      });

      test("DataTypes - BLOB IMAGE - SMALL", () {
        test_insert(rows) {
          test_image(rows[0]['BLOB_TEST'], 8782);
        }
        
        Stream<List<int>> stream = new File('saphana.jpeg').openRead();
        sqlExec(
            "INSERT INTO " + tableName + " (BLOB_TEST) VALUES (?)",
            "SELECT * FROM " + tableName, 
            stream, 
            test_insert);
      });

      test("DataTypes - BLOB (Text)", () {
        test_insert(rows) {
          expect(rows[0]['BLOB_TEST'], equals([97, 98, 99, 100, 101]));
        }

        sqlExec(
            "INSERT INTO " + tableName + " (BLOB_TEST) VALUES (?)",
            "SELECT * FROM " + tableName, 
            ['abcde'], 
            test_insert, 
            positive: false);
      });

      test("DataTypes - CLOB", () {
        var inputVal = 'Tell me, Muse, of the man of many ways, who was '+
        'drivenfar journeys, after he had sacked Troys sacred citadel.Many '+
        'were they whose cities he saw, whose minds he learned of,many the '+
        'pains he suffered in his spirit on the wide sea,struggling for his '+
        'own life and the homecoming of his companions.Even so he could not '+
        'save his companions, hard thoughhe strove to; they were destroyed '+
        'by their own wild recklessness,fools, who devoured the oxen of '+
        'Helios, the Sun God,and he took away the day of their homecoming. '+
        'From some pointhere, goddess, daughter of Zeus, speak, and begin '+
        'our story.Then all the others, as many as fled sheer destruction,'+
        'were at home now, having escaped the sea and the fighting.This one '+
        'alone, longing for his wife and his homecoming,was detained by the '+
        'queenly nymph Kalypso, bright among goddesses,in her hallowed '+
        'caverns, desiring that he should be her husband.But when the '+
        'circling of the years that very year camein which the gods had '+
        'spun for him his time of homecomingto Ithaka, not even then was '+
        'he free of his trialnor among his won people. But all the gods '+
        'pitied himexcept Poseidon; he remained relentlessly angrywith '+
        'godlike Odysseus, until he returned to his own country.';
            
        test_insert(rows) {
          expect(rows[0]['CLOB_TEST'], equals(inputVal));
        }

        sqlExec(
            "INSERT INTO " + tableName + " (CLOB_TEST) VALUES (?)", 
            "SELECT * FROM " + tableName, 
            [inputVal], 
            test_insert);
      });

      test("DataTypes - NCLOB", () {
        var inputVal = 'इंग्रजीच्या प्रेमामुळे अनेक प्राचार्य मराठी '+
          'विषयाकडे उपेक्षेनेच पाहातात. प्रवेशा देण्यापासून तो विषय '+
          'ठेवण्यापर्यंत चालढकल करीत राहातात. अगदी थोड्या विद्यार्थ्यांना '+
          'प्रवेश द्यावयाचा. संख्या कमी म्हणून विभाग बंद करण्याच्या कारवाया '+
          'करायच्या. तीन तीन हजार विद्यार्थी संख्या असलेल्या महाविद्यालयात '+
          'मराठी साहित्यातील ग्रंथ विकत घेण्यासाठी रक्कम ठरविताना खळखळ '+
          'करायची. मराठी विभागासाठी फार तर चारपाचशे रूपयांचीच रक्कम मंरूर '+
          'करायची. इंग्रजीसारख्या विभागासाठी तीनचार हजार रूपये मजूर '+
          'करायचे. भाषेच्या प्राध्यापकांच्या पीरियडची संख्या कमी करून वर्ग '+
          'मोठे करायचे. हे विद्यापीठाच्या नियमात बसत नाही, तरीही चालू '+
          'असते, एका कॉलेजात प्रथम वर्षाच्या वर्गात २७३ विद्यार्थी होते. '+
          'वर्गात बसण्याची व्यवस्था फक्त १४८ विद्यार्थ्यांची. कनिष्ठ '+
          'महाविद्यालयातही ही प्रथा चालू होती. पुढेही चालू राहाणार आहे. '+
          '८०-१०० विद्यार्थ्यांची अट असली तरी १२५ पर्यंत वर्गाट '+
          'विद्यार्थ्यांची संख्या ठेवायची. पीरीयडस्‌ कमी केल्यामुळे दोन '+
          'प्राध्यापकांच्या जागी एक तर एकाच्या जागी पुढे पार्ट टाईम नेमायचा. '+
          'शेवटी कंत्राट पद्धतीवर नेमला जातो. अमराठी मुलांनी मराठी '+
          'शिकण्याची इच्छा प्रदर्शित केली, अर्ज केले तर कालहरण करीत '+
          'राहायचे. शेवटी वाटाण्याच्या अक्षता लावायच्या. अशा अनेक '+
          'युक्त्याप्रयुक्त्या करून मराठी विषयाची उपेक्षा करावयाची. बरे '+
          'ही गोष्ट अमराठी प्राचार्यच करतात असे नव्हे, तर मराठी प्राचार्यही '+
          'या गोष्टी बिनदिक्कत करीत असतात. मराठी ही प्रांतभाषा, राज्यभाषा '+
          'म्हणून तिचे महत्त्व आहे. त्यामुळे नोकरई धंद्याच्या दृष्टीने '+
          'महाराष्ट्रात स्थायिक झालेल्या अमराठी कुटुंबातील विद्यार्थी मराठी '+
          'शिकू पाहातात, पण त्यांची सोयच केलेली नसते. अनेक '+
          'महविद्यालयातील प्रवेड घेण्याच्या फॉर्म्समध्ये मराठी, निम्नस्तर '+
          'मराठी हे विषयच दिलेले नसतात. त्यामुळे आज ते विद्यार्थी '+
          'हिन्दीसारख्या विषयाकडे वळतात. मुलाखतीच्या संदर्भात भेटलो '+
          'असता अनेक विद्यर्थ्यांनी, प्राध्यापकांनी याबाबतीतील तक्रारी '+
          'सांगितल्या त्या सविस्तर सांगणे शक्य नाही. पण एका प्राचार्यानी '+
          'सांगितलेली माहिती सांगतो. मराठी (निम्नस्तर) आपल्याकडे का '+
          'नाही? असे विचरता त्यांनी सांगितलेकी, सिनियर कॉलेजमध्ये '+
          'निम्नस्तर मराठी हा विषय मिळेलच याची खात्री नसल्यामुळे '+
          'आमच्याकडे मुलांनी हा विषय निवडला नाही. त्यांनी हिन्दी विषय '+
          'पसंत केला, त्यामुळे हिन्दीच्या दोन लेक्चररच्या जागा भराव्या '+
          'लगल्या. मराठीच्या वर्गात पुरेशी संख्या नसल्यामुळे तो बंद '+
          'करण्यात आला. हीच गोष्ट (सीनियर) महाविद्यालयाबाबत '+
          'प्राचार्याना विचारले की ते म्हणतात निम्नस्तर मराठीसाठी मुलेच '+
          'येत नाहीत,म्हणून आम्ही सीनियरचा वर्ग सुरू करू शकलॊ '+
          'नाही. हे दुष्टचक्र वाचकांच्या लक्षात आले असेलच.';
        
        test_insert(rows) {
          expect(rows[0]['NCLOB_TEST'], equals(inputVal));
        }

        sqlExec(
            "INSERT INTO " + tableName + " (NCLOB_TEST) VALUES (?)",
            "SELECT * FROM " + tableName, 
            [inputVal], 
            test_insert);
      });

      test("DataTypes - NCLOB (read from file)", () {
        test_insert(rows) {
          expect(rows[0]['NCLOB_TEST'], 
              equals(new File('Data_NCLob.txt')
                        .readAsStringSync(encoding: UTF8)));
        }

        File file = new File('Data_NCLob.txt');
        Stream inputStream = file.openRead();

        sqlExec(
            "INSERT INTO " + tableName + " (NCLOB_TEST) VALUES (?)",
            "SELECT * FROM " + tableName, 
            inputStream, 
            test_insert);
      });

      test("DataTypes - TEXT", () {
        var inputVal = 'text Lorem ipsum dolor sit amet, consectetur '+
          'adipiscing elit. Mauris quis magna ut tortor pulvinar elementum '+
          'iaculis at ante. Aenean egestas dolor non auctor auctor. Vivamus '+
          'faucibus tellus libero. Pellentesque tristique volutpat magna. '+
          'Vestibulum ante ipsum primis in faucibus orci luctus et ultrices '+
          'posuere cubilia Curae; Mauris tortor eros, luctus a risus quis, '+
          'pharetra cursus metus. Sed eu aliquet mauris. Morbi varius, quam '+
          'a semper auctor, erat ipsum faucibus erat, sit amet vehicula diam '+
          'purus vel purus. Mauris id venenatis nibh, at aliquam dolor. Ut '+
          'eu vestibulum odio. Duis hendrerit odio massa, in blandit velit '+
          'tempor ac. Nulla facilisi. In est lacus, vehicula sit amet sem '+
          'sed, interdum consequat felis. Etiam molestie commodo dui, ac '+
          'accumsan diam elementum dictum. Morbi bibendum eleifend augue. '+
          'Curabitur orci ante, pulvinar vel pellentesque id, facilisis at '+
          'leo. Sed est mi, malesuada eu mi vel, dictum hendrerit justo. In '+
          'tincidunt metus tortor, eu aliquet purus fermentum non. Vestibulum '+
          'enim arcu, scelerisque quis nibh id, pharetra auctor lectus. Donec '+
          'id ante non nunc posuere gravida. Duis egestas tincidunt '+
          'porttitor. Aenean eget velit at lorem rhoncus tincidunt in ac '+
          'erat. Aenean id hendrerit magna. Etiam semper, ligula vitae '+
          'ornare semper, mi turpis gravida eros, ut vehicula urna leo vel '+
          'quam. In at vestibulum ligula. Maecenas semper mauris in commodo '+
          'congue.';

        test_insert(rows) {
          expect(rows[0]['TEXT_TEST'], equals(inputVal));
        }

        sqlExec(
            "INSERT INTO " + tableName + " (TEXT_TEST) VALUES (?)",
            "SELECT * FROM " + tableName, 
            [inputVal], 
            test_insert);
      });

      test("DataTypes - BLOB IMAGE + NCLOB", () {
        test_insert(rows) {
          test_image(rows[0]['BLOB_TEST'], 8782);
          expect(rows[0]['NCLOB_TEST'], 
              equals(new File('Data_NCLob.txt')
                        .readAsStringSync(encoding: UTF8)));
        }

        File file = new File('Data_NCLob.txt');
        Stream inputStream = file.openRead();
  
        Stream<List<int>> imgInputStream = new File('saphana.jpeg').openRead();
        sqlExec("INSERT INTO " + tableName +
                "(NCLOB_TEST, BLOB_TEST) VALUES (?, ?)", 
            "SELECT * FROM " + tableName, 
            [inputStream, imgInputStream], 
            test_insert);
      });

      test("DataTypes - BLOB IMAGE + INT", () {
        test_insert(rows) {
          test_image(rows[0]['BLOB_TEST'], 8782);
          expect(rows[0]['INTEGER_TEST'], equals(100));
        }

        Stream<List<int>> imgInputStream = new File('saphana.jpeg').openRead();
        sqlExec("INSERT INTO " + tableName +
                "(INTEGER_TEST, BLOB_TEST) VALUES (?, ?)", 
            "SELECT * FROM " + tableName, 
            [100, imgInputStream], 
            test_insert);
      });

      test("DataTypes - DECIMAL", () {
        var decimalTestInputs 
          = [[100.5], [-100.5], [9223732036854.54], 
             [-9923732036854.54], [-99237320368.5454]];
        
        test_insert(rows) {
          for (int i=0 ; i<decimalTestInputs.length ; i++) {
            expect(rows[i]['DEC_TEST'], equals(decimalTestInputs[i][0]));
          }
        }
        sqlExec(
            "INSERT INTO " + tableName + " (DEC_TEST) VALUES (?)", 
            "SELECT * FROM " + tableName, 
            decimalTestInputs, 
            test_insert);
      });

    });
  });
}
