import '../models/basic_character_entry.dart';

/// 기초 문자표 정적 데이터 — 앱 번들. (추후 JSON/Firestore·다국어 셀 텍스트 확장 가능)
class BasicCharacterChartRepository {
  const BasicCharacterChartRepository._();

  static const String chartKorGanada = 'kor_ganada';
  static const String chartEngAlphabet = 'eng_alphabet';
  static const String chartJpnHiragana = 'jpn_hiragana';
  static const String chartJpnKatakana = 'jpn_katakana';
  static const String chartFra = 'fra_basic';
  static const String chartDeu = 'deu_basic';
  static const String chartEsp = 'esp_basic';

  /// 화면 드롭다운 순서 — [한국어(가나다), 영어, 일본어 히라가나·가타카나, 프랑스어, 독일어, 스페인어]
  static const List<BasicCharacterChartOption> allChartsOrdered = [
    _korGanada,
    _engAlphabet,
    _jpnHiragana,
    _jpnKatakana,
    _fraBasic,
    _deuBasic,
    _espBasic,
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

  /// 가나다: 자음 → 모음 → 음절(가나다 순). 표기법 열 없음.
  static const _korGanada = BasicCharacterChartOption(
    id: chartKorGanada,
    koreanSections: [
      BasicCharacterChartSection(
        sectionId: 'kor_consonants',
        characters: [
          'ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
        ],
      ),
      BasicCharacterChartSection(
        sectionId: 'kor_vowels',
        characters: [
          'ㅏ', 'ㅑ', 'ㅓ', 'ㅕ', 'ㅗ', 'ㅛ', 'ㅜ', 'ㅠ', 'ㅡ', 'ㅣ',
        ],
      ),
      BasicCharacterChartSection(
        sectionId: 'kor_syllables',
        characters: [
          '가', '나', '다', '라', '마', '바', '사', '아', '자', '차', '카', '타', '파', '하',
        ],
      ),
    ],
  );

  static const _engAlphabet = BasicCharacterChartOption(
    id: chartEngAlphabet,
    entries: [
      BasicCharacterEntry(character: 'A', pronunciation: '/eɪ/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'B', pronunciation: '/biː/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'C', pronunciation: '/siː/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'D', pronunciation: '/diː/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'E', pronunciation: '/iː/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'F', pronunciation: '/ef/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'G', pronunciation: '/dʒiː/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'H', pronunciation: '/eɪtʃ/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'I', pronunciation: '/aɪ/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'J', pronunciation: '/dʒeɪ/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'K', pronunciation: '/keɪ/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'L', pronunciation: '/el/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'M', pronunciation: '/em/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'N', pronunciation: '/en/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'O', pronunciation: '/oʊ/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'P', pronunciation: '/piː/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'Q', pronunciation: '/kjuː/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'R', pronunciation: '/ɑːr/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'S', pronunciation: '/es/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'T', pronunciation: '/tiː/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'U', pronunciation: '/juː/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'V', pronunciation: '/viː/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'W', pronunciation: '/ˈdʌbəl.juː/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'X', pronunciation: '/eks/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'Y', pronunciation: '/waɪ/', orthography: 'Latin · majuscule'),
      BasicCharacterEntry(character: 'Z', pronunciation: '/ziː/', orthography: 'Latin · majuscule'),
    ],
  );

  static const _jpnHiragana = BasicCharacterChartOption(
    id: chartJpnHiragana,
    entries: [
      BasicCharacterEntry(character: 'あ', pronunciation: 'a', orthography: '対: ア'),
      BasicCharacterEntry(character: 'い', pronunciation: 'i', orthography: '対: イ'),
      BasicCharacterEntry(character: 'う', pronunciation: 'u', orthography: '対: ウ'),
      BasicCharacterEntry(character: 'え', pronunciation: 'e', orthography: '対: エ'),
      BasicCharacterEntry(character: 'お', pronunciation: 'o', orthography: '対: オ'),
      BasicCharacterEntry(character: 'か', pronunciation: 'ka', orthography: '対: カ'),
      BasicCharacterEntry(character: 'き', pronunciation: 'ki', orthography: '対: キ'),
      BasicCharacterEntry(character: 'く', pronunciation: 'ku', orthography: '対: ク'),
      BasicCharacterEntry(character: 'け', pronunciation: 'ke', orthography: '対: ケ'),
      BasicCharacterEntry(character: 'こ', pronunciation: 'ko', orthography: '対: コ'),
      BasicCharacterEntry(character: 'さ', pronunciation: 'sa', orthography: '対: サ'),
      BasicCharacterEntry(character: 'し', pronunciation: 'shi', orthography: '対: シ'),
      BasicCharacterEntry(character: 'す', pronunciation: 'su', orthography: '対: ス'),
      BasicCharacterEntry(character: 'せ', pronunciation: 'se', orthography: '対: セ'),
      BasicCharacterEntry(character: 'そ', pronunciation: 'so', orthography: '対: ソ'),
      BasicCharacterEntry(character: 'た', pronunciation: 'ta', orthography: '対: タ'),
      BasicCharacterEntry(character: 'ち', pronunciation: 'chi', orthography: '対: チ'),
      BasicCharacterEntry(character: 'つ', pronunciation: 'tsu', orthography: '対: ツ'),
      BasicCharacterEntry(character: 'て', pronunciation: 'te', orthography: '対: テ'),
      BasicCharacterEntry(character: 'と', pronunciation: 'to', orthography: '対: ト'),
      BasicCharacterEntry(character: 'な', pronunciation: 'na', orthography: '対: ナ'),
      BasicCharacterEntry(character: 'に', pronunciation: 'ni', orthography: '対: ニ'),
      BasicCharacterEntry(character: 'ぬ', pronunciation: 'nu', orthography: '対: ヌ'),
      BasicCharacterEntry(character: 'ね', pronunciation: 'ne', orthography: '対: ネ'),
      BasicCharacterEntry(character: 'の', pronunciation: 'no', orthography: '対: ノ'),
      BasicCharacterEntry(character: 'は', pronunciation: 'ha', orthography: '対: ハ'),
      BasicCharacterEntry(character: 'ひ', pronunciation: 'hi', orthography: '対: ヒ'),
      BasicCharacterEntry(character: 'ふ', pronunciation: 'fu', orthography: '対: フ'),
      BasicCharacterEntry(character: 'へ', pronunciation: 'he', orthography: '対: ヘ'),
      BasicCharacterEntry(character: 'ほ', pronunciation: 'ho', orthography: '対: ホ'),
      BasicCharacterEntry(character: 'ま', pronunciation: 'ma', orthography: '対: マ'),
      BasicCharacterEntry(character: 'み', pronunciation: 'mi', orthography: '対: ミ'),
      BasicCharacterEntry(character: 'む', pronunciation: 'mu', orthography: '対: ム'),
      BasicCharacterEntry(character: 'め', pronunciation: 'me', orthography: '対: メ'),
      BasicCharacterEntry(character: 'も', pronunciation: 'mo', orthography: '対: モ'),
      BasicCharacterEntry(character: 'や', pronunciation: 'ya', orthography: '対: ヤ'),
      BasicCharacterEntry(character: 'ゆ', pronunciation: 'yu', orthography: '対: ユ'),
      BasicCharacterEntry(character: 'よ', pronunciation: 'yo', orthography: '対: ヨ'),
      BasicCharacterEntry(character: 'ら', pronunciation: 'ra', orthography: '対: ラ'),
      BasicCharacterEntry(character: 'り', pronunciation: 'ri', orthography: '対: リ'),
      BasicCharacterEntry(character: 'る', pronunciation: 'ru', orthography: '対: ル'),
      BasicCharacterEntry(character: 'れ', pronunciation: 're', orthography: '対: レ'),
      BasicCharacterEntry(character: 'ろ', pronunciation: 'ro', orthography: '対: ロ'),
      BasicCharacterEntry(character: 'わ', pronunciation: 'wa', orthography: '対: ワ'),
      BasicCharacterEntry(character: 'を', pronunciation: 'wo', orthography: '対: ヲ'),
      BasicCharacterEntry(character: 'ん', pronunciation: 'n', orthography: '撥音 · 対: ン'),
    ],
  );

  static const _jpnKatakana = BasicCharacterChartOption(
    id: chartJpnKatakana,
    entries: [
      BasicCharacterEntry(character: 'ア', pronunciation: 'a', orthography: '対: あ'),
      BasicCharacterEntry(character: 'イ', pronunciation: 'i', orthography: '対: い'),
      BasicCharacterEntry(character: 'ウ', pronunciation: 'u', orthography: '対: う'),
      BasicCharacterEntry(character: 'エ', pronunciation: 'e', orthography: '対: え'),
      BasicCharacterEntry(character: 'オ', pronunciation: 'o', orthography: '対: お'),
      BasicCharacterEntry(character: 'カ', pronunciation: 'ka', orthography: '対: か'),
      BasicCharacterEntry(character: 'キ', pronunciation: 'ki', orthography: '対: き'),
      BasicCharacterEntry(character: 'ク', pronunciation: 'ku', orthography: '対: く'),
      BasicCharacterEntry(character: 'ケ', pronunciation: 'ke', orthography: '対: け'),
      BasicCharacterEntry(character: 'コ', pronunciation: 'ko', orthography: '対: こ'),
      BasicCharacterEntry(character: 'サ', pronunciation: 'sa', orthography: '対: さ'),
      BasicCharacterEntry(character: 'シ', pronunciation: 'shi', orthography: '対: し'),
      BasicCharacterEntry(character: 'ス', pronunciation: 'su', orthography: '対: す'),
      BasicCharacterEntry(character: 'セ', pronunciation: 'se', orthography: '対: せ'),
      BasicCharacterEntry(character: 'ソ', pronunciation: 'so', orthography: '対: そ'),
      BasicCharacterEntry(character: 'タ', pronunciation: 'ta', orthography: '対: た'),
      BasicCharacterEntry(character: 'チ', pronunciation: 'chi', orthography: '対: ち'),
      BasicCharacterEntry(character: 'ツ', pronunciation: 'tsu', orthography: '対: つ'),
      BasicCharacterEntry(character: 'テ', pronunciation: 'te', orthography: '対: て'),
      BasicCharacterEntry(character: 'ト', pronunciation: 'to', orthography: '対: と'),
      BasicCharacterEntry(character: 'ナ', pronunciation: 'na', orthography: '対: な'),
      BasicCharacterEntry(character: 'ニ', pronunciation: 'ni', orthography: '対: に'),
      BasicCharacterEntry(character: 'ヌ', pronunciation: 'nu', orthography: '対: ぬ'),
      BasicCharacterEntry(character: 'ネ', pronunciation: 'ne', orthography: '対: ね'),
      BasicCharacterEntry(character: 'ノ', pronunciation: 'no', orthography: '対: の'),
      BasicCharacterEntry(character: 'ハ', pronunciation: 'ha', orthography: '対: は'),
      BasicCharacterEntry(character: 'ヒ', pronunciation: 'hi', orthography: '対: ひ'),
      BasicCharacterEntry(character: 'フ', pronunciation: 'fu', orthography: '対: ふ'),
      BasicCharacterEntry(character: 'ヘ', pronunciation: 'he', orthography: '対: へ'),
      BasicCharacterEntry(character: 'ホ', pronunciation: 'ho', orthography: '対: ほ'),
      BasicCharacterEntry(character: 'マ', pronunciation: 'ma', orthography: '対: ま'),
      BasicCharacterEntry(character: 'ミ', pronunciation: 'mi', orthography: '対: み'),
      BasicCharacterEntry(character: 'ム', pronunciation: 'mu', orthography: '対: む'),
      BasicCharacterEntry(character: 'メ', pronunciation: 'me', orthography: '対: め'),
      BasicCharacterEntry(character: 'モ', pronunciation: 'mo', orthography: '対: も'),
      BasicCharacterEntry(character: 'ヤ', pronunciation: 'ya', orthography: '対: や'),
      BasicCharacterEntry(character: 'ユ', pronunciation: 'yu', orthography: '対: ゆ'),
      BasicCharacterEntry(character: 'ヨ', pronunciation: 'yo', orthography: '対: よ'),
      BasicCharacterEntry(character: 'ラ', pronunciation: 'ra', orthography: '対: ら'),
      BasicCharacterEntry(character: 'リ', pronunciation: 'ri', orthography: '対: り'),
      BasicCharacterEntry(character: 'ル', pronunciation: 'ru', orthography: '対: る'),
      BasicCharacterEntry(character: 'レ', pronunciation: 're', orthography: '対: れ'),
      BasicCharacterEntry(character: 'ロ', pronunciation: 'ro', orthography: '対: ろ'),
      BasicCharacterEntry(character: 'ワ', pronunciation: 'wa', orthography: '対: わ'),
      BasicCharacterEntry(character: 'ヲ', pronunciation: 'wo', orthography: '対: を'),
      BasicCharacterEntry(character: 'ン', pronunciation: 'n', orthography: '撥音 · 対: ん'),
    ],
  );

  static const _fraBasic = BasicCharacterChartOption(
    id: chartFra,
    entries: [
      BasicCharacterEntry(character: 'é', pronunciation: '/e/', orthography: 'accent aigu · été'),
      BasicCharacterEntry(character: 'è', pronunciation: '/ɛ/', orthography: 'accent grave · père'),
      BasicCharacterEntry(character: 'ê', pronunciation: '/ɛ/', orthography: 'accent circonflexe · fête'),
      BasicCharacterEntry(character: 'ë', pronunciation: '/ɛ/', orthography: 'tréma · Noël'),
      BasicCharacterEntry(character: 'à', pronunciation: '/a/', orthography: 'grave · là'),
      BasicCharacterEntry(character: 'â', pronunciation: '/ɑ/', orthography: 'circonflexe · pâte'),
      BasicCharacterEntry(character: 'ù', pronunciation: '/y/', orthography: 'grave · où'),
      BasicCharacterEntry(character: 'û', pronunciation: '/y/', orthography: 'circonflexe · sûr'),
      BasicCharacterEntry(character: 'ü', pronunciation: '/y/', orthography: 'tréma · français rare'),
      BasicCharacterEntry(character: 'ô', pronunciation: '/o/', orthography: 'circonflexe · hôtel'),
      BasicCharacterEntry(character: 'î', pronunciation: '/i/', orthography: 'circonflexe · île'),
      BasicCharacterEntry(character: 'ï', pronunciation: '/i/', orthography: 'tréma · naïf'),
      BasicCharacterEntry(character: 'ç', pronunciation: '/s/', orthography: 'cédille · français'),
      BasicCharacterEntry(character: 'œ', pronunciation: '/œ/', orthography: 'ligature · œuf'),
      BasicCharacterEntry(character: 'æ', pronunciation: '/ɛ/', orthography: 'ligature · curriculum vitæ'),
    ],
  );

  static const _deuBasic = BasicCharacterChartOption(
    id: chartDeu,
    entries: [
      BasicCharacterEntry(character: 'ä', pronunciation: '/ɛ/', orthography: 'Umlaut · ähnlich'),
      BasicCharacterEntry(character: 'ö', pronunciation: '/ø/', orthography: 'Umlaut · schön'),
      BasicCharacterEntry(character: 'ü', pronunciation: '/y/', orthography: 'Umlaut · Tür'),
      BasicCharacterEntry(character: 'ß', pronunciation: '/s/', orthography: 'Eszett · Straße'),
      BasicCharacterEntry(character: 'A', pronunciation: '/aː/', orthography: 'Großbuchstabe'),
      BasicCharacterEntry(character: 'O', pronunciation: '/oː/', orthography: 'Großbuchstabe'),
      BasicCharacterEntry(character: 'U', pronunciation: '/uː/', orthography: 'Großbuchstabe'),
      BasicCharacterEntry(character: 'S', pronunciation: '/z/', orthography: 's- + Vokal → /z/ (Sie)'),
    ],
  );

  static const _espBasic = BasicCharacterChartOption(
    id: chartEsp,
    entries: [
      BasicCharacterEntry(character: 'ñ', pronunciation: '/ɲ/', orthography: 'eñe · año'),
      BasicCharacterEntry(character: 'á', pronunciation: '/a/', orthography: 'tilde aguda · más'),
      BasicCharacterEntry(character: 'é', pronunciation: '/e/', orthography: 'tilde aguda · café'),
      BasicCharacterEntry(character: 'í', pronunciation: '/i/', orthography: 'tilde aguda · sí'),
      BasicCharacterEntry(character: 'ó', pronunciation: '/o/', orthography: 'tilde aguda · sólo'),
      BasicCharacterEntry(character: 'ú', pronunciation: '/u/', orthography: 'tilde aguda · tú'),
      BasicCharacterEntry(character: 'ü', pronunciation: '/w/', orthography: 'diéresis · pingüino'),
      BasicCharacterEntry(character: '¿', pronunciation: '—', orthography: 'signo de apertura'),
      BasicCharacterEntry(character: '¡', pronunciation: '—', orthography: 'signo de apertura'),
    ],
  );
}
