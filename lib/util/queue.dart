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

library taskQueue;

import 'dart:collection';

class QueueEntry {
  Function _function;
  List _positionalArgs;
  Map<Symbol, dynamic> _namedArgs;
  Function _callbackFunc;
  
  QueueEntry(this._function, this._positionalArgs, this._namedArgs, 
      this._callbackFunc);
}

class TaskQueue {
  Queue<QueueEntry> _tasks = new Queue();
  
  void schedule(Function fn, Function callback, {
    List positionalArgs, 
    Map<Symbol, dynamic> namedArgs}
  ) {
    var taskEntry = new QueueEntry(fn, positionalArgs, namedArgs, callback);
    _tasks.add(taskEntry);
    
    if (_tasks.length == 1) {
      next();
    }
  }
  
  void next() {
    if (!isEmpty) {
      var taskEntry = _tasks.first;
      Function.apply(taskEntry._function, taskEntry._positionalArgs, taskEntry._namedArgs);
    }
  }
  
  void onComplete(reply) {
    QueueEntry taskEntry = _tasks.first;
    if (taskEntry._callbackFunc != null) {
      Function.apply(taskEntry._callbackFunc, [reply]);
    }
    _tasks.removeFirst();
    next();
  }
  
  bool get isEmpty {
    return _tasks.length == 0;
  }
  
  void clear() {
    _tasks.clear();
  }
}