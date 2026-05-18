import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/basic_character_kor_combine.dart';

void main() {
  test('syllable combines ㄱ and ㅏ to 가', () {
    expect(BasicCharacterKorCombine.syllable('ㄱ', 'ㅏ'), '가');
  });

  test('syllable returns null for invalid jamo', () {
    expect(BasicCharacterKorCombine.syllable('?', 'ㅏ'), isNull);
  });
}
