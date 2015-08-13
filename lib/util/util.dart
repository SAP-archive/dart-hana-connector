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

library util;

import "dart:io";
import "dart:math";
import "dart:mirrors";
import "dart:typed_data";
import "package:Connector/util/cesu8_coding.dart";

int alignLength(length, alignment) {
  if (length % alignment == 0) {
    return length;
  }
  return length + alignment - length % alignment;
}

void writeIntLE(List buffer, int num, int byteSize) {
  Uint8List numList = new Uint8List(byteSize);
  ByteData bData = new ByteData.view(numList.buffer);
  if (byteSize == 2) {
    bData.setUint16(0, num, Endianness.LITTLE_ENDIAN);
  } else if (byteSize == 4) {
    bData.setUint32(0, num, Endianness.LITTLE_ENDIAN);
  } else if (byteSize == 8) {
    bData.setUint64(0, num, Endianness.LITTLE_ENDIAN);
  }
  buffer.addAll(numList);
}

void writeInt64LE(List buffer, int num) {
  writeIntLE(buffer, num, 8);
}

void writeInt32LE(List buffer, int num) {
  writeIntLE(buffer, num, 4);
}

void writeInt16LE(List buffer, int num) {
  writeIntLE(buffer, num, 2);
}

void writeFloatDoubleLE(List buffer, double num, int byteSize) {
  Uint8List numList = new Uint8List(byteSize);
  ByteData bData = new ByteData.view(numList.buffer);
  if (byteSize == 4) {
    bData.setFloat32(0, num, Endianness.LITTLE_ENDIAN);
  } else if (byteSize == 8) {
    bData.setFloat64(0, num, Endianness.LITTLE_ENDIAN);
  }
  buffer.addAll(numList);
}

void writeFloatLE(List buffer, double num) {
  writeFloatDoubleLE(buffer, num, 4);
}

void writeDoubleLE(List buffer, double num) {
  writeFloatDoubleLE(buffer, num, 8);
}

String readString(Uint8List buffer, int offset, int endOffset) {
  return new String.fromCharCodes(buffer.sublist(offset, endOffset));
}

int readUInt16LE(Uint8List buffer, int offset) {
  return new ByteData.view(buffer.buffer).getUint16(offset,
      Endianness.LITTLE_ENDIAN);
}

int readInt16LE(Uint8List buffer, int offset) {
  return new ByteData.view(buffer.buffer).getInt16(offset,
      Endianness.LITTLE_ENDIAN);
}

int readUInt32LE(Uint8List buffer, int offset) {
  return new ByteData.view(buffer.buffer).getUint32(offset,
      Endianness.LITTLE_ENDIAN);
}

int readInt32LE(Uint8List buffer, int offset) {
  return new ByteData.view(buffer.buffer).getInt32(offset,
      Endianness.LITTLE_ENDIAN);
}

int readUInt64LE(Uint8List buffer, int offset) {
  return new ByteData.view(buffer.buffer).getUint64(offset,
      Endianness.LITTLE_ENDIAN);
}

int readInt64LE(Uint8List buffer, int offset) {
  return new ByteData.view(buffer.buffer).getInt64(offset,
      Endianness.LITTLE_ENDIAN);
}

double readFloatLE(Uint8List buffer, int offset) {
  return new ByteData.view(buffer.buffer).getFloat32(offset,
      Endianness.LITTLE_ENDIAN);
}

double readDoubleLE(Uint8List buffer, int offset) {
  return new ByteData.view(buffer.buffer).getFloat64(offset,
      Endianness.LITTLE_ENDIAN);
}

int BASE = pow(10, 7);
int EXP_BIAS = 6176;
int INT_2_21 = pow(2, 21);
int INT_2_32 = pow(2, 32);

int INT_2_32_0 = 4967296;
int INT_2_32_1 = 429;

int INT_2_64_0 = 9551616;
int INT_2_64_1 = 4407370;
int INT_2_64_2 = 184467;

int INT_2_53_0 = 4740992;
int INT_2_53_1 = 719925;
int INT_2_53_2 = 90;

Map readDec128(buffer, [int offset = 0]) {

  var i, j, k, l, z0, z1, y0, y1, y2, x0, x1, x2, x3, x4;

  if ((buffer[offset + 15] & 0x70) == 0x70) {
    return null;
  }

  i = buffer[offset + 2] << 16;
  i |= buffer[offset + 1] << 8;
  i |= buffer[offset];
  i += modulo((buffer[offset + 3] << 24), pow(2, 32));
  offset += 4;

  j = buffer[offset + 2] << 16;
  j |= buffer[offset + 1] << 8;
  j |= buffer[offset];
  j += modulo((buffer[offset + 3] << 24), pow(2, 32));
  offset += 4;

  k = buffer[offset + 2] << 16;
  k |= buffer[offset + 1] << 8;
  k |= buffer[offset];
  k += modulo((buffer[offset + 3] << 24), pow(2, 32));
  offset += 4;

  l = (buffer[offset + 2] & 0x01) << 16;
  l |= buffer[offset + 1] << 8;
  l |= buffer[offset];
  offset += 2;

  var dec = {
    's': (buffer[offset + 1] & 0x80 != 0) ? -1 : 1,
    'm': null,
    'e': ((((buffer[offset + 1] << 8) | buffer[offset]) & 0x7ffe) >> 1) -
        EXP_BIAS
  };

  if (k == 0 && l == 0) {
    if (j == 0) {
      dec['m'] = i;
      return dec;
    }
    if (j < INT_2_21 || (j == INT_2_21 && i == 0)) {
      dec['m'] = j * INT_2_32 + i;
      return dec;
    }
  }

  if (i < BASE) {
    x0 = i;
    x1 = 0;
  } else {
    x0 = i % BASE;
    x1 = (i / BASE).floor();
  }

  if (j < BASE) {
    x0 += j * INT_2_32_0;
    x1 += j * INT_2_32_1;
    x2 = 0;
  } else {
    z0 = j % BASE;
    z1 = (j / BASE).floor();
    x0 += z0 * INT_2_32_0;
    x1 += z0 * INT_2_32_1 + z1 * INT_2_32_0;
    x2 = z1 * INT_2_32_1;
  }

  if (k < BASE) {
    y0 = k;
    y1 = 0;
  } else {
    y0 = k % BASE;
    y1 = (k / BASE).floor();
  }

  if (l < BASE) {
    y0 += l * INT_2_32_0;
    y1 += l * INT_2_32_1;
    y2 = 0;
  } else {
    z0 = l % BASE;
    z1 = (l / BASE).floor();
    y0 += z0 * INT_2_32_0;
    y1 += z0 * INT_2_32_1 + z1 * INT_2_32_0;
    y2 = z1 * INT_2_32_1;
  }

  if (y0 >= BASE) {
    y1 += (y0 / BASE).floor();
    y0 %= BASE;
  }
  if (y1 >= BASE) {
    y2 += (y1 / BASE).floor();
    y1 %= BASE;
  }

  x0 += y0 * INT_2_64_0;
  x1 += y0 * INT_2_64_1 + y1 * INT_2_64_0;
  x2 += y0 * INT_2_64_2 + y1 * INT_2_64_1 + y2 * INT_2_64_0;
  x3 = y1 * INT_2_64_2 + y2 * INT_2_64_1;
  x4 = y2 * INT_2_64_2;

  if (x0 >= BASE) {
    x1 += (x0 / BASE).floor();
    x0 %= BASE;
  }
  if (x1 >= BASE) {
    x2 += (x1 / BASE).floor();
    x1 %= BASE;
  }
  if (x2 >= BASE) {
    x3 += (x2 / BASE).floor();
    x2 %= BASE;
  }
  if (x3 >= BASE) {
    x4 += (x3 / BASE).floor();
    x3 %= BASE;
  }

  if (x4 != 0) {
    dec['m'] = '' + intToString(x4, pad: 14) + intToString(x3 * BASE + x2, pad: 14) + intToString(x1 *
        BASE + x0, pad: 14);
    return dec;
  }
  if (x3 != 0) {
    dec['m'] = '' + intToString((x3 * BASE + x2), pad: 14) + intToString(x1 * BASE + x0, pad: 14);
    return dec;
  }
  if (x2 != 0) {
    if (x2 < INT_2_53_2 || (x2 == INT_2_53_2 && (x1 < INT_2_53_1 || (x1 ==
        INT_2_53_1 && x0 <= INT_2_53_0)))) {
      dec['m'] = intToString(((x2 * BASE + x1) * BASE), pad: 14) + intToString(x0, pad: 14);
      return dec;
    }
    dec['m'] = '' + intToString(x2, pad: 14) + intToString(x1 * BASE + x0, pad: 14);
    return dec;
  }
  dec['m'] = intToString((x1 * BASE + x0), pad: 14);
  return dec;
}

int modulo(int a, int b) {
  return a - (a / b).floor() * b;
}

double readDecFloat(buffer, offset) {
  Map value = readDec128(buffer, offset);
  if (value == null) {
    return null;
  }
  var d, l, e;
  d = '' + value['m'].toString();
  l = d.length;
  e = value['e'] + l - 1;
  if (e < 0) {
    e = 'e' + e.toString();
  } else {
    e = 'e+' + e.toString();
  }
  while (d.codeUnitAt(l - 1) == 48) {
    l -= 1;
  }
  if (l > 1) {
    d = d.substring(0, 1) + '.' + d.substring(1, l);
  }
  if (value['s'] < 0) {
    return double.parse('-' + d + e);
  }
  return double.parse(d + e);
}

double readDecFixed(buffer, int offset, [int frac = 0]) {
  Map value = readDec128(buffer, offset);
  if (value == null) {
    return null;
  }
  var d, e, l, k, i, f;
  d = '' + value['m'].toString();
  e = value['e'];
  if (e < 0) {
    l = d.length;
    k = l + e;
    if (k > 0) {
      i = d.substring(0, k);
      f = d.substring(k);
    } else if (k < 0) {
      i = '0';
      f = intToString(d, pad: -k);
    } else {
      i = '0';
      f = d;
    }
  } else if (e > 0) {
    i = d + intToString(e, pad: e);
    f = '';
  } else {
    i = d;
    f = '';
  }
  if (value['s'] < 0) {
    i = '-' + i;
  }
  if (frac == 0) {
    return double.parse(i);
  }
  l = f.length;
  if (l > frac) {
    f = f.substring(0, frac);
  } else if (l < frac) {
    intToString(f, pad: frac - l);
  }
  return double.parse(i + '.' + f);
}

String intToString(var i, {int pad: 0}) {
  String str = (i is String) ? i : i.toString();
  int paddingToAdd = pad - str.length;
  return (paddingToAdd > 0) ? "${new List.filled(paddingToAdd, '0').join('')}$i"
      : str;
}

String className(instance) {
  InstanceMirror instanceMirror = reflect(instance);
  ClassMirror cm = instanceMirror.type;
  String name = MirrorSystem.getName(cm.simpleName);
  return (name.substring(0, 1) == '_') ? name.substring(1) : name;
}

Uint8List createBuffer(String data) {
  return new Uint8List.fromList(encodeToCESU8(data));
}

String clientId() {
  return 'dart@' + Platform.localHostname;
}

String toCamelCase(String str) {
  List<String> arr = str.split('_');
  String result = arr[0].toLowerCase();

  for (int i = 1; i < arr.length; i++) {
    String s = arr[i];
    result += s.substring(0, 1).toUpperCase() + s.substring(1).toLowerCase();
  }

  return result;
}

bool getBoolValue(var n) {
  if (n != null) {
    if (n is bool) {
      return n;
    } else if (n is int) {
      return n != 0;
    } else {
      return true;
    }
  }
  return false;
}
