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

library protocol.common.type_code;

class TypeCode {
  final int index;
  final String _name;
  const TypeCode(this.index, this._name);
  String toString() => '$TypeCode.$_name';
  
  static const TypeCode NULL = const TypeCode(0,'NULL');
  static const TypeCode TINYINT = const TypeCode(1,'TINYINT');
  static const TypeCode SMALLINT = const TypeCode(2,'SMALLINT');
  static const TypeCode INT = const TypeCode(3,'INT');
  static const TypeCode BIGINT = const TypeCode(4,'BIGINT');
  static const TypeCode DECIMAL = const TypeCode(5,'DECIMAL');
  static const TypeCode REAL = const TypeCode(6,'REAL');
  static const TypeCode DOUBLE = const TypeCode(7,'DOUBLE');
  static const TypeCode CHAR = const TypeCode(8,'CHAR');
  static const TypeCode VARCHAR1 = const TypeCode(9,'VARCHAR1');
  static const TypeCode NCHAR = const TypeCode(10,'NCHAR');
  static const TypeCode NVARCHAR = const TypeCode(11,'NVARCHAR');
  static const TypeCode BINARY = const TypeCode(12,'BINARY');
  static const TypeCode VARBINARY = const TypeCode(13,'VARBINARY');
  static const TypeCode DATE = const TypeCode(14,'DATE');
  static const TypeCode TIME = const TypeCode(15,'TIME');
  static const TypeCode TIMESTAMP = const TypeCode(16,'TIMESTAMP');
  static const TypeCode TIME_TZ = const TypeCode(17,'TIME_TZ');
  static const TypeCode TIME_LTZ = const TypeCode(18,'TIME_LTZ');
  static const TypeCode TIMESTAMP_TZ = const TypeCode(19,'TIMESTAMP_TZ');
  static const TypeCode TIMESTAMP_LTZ = const TypeCode(20,'TIMESTAMP_LTZ');
  static const TypeCode INTERVAL_YM = const TypeCode(21,'INTERVAL_YM');
  static const TypeCode INTERVAL_DS = const TypeCode(22,'INTERVAL_DS');
  static const TypeCode ROWID = const TypeCode(23,'ROWID');
  static const TypeCode UROWID = const TypeCode(24,'UROWID');
  static const TypeCode CLOB = const TypeCode(25,'CLOB');
  static const TypeCode NCLOB = const TypeCode(26,'NCLOB');
  static const TypeCode BLOB = const TypeCode(27,'BLOB');
  static const TypeCode BOOLEAN = const TypeCode(28,'BOOLEAN');
  static const TypeCode STRING = const TypeCode(29,'STRING');
  static const TypeCode NSTRING = const TypeCode(30,'NSTRING');
  static const TypeCode LOCATOR = const TypeCode(31,'LOCATOR');
  static const TypeCode NLOCATOR = const TypeCode(32,'NLOCATOR');
  static const TypeCode BSTRING = const TypeCode(33,'BSTRING');
  static const TypeCode DECIMAL_DIGIT_ARRAY = const TypeCode(34,'DECIMAL_DIGIT_ARRAY');
  static const TypeCode VARCHAR2 = const TypeCode(35,'VARCHAR2');
  static const TypeCode UNUSED1 = const TypeCode(36,'UNUSED1');
  static const TypeCode UNUSED2 = const TypeCode(37,'UNUSED2');
  static const TypeCode UNUSED3 = const TypeCode(38,'UNUSED3');
  static const TypeCode UNUSED4 = const TypeCode(39,'UNUSED4');
  static const TypeCode UNUSED5 = const TypeCode(40,'UNUSED5');
  static const TypeCode UNUSED6 = const TypeCode(41,'UNUSED6');
  static const TypeCode UNUSED7 = const TypeCode(42,'UNUSED7');
  static const TypeCode UNUSED8 = const TypeCode(43,'UNUSED8');
  static const TypeCode UNUSED9 = const TypeCode(44,'UNUSED9');
  static const TypeCode TABLE = const TypeCode(45,'TABLE');
  static const TypeCode UNUSED11 = const TypeCode(46,'UNUSED11');
  static const TypeCode UNUSED1F = const TypeCode(47,'UNUSED1F');
  static const TypeCode ABAPSTREAM = const TypeCode(48,'ABAPSTREAM');
  static const TypeCode ABAPSTRUCT = const TypeCode(49,'ABAPSTRUCT');
  static const TypeCode UNUSED12 = const TypeCode(50,'UNUSED12');
  static const TypeCode TEXT = const TypeCode(51,'TEXT');
  static const TypeCode SHORTTEXT = const TypeCode(52,'SHORTTEXT');
  static const TypeCode UNUSED15 = const TypeCode(53,'UNUSED15');
  static const TypeCode UNUSED16 = const TypeCode(54,'UNUSED16');
  static const TypeCode ALPHANUM = const TypeCode(55,'ALPHANUM');
  static const TypeCode UNUSED18 = const TypeCode(56,'UNUSED18');
  static const TypeCode UNUSED19 = const TypeCode(57,'UNUSED19');
  static const TypeCode UNUSED20 = const TypeCode(58,'UNUSED20');
  static const TypeCode UNUSED21 = const TypeCode(59,'UNUSED21');
  static const TypeCode UNUSED22 = const TypeCode(60,'UNUSED22');
  static const TypeCode LONGDATE = const TypeCode(61,'LONGDATE');
  static const TypeCode SECONDDATE = const TypeCode(62,'SECONDDATE');
  static const TypeCode DAYDATE = const TypeCode(63,'DAYDATE');
  static const TypeCode SECONDTIME = const TypeCode(64,'SECONDTIME');
  static const TypeCode CSDATE = const TypeCode(65,'CSDATE');
  static const TypeCode CSTIME = const TypeCode(66,'CSTIME');
  static const TypeCode BLOB_DISK = const TypeCode(71,'BLOB_DISK');
  static const TypeCode CLOB_DISK = const TypeCode(72,'CLOB_DISK');
  static const TypeCode NCLOB_DISK = const TypeCode(73,'NCLOB_DISK');
  
  static const List<TypeCode> values = const <TypeCode>[NULL, TINYINT, SMALLINT, INT, BIGINT, DECIMAL, REAL, DOUBLE, CHAR, VARCHAR1, NCHAR, NVARCHAR, BINARY, VARBINARY, DATE, TIME, TIMESTAMP, TIME_TZ, TIME_LTZ, TIMESTAMP_TZ, TIMESTAMP_LTZ, INTERVAL_YM, INTERVAL_DS, ROWID, UROWID, CLOB, NCLOB, BLOB, BOOLEAN, STRING, NSTRING, LOCATOR, NLOCATOR, BSTRING, DECIMAL_DIGIT_ARRAY, VARCHAR2, UNUSED1, UNUSED2, UNUSED3, UNUSED4, UNUSED5, UNUSED6, UNUSED7, UNUSED8, UNUSED9, TABLE, UNUSED11, UNUSED1F, ABAPSTREAM, ABAPSTRUCT, UNUSED12, TEXT, SHORTTEXT, UNUSED15, UNUSED16, ALPHANUM, UNUSED18, UNUSED19, UNUSED20, UNUSED21, UNUSED22, LONGDATE, SECONDDATE, DAYDATE, SECONDTIME, CSDATE, CSTIME, null, null, null, null, BLOB_DISK, CLOB_DISK, NCLOB_DISK];
  
}