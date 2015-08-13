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

library protocol.result.result_set_transform;

import 'dart:async';
import 'dart:typed_data';
import 'package:Connector/protocol/result/result_set.dart';
import "package:Connector/protocol/result/reader.dart";
import 'package:Connector/protocol/result/parser.dart';

class ResultSetTransform {
  static const DEFAULT_THRESHOLD = 128;
  
  StreamTransformer _strTransformer;
  List _metadata;
  ResultSet _rs;
  int _threshold;
  List _objectBuffer;

  ResultSetTransform(this._rs, this._metadata, [Map options = null]) {
    if (options == null) {
      options = new Map();
    }

    _threshold = (options['threshold'] == null) ? DEFAULT_THRESHOLD : options['threshold'];

    _objectBuffer = new List();
    _strTransformer = new StreamTransformer((Stream input, bool cancelOnError) {
      StreamController controller;
      StreamSubscription subscription;
      controller = new StreamController(onListen: () {
        subscription = input.listen((Uint8List data) {
          controller.add(transform(data));
        }, 
        onError: (err) {
          controller.addError(err);
        }, 
        onDone: controller.close, 
        cancelOnError: cancelOnError);
      });
      return controller.stream.listen(null);
    });
  }
  
  StreamTransformer get streamTransformer {
    return _strTransformer;
  }

  List transform(Uint8List data) {
    _objectBuffer.clear();
    Reader reader = new Reader(data, _rs);
    Parser p = new Parser(_metadata);
    
    run() {
      int i = 0;
      while (reader.hasMore() && i++ < _threshold) {
        _objectBuffer.add(p.parseFunction('columnDisplayName', reader));
      }
      if (reader.hasMore()) {
        run();
      }
    }
    run();
    return _objectBuffer;
  }
}
