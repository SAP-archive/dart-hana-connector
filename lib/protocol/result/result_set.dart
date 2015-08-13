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

library protocol.result.result_set;

import "dart:math" as math;
import "dart:async";
import 'dart:typed_data';
import "package:Connector/protocol/connection/connection.dart";
import 'package:Connector/protocol/data/column.dart';
import "package:Connector/protocol/lob.dart";
import "package:Connector/protocol/common/result_set_attributes.dart";
import 'package:Connector/protocol/reply/replypart.dart';
import "package:Connector/protocol/result/result_set_transform.dart";
import 'package:Connector/protocol/lob_descriptor.dart';

class StrConsumer extends StreamConsumer {
  List _rows;
  List _columns;
  
  StrConsumer() {
    _rows = new List();
  }
  
  Future addStream(Stream stream) {
    Completer c = new Completer();
    stream.listen(
      (var row) {
        _rows.addAll(row);
    },
    onError: (Error err) {
      print("Error in addStream of StrConsumer" + err.toString());
      c.completeError(err);
    },
    onDone: () {
      c.complete(_rows);
    });
    return c.future;
  }
  
  close() {}
}


class ResultSet {
  static final int MAX_FETCH_SIZE = math.pow(2, 15) - 1;
  static final int DEFAULT_FETCH_SIZE = math.pow(2, 10);
  static final int DEFAULT_ROW_LENGTH = math.pow(2, 6);
  static final int DEFAULT_ARRAY_LENGTH = math.pow(2, 8);
  
  var _id;
  List _metadata;
  bool _closed =  true;
  bool _finished = false;
  bool _running = false;
  
  Connection _connection;
  var _data;
  int _fetchSize;
  int _rowLength;
  int _readSize;
  
  StreamController streamController; // Might not have to be implemented as class instance variable
  
  ResultSet(this._connection, var rsd) {
    _id = rsd['id'];
    _metadata = rsd['metadata'];
    _data = rsd['data'];
    _fetchSize = ResultSet.DEFAULT_FETCH_SIZE;
    _rowLength = ResultSet.DEFAULT_ROW_LENGTH;
    _readSize = Lob.DEFAULT_READ_SIZE;
  }
  
  Future fetch() {
    Completer c = new Completer();
    Stream stream = createArrayStream();
    StreamConsumer collector = new StrConsumer();
    Future fCollector = collector.addStream(stream);
    fCollector.then((var rows) { 
      if (getLobColumnNames().length > 0) {
        collectLobRows(rows).then((resultWithLobRows){
          c.complete(resultWithLobRows);
        },
        onError: (Error err){
          c.completeError(err);
        });
      } else {
        c.complete(rows);  
      }
    });
    return c.future;
  }
  
  Stream createArrayStream ([options = null]) {
    if ((options is int) || (options is double)) {
      var optionsVal = options;
      options = new Map();
      options['arrayMode'] = optionsVal;
    } else if (options is Map || options is List) {
      Map opt = new Map(); // Yet to check when options can be List
      opt.addAll(options);
      options = opt;
    } else {
      options = new Map();
      options['arrayMode'] = ResultSet.DEFAULT_ARRAY_LENGTH;
    }
    Stream resStream = _createReadStream(options);
    ResultSetTransform rsTransform = new ResultSetTransform(this, _metadata);
    return resStream.transform(rsTransform.streamTransformer);
  }
    
  Stream _createReadStream([options = null]) { //util.createReadStream in nodejs connector    
    resume() {
      if (_running || _finished) {
        return;
      }
      _running = true;
      
      if (_data != null) {
        _handleData(_data);
        _data = null;
      } else {
        _sendFetch();
      }
    }
    
    pause() {
      _running = false;
    }
    
    streamController = new StreamController(
        onResume: resume,
        onPause: pause,
        onListen: resume
    );
    return streamController.stream;
  }
  
  List getLobColumnNames() {
    List<Column> columns = new List.from(_metadata, growable: true);
    columns.removeWhere((column) => !Lob.isLobType(column));
    columns.forEach((col) => col.columnDisplayName);
    return columns;
  }
  
  Lob createLob(LobDescriptor ld, {Map options}) {
    if (options == null) {
      options = new Map();
    }
    options['readSize'] = _readSize;
    return new Lob(sendReadLob, ld, options);
  }
  
  void _handleData(ReplyPart data) {
    if (data.argumentCount > 0 && data.buffer is Uint8List) {
      streamController.add(data.buffer);
    }

    if (isLast(data)) {
      _finished = true;
      _running = false;
      _closed = isClosed(data);
      streamController.close();
      return;
    }

    if (_running) {
      _sendFetch();
    }
  }
  
  bool isLast(ReplyPart data) {
    return (data.attributes & ResultSetAttributes.LAST.value > 0);
  }

  bool isClosed(ReplyPart data) {
    return (data.attributes & ResultSetAttributes.CLOSED.value > 0);
  }
  
  void _sendFetch() {
    _connection.fetchNext(receiveData, {
      'resultSetId': _id,
      'fetchSize': _fetchSize
    });
  }
  
  void receiveData(reply) {
    if (reply is Error) {
      _running = false;
      streamController.addError(reply);
      return;
    } else {
      ReplyPart data = reply.resultSets[0]['data'];
      if (_running) {
        _handleData(data);
      } else {
        _data = data;
      }
    }
  }
  
  void sendReadLob(Map req, Function cb) {
    _connection.readLob(cb, req);
  }
  
  void close() {
   _closed = true;
  }
  
  Future collectLobRows(rows) {
    Completer cLobRows = new Completer();
    int i = 0;
    Function handleRow;
    
    next() {
      if (i == rows.length) {
        cLobRows.complete(rows);
        return;
      }
      fetchColumnDataOfRow(rows[i], handleRow);
    }
    
    handleRow = ([error]) {
      if (error is Error) {
        return cLobRows.completeError(error);
      }
      i += 1;
      next();
    };
    
    next();
    return cLobRows.future;
  }
  
  fetchColumnDataOfRow(row, Function cbFunc) {
    int i = 0;
    Function receiveColData;
    
    next() {
      if (i == _metadata.length){
        return cbFunc();
      }
      
      var lob = row[_metadata[i].columnDisplayName];
      if (lob is! Lob) {
        return receiveColData(lob);
      }
      Future fReadLob = lob.read();
      fReadLob.then((lobData) {
        receiveColData(lobData);
      }, onError: (Error err) {
        receiveColData(err);
      });
    }
    
    receiveColData = (result) {
      if (result is Error) {
        return cbFunc(result);
      }
      row[_metadata[i].columnDisplayName] = result;
      i += 1;
      next();
    };
    
    next();
  }
  
}
