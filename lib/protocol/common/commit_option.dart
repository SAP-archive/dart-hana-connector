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

library protocol.common.commit_option;

class CommitOption {
  final int index;
  final String _name;
  const CommitOption(this.index, this._name);
  String toString() => '$CommitOption.$_name';
  
  static const CommitOption HOLD_CURSORS_OVER_COMMIT = const CommitOption(0, 'HOLD_CURSORS_OVER_COMMIT');
  
  static const List<CommitOption> values = const <CommitOption>[HOLD_CURSORS_OVER_COMMIT];
}
