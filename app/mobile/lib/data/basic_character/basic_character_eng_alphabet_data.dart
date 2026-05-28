import '../../models/basic_character_entry.dart';

const String kBasicCharacterChartIdEngAlphabet = 'eng_alphabet';

const List<String> _engAlphabetLetters = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
];

/// 영어 알파벳 기초 문자표 — 발음·예시는 UI 로케일별 서비스·i18n에서 조회.
final BasicCharacterChartOption kBasicCharacterEngAlphabetChart =
    BasicCharacterChartOption(
  id: kBasicCharacterChartIdEngAlphabet,
  entries: [
    for (final ch in _engAlphabetLetters) BasicCharacterEntry(character: ch),
  ],
);
