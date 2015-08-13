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

library protocol.auth.scramsha256;

import "dart:math";
import "dart:typed_data";

import 'package:crypto/crypto.dart';

import "package:Connector/protocol/common/part_kind.dart";
import "package:Connector/protocol/data/fields.dart";
import "package:Connector/protocol/request/part.dart";
import 'package:Connector/util/util.dart';

class SCRAMSHA256 {
  static const int CLIENT_CHALLENGE_SIZE = 64;
  static const int CLIENT_PROOF_SIZE = 32;
  
  final Random _random = new Random(); 
  final String _name = 'SCRAMSHA256';
  String _user;
  Uint8List _password;
  Uint8List _clientChallenge;
  Uint8List _clientProof;
  Uint8List _sessionCookie;

  SCRAMSHA256(options) {
    if (options == null) {
      options = new Map();
    }
    
    var pwd = options['password'];    
    _password = (className(pwd) == 'OneByteString') ?
       createBuffer(pwd) : pwd;
    
    _clientChallenge = (options.containsKey('clientChallenge')) ?
        options['clientChallenge'] : createClientChallenge();
  }
  
  Uint8List get sessionCookie {
    return _sessionCookie;  
  }
  
  String get name {
    return _name;
  }

  String get user {
    return _user;
  }


  Uint8List createClientChallenge() {
    List<int> list = new List<int>();  
    for (int i = 0; i < CLIENT_CHALLENGE_SIZE; i++) {
      list.add(_random.nextInt(255));
    }
    return new Uint8List.fromList(list);
  }

  Uint8List initialData() {
    return _clientChallenge;
  }

  initialize(Uint8List buffer) {
    Part p = new Part(PartKindEnum.inst.NIL, 1);
    p.buffer = buffer;
    
    List<List<int>> serverChallengeData = (new Fields()).read(p);
    _clientProof = calculateClientProof([serverChallengeData[0]],
      serverChallengeData[1], _clientChallenge, _password);
  }

  finalData() {
    return _clientProof;
  }

  finalize(buffer) {
    // NO-OP
  }

  Uint8List calculateClientProof(List<List<int>> salts, List<int> serverKey, 
                       Uint8List clientKey, Uint8List password) {
    List<int> buf = new List<int>();
    buf.add(0x00);
    buf.add(salts.length);
    
    for (int i = 0; i < salts.length; i++) {
      buf.add(CLIENT_PROOF_SIZE);
      buf.addAll(scramble(salts[i], serverKey, clientKey, password));
    }

    return new Uint8List.fromList(buf);
  }
  

  Uint8List scramble(List<int> salt, Uint8List serverKey, 
           Uint8List clientKey, Uint8List password) {
    int length = salt.length + serverKey.length + clientKey.length;
    List<int> buf = new List<int>();
    
    buf.addAll(salt);
    buf.addAll(serverKey);
    buf.addAll(clientKey);

    var key = sha256(hmac(password, salt));
    var sig = hmac(sha256(key), buf);
    return xor(sig, key);
  }

  Uint8List xor(a, b) {
    Uint8List result = new Uint8List(a.length);    
    for (var i = 0; i < a.length; i++) {
      result[i] = a[i] ^ b[i];
    }
    return result;
  }

  hmac(List<int> key, List<int> msg) {
    return createHmac(key, msg);
  }

  List<int> createHmac(List<int> secretBytes, List<int> messageBytes) {
    HMAC hmac = new HMAC(new SHA256(), secretBytes);
    hmac.add(messageBytes);
    List<int> digest = hmac.close();
    //String hash = CryptoUtils.bytesToBase64(digest);
    return digest;
  }
  
  sha256(List<int> msg) {
    SHA256 sha = new SHA256();
    sha.add(msg);
    return sha.close();
  }
}






