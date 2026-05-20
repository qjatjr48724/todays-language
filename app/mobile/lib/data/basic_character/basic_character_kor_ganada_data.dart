import '../../models/basic_character_entry.dart';

const String kBasicCharacterChartIdKorGanada = 'kor_ganada';

/// 한국어(가나다) 기초 문자표 — 자음 · 모음 · 음절.
const BasicCharacterChartOption kBasicCharacterKorGanadaChart =
    BasicCharacterChartOption(
  id: kBasicCharacterChartIdKorGanada,
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
