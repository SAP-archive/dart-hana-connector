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

library protocol.common.segment_kind;

class SegmentKind {
  final int index;
  final String _name;
  const SegmentKind(this.index, this._name);
  String toString() => '$SegmentKind.$_name';
  
  static const SegmentKind INVALID = const SegmentKind(0, 'INVALID');
  static const SegmentKind REQUEST = const SegmentKind(1, 'REQUEST');
  static const SegmentKind REPLY = const SegmentKind(2, 'REPLY');
  static const SegmentKind ERROR = const SegmentKind(5, 'ERROR');
  
  static const List<SegmentKind> values = const <SegmentKind>[INVALID, REQUEST, REPLY, null, null, ERROR];
}