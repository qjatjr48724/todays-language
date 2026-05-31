import '../../models/basic_character_entry.dart';
import '../../services/basic_character_eng_pronunciation.dart';

const String kBasicCharacterChartIdEngAlphabet = 'eng_alphabet';

const List<String> _engAlphabetLetters = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
];

const Map<String, (String word, String ko, String en, String ja)> _engExamples = {
  'A': ('Apple', '사과', 'fruit', 'りんご'),
  'B': ('Ball', '공', 'toy', 'ボール'),
  'C': ('Cat', '고양이', 'animal', 'ねこ'),
  'D': ('Dog', '개', 'animal', 'いぬ'),
  'E': ('Egg', '달걀', 'food', 'たまご'),
  'F': ('Fish', '물고기', 'animal', 'さかな'),
  'G': ('Grape', '포도', 'fruit', 'ぶどう'),
  'H': ('Hat', '모자', 'clothing', 'ぼうし'),
  'I': ('Ice', '얼음', 'frozen water', 'こおり'),
  'J': ('Juice', '주스', 'drink', 'ジュース'),
  'K': ('King', '왕', 'ruler', 'おう'),
  'L': ('Lion', '사자', 'animal', 'ライオン'),
  'M': ('Moon', '달', 'night sky', 'つき'),
  'N': ('Nest', '둥지', 'bird home', 'す'),
  'O': ('Orange', '오렌지', 'fruit', 'オレンジ'),
  'P': ('Pen', '펜', 'writing tool', 'ペン'),
  'Q': ('Queen', '여왕', 'ruler', 'じょおう'),
  'R': ('Rabbit', '토끼', 'animal', 'うさぎ'),
  'S': ('Sun', '해', 'daytime', 'たいよう'),
  'T': ('Tree', '나무', 'plant', 'き'),
  'U': ('Umbrella', '우산', 'rain gear', 'かさ'),
  'V': ('Violin', '바이올린', 'instrument', 'バイオリン'),
  'W': ('Water', '물', 'drink', 'みず'),
  'X': ('X-ray', '엑스레이', 'medical scan', 'レントゲン'),
  'Y': ('Yellow', '노란색', 'color', 'きいろ'),
  'Z': ('Zoo', '동물원', 'animals', 'どうぶつえん'),
};

List<BasicCharacterLocalizedRow> buildEngAlphabetLocalizedRows() {
  return [
    for (final letter in _engAlphabetLetters)
      BasicCharacterLocalizedRow(
        character: letter,
        pronunciationKo: BasicCharacterEngPronunciation.forLetter(letter, 'ko'),
        pronunciationEn: BasicCharacterEngPronunciation.forLetter(letter, 'en'),
        pronunciationJa: BasicCharacterEngPronunciation.forLetter(letter, 'ja'),
        exampleWord: _engExamples[letter]!.$1,
        exampleGlossKo: _engExamples[letter]!.$2,
        exampleGlossEn: _engExamples[letter]!.$3,
        exampleGlossJa: _engExamples[letter]!.$4,
      ),
  ];
}

/// 영어 알파벳 — 문자 · 로컬 발음 · 예시 3열.
final BasicCharacterChartOption kBasicCharacterEngAlphabetChart =
    BasicCharacterChartOption(
  id: kBasicCharacterChartIdEngAlphabet,
  localizedRows: buildEngAlphabetLocalizedRows(),
);
