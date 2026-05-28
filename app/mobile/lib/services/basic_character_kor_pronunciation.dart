/// 한국어 자모·음절 발음 표기 — **앱 UI 로케일**(디바이스 기준 `ko`/`en`/`ja`)에 따라 달라짐.
class BasicCharacterKorPronunciation {
  BasicCharacterKorPronunciation._();

  /// [languageCode]는 `Localizations.localeOf(context).languageCode` 등.
  /// 지원: `ko`, `ja` — 그 외는 프로젝트 규칙에 따라 `en` 폴백.
  static String normalizeUiLanguage(String languageCode) {
    final c = languageCode.toLowerCase().split(RegExp(r'[-_]')).first;
    if (c == 'ko') return 'ko';
    if (c == 'ja') return 'ja';
    return 'en';
  }

  static String forCharacter(String ch, String languageCode) {
    final ui = normalizeUiLanguage(languageCode);
    switch (ui) {
      case 'ko':
        return _korean[ch] ?? _english[ch] ?? ch;
      case 'ja':
        return _japanese[ch] ?? _english[ch] ?? ch;
      default:
        return _english[ch] ?? ch;
    }
  }

  /// UI 영어(및 미지원 로케일 폴백) — 로마자·짧은 설명.
  static const Map<String, String> _english = {
    'ㄱ': 'g / k',
    'ㄴ': 'n',
    'ㄷ': 'd / t',
    'ㄹ': 'r / l',
    'ㅁ': 'm',
    'ㅂ': 'b / p',
    'ㅅ': 's',
    'ㅇ': 'silent / ng',
    'ㅈ': 'j',
    'ㅊ': 'ch',
    'ㅋ': 'k',
    'ㅌ': 't',
    'ㅍ': 'p',
    'ㅎ': 'h',
    'ㅏ': 'a',
    'ㅑ': 'ya',
    'ㅓ': 'eo',
    'ㅕ': 'yeo',
    'ㅗ': 'o',
    'ㅛ': 'yo',
    'ㅜ': 'u',
    'ㅠ': 'yu',
    'ㅡ': 'eu',
    'ㅣ': 'i',
    '가': 'ga',
    '나': 'na',
    '다': 'da',
    '라': 'ra',
    '마': 'ma',
    '바': 'ba',
    '사': 'sa',
    '아': 'a',
    '자': 'ja',
    '차': 'cha',
    '카': 'ka',
    '타': 'ta',
    '파': 'pa',
    '하': 'ha',
  };

  /// UI 일본어 — 가타카나·짧은 설명.
  static const Map<String, String> _japanese = {
    'ㄱ': 'g/k · カ行系',
    'ㄴ': 'n · ナ行',
    'ㄷ': 'd/t · タ行',
    'ㄹ': 'r/l · ラ行',
    'ㅁ': 'm · マ行',
    'ㅂ': 'b/p · バ行',
    'ㅅ': 's · サ行',
    'ㅇ': '無声・ng · ン',
    'ㅈ': 'j · ジャ行',
    'ㅊ': 'ch · チャ行',
    'ㅋ': 'k · カ行強',
    'ㅌ': 't · タ行強',
    'ㅍ': 'p · パ行強',
    'ㅎ': 'h · ハ行',
    'ㅏ': 'a · ア',
    'ㅑ': 'ya · ヤ',
    'ㅓ': 'eo · オ寄り',
    'ㅕ': 'yeo · ヨ',
    'ㅗ': 'o · オ',
    'ㅛ': 'yo · ヨ',
    'ㅜ': 'u · ウ',
    'ㅠ': 'yu · ユ',
    'ㅡ': 'eu · ウ/イの中間',
    'ㅣ': 'i · イ',
    '가': 'ga · ガ',
    '나': 'na · ナ',
    '다': 'da · ダ',
    '라': 'ra · ラ',
    '마': 'ma · マ',
    '바': 'ba · バ',
    '사': 'sa · サ',
    '아': 'a · ア',
    '자': 'ja · ジャ',
    '차': 'cha · チャ',
    '카': 'ka · カ',
    '타': 'ta · タ',
    '파': 'pa · パ',
    '하': 'ha · ハ',
  };

  /// UI 한국어 — 자모 이름·짧은 로마자.
  static const Map<String, String> _korean = {
    'ㄱ': '기역 · g/k',
    'ㄴ': '니은 · n',
    'ㄷ': '디귿 · d/t',
    'ㄹ': '리을 · r/l',
    'ㅁ': '미음 · m',
    'ㅂ': '비읍 · b/p',
    'ㅅ': '시옷 · s',
    'ㅇ': '이응 · 묵음·ng',
    'ㅈ': '지읒 · j',
    'ㅊ': '치읓 · ch',
    'ㅋ': '키읔 · k',
    'ㅌ': '티읕 · t',
    'ㅍ': '피읖 · p',
    'ㅎ': '히읗 · h',
    'ㅏ': '아 · a',
    'ㅑ': '야 · ya',
    'ㅓ': '어 · eo',
    'ㅕ': '여 · yeo',
    'ㅗ': '오 · o',
    'ㅛ': '요 · yo',
    'ㅜ': '우 · u',
    'ㅠ': '유 · yu',
    'ㅡ': '으 · eu',
    'ㅣ': '이 · i',
    '가': '가 · ga',
    '나': '나 · na',
    '다': '다 · da',
    '라': '라 · ra',
    '마': '마 · ma',
    '바': '바 · ba',
    '사': '사 · sa',
    '아': '아 · a',
    '자': '자 · ja',
    '차': '차 · cha',
    '카': '카 · ka',
    '타': '타 · ta',
    '파': '파 · pa',
    '하': '하 · ha',
  };
}
