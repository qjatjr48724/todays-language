/// 한글 자음·모음 조합(초성+중성 → 음절).
class BasicCharacterKorCombine {
  BasicCharacterKorCombine._();

  static const int _base = 0xAC00;

  static const List<String> _chos = [
    'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ', 'ㅅ',
    'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ',
  ];

  static const List<String> _jungs = [
    'ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ',
    'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ',
  ];

  /// [consonant]·[vowel]이 조합 불가면 null.
  static String? syllable(String consonant, String vowel) {
    final ci = _chos.indexOf(consonant);
    final ji = _jungs.indexOf(vowel);
    if (ci < 0 || ji < 0) return null;
    return String.fromCharCode(_base + ci * 588 + ji * 28);
  }
}
