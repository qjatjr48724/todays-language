/// 영어 알파벳 글자 이름 — 앱 UI 로케일(`ko`/`en`/`ja`) 기준 표기.
class BasicCharacterEngPronunciation {
  BasicCharacterEngPronunciation._();

  static String normalizeUiLanguage(String languageCode) {
    final c = languageCode.toLowerCase().split(RegExp(r'[-_]')).first;
    if (c == 'ko') return 'ko';
    if (c == 'ja') return 'ja';
    return 'en';
  }

  static String forLetter(String letter, String languageCode) {
    final key = letter.toUpperCase();
    final ui = normalizeUiLanguage(languageCode);
    switch (ui) {
      case 'ko':
        return _korean[key] ?? key;
      case 'ja':
        return _japanese[key] ?? key;
      default:
        return _english[key] ?? key;
    }
  }

  static const Map<String, String> _english = {
    'A': 'ay',
    'B': 'bee',
    'C': 'cee',
    'D': 'dee',
    'E': 'ee',
    'F': 'ef',
    'G': 'jee',
    'H': 'aitch',
    'I': 'eye',
    'J': 'jay',
    'K': 'kay',
    'L': 'el',
    'M': 'em',
    'N': 'en',
    'O': 'oh',
    'P': 'pee',
    'Q': 'cue',
    'R': 'ar',
    'S': 'ess',
    'T': 'tee',
    'U': 'you',
    'V': 'vee',
    'W': 'double-you',
    'X': 'ex',
    'Y': 'why',
    'Z': 'zee',
  };

  static const Map<String, String> _korean = {
    'A': '에이',
    'B': '비',
    'C': '씨',
    'D': '디',
    'E': '이',
    'F': '에프',
    'G': '지',
    'H': '에이치',
    'I': '아이',
    'J': '제이',
    'K': '케이',
    'L': '엘',
    'M': '엠',
    'N': '엔',
    'O': '오',
    'P': '피',
    'Q': '큐',
    'R': '아르',
    'S': '에스',
    'T': '티',
    'U': '유',
    'V': '브이',
    'W': '더블유',
    'X': '엑스',
    'Y': '와이',
    'Z': '제트',
  };

  static const Map<String, String> _japanese = {
    'A': 'エイ',
    'B': 'ビー',
    'C': 'シー',
    'D': 'ディー',
    'E': 'イー',
    'F': 'エフ',
    'G': 'ジー',
    'H': 'エイチ',
    'I': 'アイ',
    'J': 'ジェー',
    'K': 'ケー',
    'L': 'エル',
    'M': 'エム',
    'N': 'エヌ',
    'O': 'オー',
    'P': 'ピー',
    'Q': 'キュー',
    'R': 'アール',
    'S': 'エス',
    'T': 'ティー',
    'U': 'ユー',
    'V': 'ヴィー',
    'W': 'ダブリュー',
    'X': 'エックス',
    'Y': 'ワイ',
    'Z': 'ゼット',
  };
}
