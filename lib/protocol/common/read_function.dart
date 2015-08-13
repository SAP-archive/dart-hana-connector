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

library protocol.common.read_function;

import "package:Connector/protocol/common/type_code.dart";

class ReadFunction {
  static const String READ_TINYINT = 'readTinyInt';
  static const String READ_SMALLINT = 'readSmallInt';
  static const String READ_INT = 'readInt';
  static const String READ_BIGINT = 'readBigInt';
  static const String READ_STRING = 'readString';
  static const String READ_BINARY = 'readBinary';
  static const String READ_DATE = 'readDate';
  static const String READ_DAYDATE = 'readDayDate';
  static const String READ_TIME = 'readTime';
  static const String READ_SECONDTIME = 'readSecondTime';
  static const String READ_TIMESTAMP = 'readTimestamp';
  static const String READ_LONGDATE = 'readLongDate';
  static const String READ_SECONDDATE = 'readSecondDate';
  static const String READ_BLOB = 'readBLob';
  static const String READ_CLOB = 'readCLob';
  static const String READ_NCLOB = 'readNCLob';
  static const String READ_DOUBLE = 'readDouble';
  static const String READ_FLOAT = 'readFloat';
  static const String READ_DECIMAL = 'readDecimal';
  
  Map<int, String> readFunc= new Map<int, String>();
  static final ReadFunction inst = new ReadFunction();

  ReadFunction() {
    readFunc[TypeCode.TINYINT.index] = READ_TINYINT;
    readFunc[TypeCode.SMALLINT.index] = READ_SMALLINT;
    readFunc[TypeCode.INT.index] = READ_INT;
    readFunc[TypeCode.BIGINT.index] = READ_BIGINT;
    readFunc[TypeCode.STRING.index] = READ_STRING;
    readFunc[TypeCode.VARCHAR1.index] = READ_STRING;
    readFunc[TypeCode.VARCHAR2.index] = READ_STRING;
    readFunc[TypeCode.CHAR.index] = READ_STRING;
    readFunc[TypeCode.NCHAR.index] = READ_STRING;
    readFunc[TypeCode.NVARCHAR.index] = READ_STRING;
    readFunc[TypeCode.NSTRING.index] = READ_STRING;
    readFunc[TypeCode.SHORTTEXT.index] = READ_STRING;
    readFunc[TypeCode.ALPHANUM.index] = READ_STRING;
    readFunc[TypeCode.BINARY.index] = READ_BINARY;
    readFunc[TypeCode.VARBINARY.index] = READ_BINARY;
    readFunc[TypeCode.BSTRING.index] = READ_BINARY;
    readFunc[TypeCode.DATE.index] = READ_DATE;
    readFunc[TypeCode.TIME.index] = READ_TIME;
    readFunc[TypeCode.TIMESTAMP.index] = READ_TIMESTAMP;
    readFunc[TypeCode.DAYDATE.index] = READ_DAYDATE;
    readFunc[TypeCode.SECONDTIME.index] = READ_SECONDTIME;
    readFunc[TypeCode.LONGDATE.index] = READ_LONGDATE;
    readFunc[TypeCode.SECONDDATE.index] = READ_SECONDDATE;
    readFunc[TypeCode.BLOB.index] = READ_BLOB;
    readFunc[TypeCode.LOCATOR.index] = READ_BLOB;
    readFunc[TypeCode.CLOB.index] = READ_CLOB;
    readFunc[TypeCode.NCLOB.index] = READ_NCLOB;
    readFunc[TypeCode.NLOCATOR.index] = READ_NCLOB;
    readFunc[TypeCode.TEXT.index] = READ_NCLOB;
    readFunc[TypeCode.DOUBLE.index] = READ_DOUBLE;
    readFunc[TypeCode.REAL.index] = READ_FLOAT;
    readFunc[TypeCode.DECIMAL.index] = READ_DECIMAL;
  }
   
}
