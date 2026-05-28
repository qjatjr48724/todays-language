import '../data/basic_character/basic_character_deu_basic_data.dart';
import '../data/basic_character/basic_character_eng_alphabet_data.dart';
import '../data/basic_character/basic_character_esp_basic_data.dart';
import '../data/basic_character/basic_character_fra_basic_data.dart';
import '../data/basic_character/basic_character_jpn_hiragana_data.dart';
import '../data/basic_character/basic_character_jpn_katakana_data.dart';
import '../data/basic_character/basic_character_kor_ganada_data.dart';
import '../models/basic_character_entry.dart';

/// 기초 문자표 조회 — 정적 데이터는 [lib/data/basic_character/] 언어별 파일.
class BasicCharacterChartRepository {
  const BasicCharacterChartRepository._();

  static const String chartKorGanada = kBasicCharacterChartIdKorGanada;
  static const String chartEngAlphabet = kBasicCharacterChartIdEngAlphabet;
  static const String chartJpnHiragana = kBasicCharacterChartIdJpnHiragana;
  static const String chartJpnKatakana = kBasicCharacterChartIdJpnKatakana;
  static const String chartFra = kBasicCharacterChartIdFraBasic;
  static const String chartDeu = kBasicCharacterChartIdDeuBasic;
  static const String chartEsp = kBasicCharacterChartIdEspBasic;

  /// 화면 드롭다운 순서 — [한국어(가나다), 영어, 일본어 히라가나·가타카나, 프랑스어, 독일어, 스페인어]
  static final List<BasicCharacterChartOption> allChartsOrdered = [
    kBasicCharacterKorGanadaChart,
    kBasicCharacterEngAlphabetChart,
    kBasicCharacterJpnHiraganaChart,
    kBasicCharacterJpnKatakanaChart,
    kBasicCharacterFraBasicChart,
    kBasicCharacterDeuBasicChart,
    kBasicCharacterEspBasicChart,
  ];

  static BasicCharacterChartOption? optionById(String id) {
    for (final o in allChartsOrdered) {
      if (o.id == id) return o;
    }
    return null;
  }

  /// 한국어(가나다) 자음·모음 목록 — [koreanSections]에서 조회.
  static List<String> koreanConsonants(List<BasicCharacterChartSection> sections) {
    return _charsForSection(sections, 'kor_consonants');
  }

  static List<String> koreanVowels(List<BasicCharacterChartSection> sections) {
    return _charsForSection(sections, 'kor_vowels');
  }

  static List<String> _charsForSection(
    List<BasicCharacterChartSection> sections,
    String sectionId,
  ) {
    for (final s in sections) {
      if (s.sectionId == sectionId) return s.characters;
    }
    return const [];
  }
}
