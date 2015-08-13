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

library protocol.statement;

import 'dart:async';
import 'package:Connector/protocol/common/function_code.dart';
import 'package:Connector/protocol/connection/connection.dart';
import 'package:Connector/protocol/data/parameter_metadata.dart';
import 'package:Connector/protocol/reply/reply.dart';
import 'package:Connector/protocol/result/result.dart';


class Statement {
  var _id;
  int _functionCode = FunctionCode.NIL.index;
  List<Parameter> _parameterMetadata;
  var _resultSetMetadata;
  bool _dropped;
  Connection _connection;

  Statement(this._connection);

  Statement handle(Reply reply) {
    _id = reply.attributes['statementId'];
    _functionCode = reply.functionCode;
    
    if (reply.resultSets is List && reply.resultSets.length > 0) {
      _resultSetMetadata = reply.resultSets[0]['metadata'];
    }
    _parameterMetadata = reply.attributes['parameterMetadata'];
    return this;
  }

  Future exec(var values, {Map options, bool fetchResultForStreaming: false}) {
    Completer cExec = new Completer();
    Map defaults = {
      'autoFetch': !fetchResultForStreaming
    };
    executeStatement(cExec, defaults, values, options: options);
    return cExec.future;
  }

  void executeStatement(Completer cExec, Map defaults, var values, {Map options}) {
    if (options != null && options is Map) {
      options.addAll(defaults);
    } else {
      options = defaults;
      options['autoFetch'] = true;
    }

    var result = new Result(_connection, options);
    result.resultSetMetadata = _resultSetMetadata;
    List<Parameter> paramMetadataList = new List<Parameter>();
    for (Parameter p in _parameterMetadata) {
      if (p.isOutputParameter()) {
        paramMetadataList.add(p);
      }
    }
    result.parameterMetadata = paramMetadataList;
    
    void onExecuteStatementCallback(reply) {
      if (reply is Error) {
        cExec.completeError(reply);
      } else {
        Future resFuture = result.handle(reply);
        resFuture.then((rows) {
          cExec.complete(rows);
        },
        onError: (Error e){
          cExec.completeError(e);
        });
      }
    }
    
    try {
      _connection.execute(onExecuteStatementCallback, {
        'functionCode': _functionCode,
        'statementId': _id,
        'parameters': _normalizeParameters(values)
      });
    } catch(err) {
      return cExec.completeError(err);
    }
  }

  _normalizeParameters(var values) {
    List<Parameter> inputParameterMetadata = new List<Parameter>();
    for (Parameter p in _parameterMetadata) {
      if (p.isInputParameter()) {
        inputParameterMetadata.add(p);
      }
    }
    
    if (inputParameterMetadata.length == 0) {
      return null;
    }
    
    getDataType(Parameter metadata) {
      return metadata.dataType;
    }

    getObjectValue(Parameter metadata) {
      return (values.containsKey(metadata.name)) ? values[metadata.name] : null;
    }

    Map parameters = {
      'types': new List.generate(inputParameterMetadata.length, 
          (int index) => getDataType(inputParameterMetadata[index])),
      'values': null
    };
    
    if (values is List) {
      if (values.length == 0) {
         throw new StateError('Invalid input parameter values');
      }

      parameters['values'] = values;
      return parameters;
    } else if (values is Map) {
      parameters['values'] = new List.generate(inputParameterMetadata.length, 
              (int index) => getObjectValue(inputParameterMetadata[index]));
      return parameters;
    } else {
      parameters['values'] = [values];
      return parameters;
    }
  }
  
  Future drop() {
    Completer cExec = new Completer();
    Map options = {'statementId': _id};
    _connection.dropStatement(cExec, options);
    return cExec.future;
  }
}
