/// 기초 문자표 한 행 — 문자 · 발음 · 표기법(영어·한국어 표는 일부 열 미사용).
class BasicCharacterEntry {
  const BasicCharacterEntry({
    required this.character,
    this.pronunciation = '',
    this.orthography = '',
  });

  final String character;
  final String pronunciation;
  final String orthography;
}

/// 한국어 표: 자음 / 모음 / 음절(가나다) 등 구역 제목 + 문자 목록.
class BasicCharacterChartSection {
  const BasicCharacterChartSection({
    required this.sectionId,
    required this.characters,
  });

  /// `kor_consonants` | `kor_vowels` | `kor_syllables` — i18n 키 접두와 매핑.
  final String sectionId;
  final List<String> characters;
}

/// 드롭다운에 노출할 문자표 종류(고정 목록).
class BasicCharacterChartOption {
  const BasicCharacterChartOption({
    required this.id,
    this.entries = const [],
    this.koreanSections,
  });

  final String id;
  final List<BasicCharacterEntry> entries;

  /// 한국어(가나다)만 사용 — [entries]는 비움.
  final List<BasicCharacterChartSection>? koreanSections;
}
