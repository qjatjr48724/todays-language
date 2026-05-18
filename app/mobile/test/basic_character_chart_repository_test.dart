import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/basic_character_chart_repository.dart';
import 'package:mobile/services/basic_character_kor_pronunciation.dart';

void main() {
  test('allChartsOrdered has seven options in fixed order', () {
    final ids =
        BasicCharacterChartRepository.allChartsOrdered.map((e) => e.id).toList();
    expect(ids.length, 7);
    expect(ids.first, BasicCharacterChartRepository.chartKorGanada);
  });

  test('entries have character, pronunciation, orthography', () {
    final eng = BasicCharacterChartRepository.optionById(
      BasicCharacterChartRepository.chartEngAlphabet,
    );
    expect(eng, isNotNull);
    expect(eng!.entries.first.character, 'A');
    expect(eng.entries.first.pronunciation, isNotEmpty);
  });

  test('Korean chart uses three sections: consonants, vowels, syllables', () {
    final kor = BasicCharacterChartRepository.optionById(
      BasicCharacterChartRepository.chartKorGanada,
    );
    expect(kor?.koreanSections?.length, 3);
    expect(kor?.koreanSections?.first.characters.first, 'ㄱ');
    expect(kor?.koreanSections?[2].characters.first, '가');
  });

  test('koreanConsonants and koreanVowels extract jamo lists', () {
    final kor = BasicCharacterChartRepository.optionById(
      BasicCharacterChartRepository.chartKorGanada,
    )!;
    final sections = kor.koreanSections!;
    expect(
      BasicCharacterChartRepository.koreanConsonants(sections).first,
      'ㄱ',
    );
    expect(
      BasicCharacterChartRepository.koreanVowels(sections).first,
      'ㅏ',
    );
  });

  test('Korean pronunciation follows UI locale (en vs ja)', () {
    expect(
      BasicCharacterKorPronunciation.forCharacter('ㄱ', 'en'),
      'g / k',
    );
    expect(
      BasicCharacterKorPronunciation.forCharacter('ㄱ', 'ja'),
      contains('カ行'),
    );
    expect(
      BasicCharacterKorPronunciation.forCharacter('ㄱ', 'ko'),
      contains('기역'),
    );
  });

  test('normalizeUiLanguage maps unsupported to en', () {
    expect(BasicCharacterKorPronunciation.normalizeUiLanguage('fr'), 'en');
    expect(BasicCharacterKorPronunciation.normalizeUiLanguage('ko-KR'), 'ko');
  });
}
