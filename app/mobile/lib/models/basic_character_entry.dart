/// 기초 문자표 3열 구역 — 일본어 あ행·か行 등 행 단위 묶음.
class BasicCharacterLocalizedSection {
  const BasicCharacterLocalizedSection({
    required this.sectionId,
    required this.rows,
  });

  /// `a` | `ka` | `sa` | … | `n` — chart screen i18n 키와 매핑.
  final String sectionId;
  final List<BasicCharacterLocalizedRow> rows;
}


/// 기초 문자표 3열 행 — 문자 · UI 로케일별 발음 · 예시(단어+뜻).
class BasicCharacterLocalizedRow {
  const BasicCharacterLocalizedRow({
    required this.character,
    required this.pronunciationKo,
    required this.pronunciationEn,
    required this.pronunciationJa,
    required this.exampleWord,
    required this.exampleGlossKo,
    required this.exampleGlossEn,
    required this.exampleGlossJa,
  });

  final String character;
  final String pronunciationKo;
  final String pronunciationEn;
  final String pronunciationJa;
  final String exampleWord;
  final String exampleGlossKo;
  final String exampleGlossEn;
  final String exampleGlossJa;
}


/// 기초 문자표 한 행 — 문자 · 발음 · 표기법(레거시, 신규 표는 [BasicCharacterLocalizedRow]).
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
    this.localizedRows = const [],
    this.localizedSections = const [],
  });

  final String id;
  final List<BasicCharacterEntry> entries;

  /// 한국어(가나다)만 사용 — [entries]는 비움.
  final List<BasicCharacterChartSection>? koreanSections;

  /// 문자 · 발음 · 예시 3열 표(영어·유럽어 등 — 단일 표).
  final List<BasicCharacterLocalizedRow> localizedRows;

  /// 일본어 가나 등 행 단위 구역이 있는 3열 표.
  final List<BasicCharacterLocalizedSection> localizedSections;

  bool get usesLocalizedTable =>
      localizedRows.isNotEmpty || localizedSections.isNotEmpty;
}
