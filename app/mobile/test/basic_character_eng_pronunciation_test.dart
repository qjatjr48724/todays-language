import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/basic_character_eng_pronunciation.dart';

void main() {
  test('English letter pronunciation follows UI locale', () {
    expect(
      BasicCharacterEngPronunciation.forLetter('A', 'ko'),
      '에이',
    );
    expect(
      BasicCharacterEngPronunciation.forLetter('A', 'en'),
      'ay',
    );
    expect(
      BasicCharacterEngPronunciation.forLetter('A', 'ja'),
      'エイ',
    );
    expect(
      BasicCharacterEngPronunciation.forLetter('z', 'ko'),
      '제트',
    );
  });

  test('normalizeUiLanguage maps unsupported to en', () {
    expect(BasicCharacterEngPronunciation.normalizeUiLanguage('fr'), 'en');
    expect(BasicCharacterEngPronunciation.normalizeUiLanguage('ko-KR'), 'ko');
  });
}
