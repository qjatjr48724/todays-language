import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/data/basic_character/basic_character_kana_rows.dart';
import 'package:mobile/models/basic_character_entry.dart';
import 'package:mobile/services/basic_character_chart_repository.dart';
import 'package:mobile/services/basic_character_kor_pronunciation.dart';
import 'package:mobile/services/user_profile_sync.dart';

void main() {
  test('allChartsOrdered has four active options (European charts disabled)', () {
    final ids =
        BasicCharacterChartRepository.allChartsOrdered.map((e) => e.id).toList();
    expect(
      BasicCharacterChartRepository.kEuropeanBasicCharacterChartsEnabled,
      isFalse,
    );
    expect(ids.length, 4);
    expect(ids, [
      BasicCharacterChartRepository.chartKorGanada,
      BasicCharacterChartRepository.chartEngAlphabet,
      BasicCharacterChartRepository.chartJpnHiragana,
      BasicCharacterChartRepository.chartJpnKatakana,
    ]);
  });

  test('non-Korean charts use localized 3-column rows', () {
    final eng = BasicCharacterChartRepository.optionById(
      BasicCharacterChartRepository.chartEngAlphabet,
    );
    expect(eng, isNotNull);
    expect(eng!.usesLocalizedTable, isTrue);
    expect(eng.localizedRows.length, 26);
    expect(eng.localizedRows.first.character, 'A');

    final hira = BasicCharacterChartRepository.optionById(
      BasicCharacterChartRepository.chartJpnHiragana,
    );
    expect(hira!.localizedSections.length, 11);
    expect(hira.localizedSections.first.sectionId, 'a');
    expect(hira.localizedSections.first.rows.length, 5);
    expect(hira.localizedSections.last.sectionId, 'n');
    expect(hira.usesJpnKanaTabs, isTrue);
    expect(hira.jpnKanaSectionsByTab.keys, contains('seion'));
    expect(
      hira.jpnKanaSectionsByTab[jpnKanaTabKey(JpnKanaPronunciationTab.dakuon)]
          ?.length,
      4,
    );
    expect(
      hira.jpnKanaSectionsByTab[jpnKanaTabKey(JpnKanaPronunciationTab.handakuon)]
          ?.first
          .sectionId,
      'pa',
    );
    expect(
      hira.jpnKanaSectionsByTab[jpnKanaTabKey(JpnKanaPronunciationTab.youon)]
          ?.length,
      11,
    );
    expect(
      hira.jpnKanaSectionsByTab[jpnKanaTabKey(JpnKanaPronunciationTab.sokuon)]
          ?.first
          .rows
          .length,
      3,
    );
  });

  test('Korean chart uses three sections: consonants, vowels, syllables', () {
    final kor = BasicCharacterChartRepository.optionById(
      BasicCharacterChartRepository.chartKorGanada,
    );
    expect(kor?.koreanSections?.length, 3);
    expect(kor?.usesLocalizedTable, isFalse);
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

  test('localized 3-column row formats pronunciation and example by UI locale', () {
    const row = BasicCharacterLocalizedRow(
      character: 'é',
      pronunciationKo: '에',
      pronunciationEn: 'ay',
      pronunciationJa: 'エ',
      exampleWord: 'été',
      exampleGlossKo: '여름',
      exampleGlossEn: 'summer',
      exampleGlossJa: '夏',
    );

    expect(BasicCharacterKorPronunciation.localizedPronunciationFor(row, 'ko'), '에');
    expect(BasicCharacterKorPronunciation.localizedPronunciationFor(row, 'en'), 'ay');
    expect(BasicCharacterKorPronunciation.localizedExampleFor(row, 'ko'), 'été 여름');
    expect(BasicCharacterKorPronunciation.localizedExampleFor(row, 'en'), 'été (summer)');
    expect(BasicCharacterKorPronunciation.localizedExampleFor(row, 'fr'), 'été (summer)');
  });

  test('isTargetLanguageSelectable allows KOR USA JPN only', () {
    expect(isTargetLanguageSelectable('KOR'), isTrue);
    expect(isTargetLanguageSelectable('usa'), isTrue);
    expect(isTargetLanguageSelectable('JPN'), isTrue);
    expect(isTargetLanguageSelectable('FRA'), isFalse);
    expect(isTargetLanguageSelectable('DEU'), isFalse);
    expect(isTargetLanguageSelectable('CHN'), isFalse);
    expect(isTargetLanguageSelectable('ESP'), isFalse);
    expect(isTargetLanguageSelectable(null), isFalse);
  });
}
