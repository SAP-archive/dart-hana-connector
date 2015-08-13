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

library protocol.request.request;

export 'package:Connector/protocol/request/part.dart';

import "package:Connector/protocol/common/message_type.dart";
import "package:Connector/protocol/common/command_option.dart";
import "package:Connector/protocol/common/part_kind.dart";
import "package:Connector/protocol/request/segment.dart";
import 'package:Connector/protocol/common/commit_option.dart';
import 'package:Connector/protocol/common/type_code.dart';
import 'package:Connector/util/util.dart';

class Request {
  static Segment createSegment(MessageType type, Map options) {
    int commitImmediately = 0;
    int commandOptionsVal = CommandOptionEnum.inst.NIL.value;

    if (type == MessageType.EXECUTE || type == MessageType.EXECUTE_DIRECT) {
      commitImmediately = getCommitImmediately(options, 1);
      commandOptionsVal = getCommandOptions(options);
    } else if (type == MessageType.FETCH_NEXT || type == MessageType.READ_LOB) {
      commitImmediately = getCommitImmediately(options, 1);
    } else if (type == MessageType.PREPARE) {
      commandOptionsVal = getCommandOptions(options);
    }
    Segment segment = new Segment(type, commitImmediately, commandOptionsVal);
    return segment;
  }

  static authenticate(options) {
    Segment segment = createSegment(MessageType.AUTHENTICATE, options);
    segment.add(PartKindEnum.inst.AUTHENTICATION, options['authentication']);
    return segment;
  }

  static connect(Map options) {
    Segment segment = createSegment(MessageType.CONNECT, options);
    segment.add(PartKindEnum.inst.AUTHENTICATION, options['authentication']);
    segment.add(PartKindEnum.inst.CLIENT_ID, options['clientId']);
    segment.add(PartKindEnum.inst.CONNECT_OPTIONS, options['connectOptions']);
    return segment;
  }
  
  static execute(Map options) {
    var segment = createSegment(MessageType.EXECUTE, options);
    segment.add(PartKindEnum.inst.STATEMENT_ID, options['statementId']);
    segment.add(PartKindEnum.inst.PARAMETERS, options['parameters']);
    return segment;
  }

  static disconnect({Map options}) {
    Segment segment = createSegment(MessageType.DISCONNECT, options);
    return segment;
  }
  
  static executeDirect(Map options) {
    Segment segment = createSegment(MessageType.EXECUTE_DIRECT, options);
    segment.add(PartKindEnum.inst.COMMAND, options['command']);
    return segment;
  }
  
  static commit(options) {
    var segment = createSegment(MessageType.COMMIT, options);
    // commitOptions
    addCommitOptions(segment, options);
    return segment;
  }

  static rollback(options) {
    var segment = createSegment(MessageType.ROLLBACK, options);
    // commitOptions
    addCommitOptions(segment, options);
    return segment;
  }

  static addCommitOptions(segment, options) {
    if (options['holdCursorsOverCommit'] != null) {
      var commitOptions = [{
        "name"  : CommitOption.HOLD_CURSORS_OVER_COMMIT.index,
        "type"  : TypeCode.BOOLEAN,
        "value" : true
      }];
      segment.add(PartKindEnum.inst.COMMIT_OPTIONS, commitOptions);
    }
    return segment;
  }
  
  static fetchNext(Map options) {
    Segment segment = createSegment(MessageType.FETCH_NEXT, options);
    segment.add(PartKindEnum.inst.RESULT_SET_ID, options['resultSetId']);
    segment.add(PartKindEnum.inst.FETCH_SIZE, options['fetchSize']);
    return segment;
  }
  
  static prepare(Map options) {
    Segment segment = createSegment(MessageType.PREPARE, options);
    segment.add(PartKindEnum.inst.COMMAND, options['command']);
    return segment;
  }

  static int getCommitImmediately(Map options, int defaultVal) {
    int commitImmediately = defaultVal;
    if (options['autoCommit'] != null) {
      commitImmediately = getBoolValue(options['autoCommit']) ? 1 : 0;
    } else if (options['commitImmediately'] != null) {
      commitImmediately = getBoolValue(options['commitImmediately']) ? 1 : 0;
    }
    return commitImmediately;
  }

  static int getCommandOptions (Map options) {
    int commandOptionsVal = 0;
    if (options['scrollableCursor'] != null) {
      commandOptionsVal |= CommandOptionEnum.inst.SCROLLABLE_CURSOR_ON.value;
    }
    if (options['holdCursorsOverCommit'] != null) {
      commandOptionsVal |= CommandOptionEnum.inst.HOLD_CURSORS_OVER_COMMIT.value;
    }
    return commandOptionsVal;
  }
  
  static readLob(options) {
    Segment segment = createSegment(MessageType.READ_LOB, options);
    segment.add(PartKindEnum.inst.READ_LOB_REQUEST, options['readLobRequest']);
    return segment;
  }
  
  static writeLob(options) {
    Segment segment = createSegment(MessageType.WRITE_LOB, options);  // Check if options might be set to {}
    segment.add(PartKindEnum.inst.WRITE_LOB_REQUEST, options['writeLobRequest']);
    return segment;
  }
  
  static dropStatementId(options) {
    Segment segment = createSegment(MessageType.DROP_STATEMENT_ID, options);
    segment.add(PartKindEnum.inst.STATEMENT_ID, options['statementId']);
    return segment;
  }
  
  
}
