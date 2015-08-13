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

library cesu8_coding;
import 'dart:convert';

int bmpLowerLimit = 0x00;
int bmpUpperLimit = 0x10000;

int surrogateMin = 0xD800;
int surrogateMax = 0xDFFF;

int pre0 = 0x00; //0000 0000
int pre1 = 0x80; //1000 0000
int pre2 = 0xC0; //1100 0000
int pre3 = 0xE0; //1110 0000
int pre4 = 0xF0; //1111 0000

int mask2 = 0x3F; //0011 1111
int mask3 = 0x1F; //0001 1111
int mask4 = 0x0F; //0000 1111

String runeError = '\uFFFD';

int rune1Max = 0x7F;
int rune2Max = 0x7FF;

List<int> encodeToCESU8(String str) {
  List<int> runes = str.runes.toList();
  List<int> codePoints = str.codeUnits;
  int codePointCounter = 0;
  List<int> cesu8Encoding = new List<int>.from([], growable: true);

  for (int i = 0; i < runes.length; i++) {
    if (runes[i] >= bmpLowerLimit && runes[i] <= bmpUpperLimit) {
      cesu8Encoding.addAll(UTF8.encode(str.substring(codePointCounter, codePointCounter + 1)));
      codePointCounter++;
    } else {
      cesu8Encoding.addAll(encodeSurrogate(codePoints[codePointCounter]));
      cesu8Encoding.addAll(encodeSurrogate(codePoints[codePointCounter + 1]));
      codePointCounter = codePointCounter + 2;
    }
  }
  return cesu8Encoding;
}

String decodeCESU8(List<int> cesu8Val) {
  String decodedString = new String.fromCharCodes([]);
  List<int> cesu8Copy = new List<int>.from(cesu8Val, growable: true);
  int readIndex = 0;
  int writeIndex = 0;
  int diffLength = 0;

  while (cesu8Copy.length > 0) {
    Map decodedRuneResult = decodeRuneFromCESU8(cesu8Copy);
    int runeSize = decodedRuneResult['size'];
    if (decodedRuneResult['rune'] == runeError) {
      //TODO: Handle Error case
      return null; //TODO: Change later
    }

    if (decodedRuneResult['isSurrogate']) {
      List cesu8TmpCopy = cesu8Copy.sublist(runeSize);
      Map decodedRune2Result = decodeRuneFromCESU8(cesu8TmpCopy);
      if (decodedRune2Result['rune'] == runeError || !decodedRuneResult['isSurrogate']) {
        //TODO: Handle Error case
        return null; //TODO: Change later
      }
      decodedString += new String.fromCharCodes([decodedRuneResult['rune'], decodedRune2Result['rune']]);
      cesu8TmpCopy.removeRange(0, 3);
      cesu8Copy = cesu8TmpCopy;
    } else {
      decodedString += UTF8.decode(cesu8Copy.sublist(0, runeSize));
      cesu8Copy.removeRange(0, runeSize);
    }
  }
  return decodedString;
}

List<int> encodeSurrogate(int surrogate) {
  List<int> cesuEncodedSurrogate = new List<int>(3);

  if (surrogate >= surrogateMin && surrogate <= surrogateMax) {
    cesuEncodedSurrogate[0] = pre3 | surrogate >> 12;
    cesuEncodedSurrogate[1] = pre1 | surrogate >> 6 & mask2;
    cesuEncodedSurrogate[2] = pre1 | surrogate & mask2;
  } else {
    //TODO: raise error. invalid surrogate, not within limits
  }
  return cesuEncodedSurrogate;
}

Map decodeRuneFromCESU8(List<int> rune) {
  Map result = new Map();
  int resultRune;

  createResult(resultRune, int size, bool isSurrogate) {
    result['rune'] = resultRune;
    result['size'] = size;
    result['isSurrogate'] = isSurrogate;
    return result;
  }

  int len = rune.length;

  if (len < 1) {
    return createResult(runeError, 0, false);
  }

  int byte0 = rune[0];
  if (byte0 < pre1) {
    return createResult(byte0, 1, false);
  }

  if (byte0 < pre2) {
    return createResult(runeError, 1, false);
  }

  if (len < 2) {
    return createResult(runeError, 1, false);
  }

  int byte1 = rune[1];
  if (byte1 < pre1 || byte1 >= pre2) {
    return createResult(runeError, 1, false);
  }

  if (byte0 < pre3) {
    resultRune = (byte0 & mask3) << 6 | (byte1 & mask2);
    if (resultRune <= rune1Max) {
      return createResult(runeError, 1, false);
    }
    return createResult(resultRune, 2, false);
  }

  if (len < 3) {
    return createResult(runeError, 1, false);
  }
  int byte2 = rune[2];
  if (byte2 < pre1 || byte2 >= pre2) {
    return createResult(runeError, 1, false);
  }

  if (byte0 < pre4) {
    resultRune = (byte0 & mask4) << 12 | (byte1 & mask2) << 6 | (byte2 & mask2);
    if (resultRune <= rune2Max) {
      return createResult(runeError, 1, false);
    }

    if (resultRune >= surrogateMin && resultRune <= surrogateMax) {
      return createResult(resultRune, 3, true);
    }
    return createResult(resultRune, 3, false);
  }

  return createResult(runeError, 1, false);
}
