import '../../models/basic_character_entry.dart';

const String kBasicCharacterChartIdEspBasic = 'esp_basic';

const List<BasicCharacterLocalizedRow> _espLocalizedRows = [
  BasicCharacterLocalizedRow(
    character: 'ñ',
    pronunciationKo: '니', pronunciationEn: 'ny', pronunciationJa: 'ニ',
    exampleWord: 'año', exampleGlossKo: '해', exampleGlossEn: 'year', exampleGlossJa: '年',
  ),
  BasicCharacterLocalizedRow(
    character: 'á',
    pronunciationKo: '아', pronunciationEn: 'ah', pronunciationJa: 'ア',
    exampleWord: 'más', exampleGlossKo: '더', exampleGlossEn: 'more', exampleGlossJa: 'もっと',
  ),
  BasicCharacterLocalizedRow(
    character: 'é',
    pronunciationKo: '에', pronunciationEn: 'ay', pronunciationJa: 'エ',
    exampleWord: 'café', exampleGlossKo: '카페', exampleGlossEn: 'coffee shop', exampleGlossJa: 'カフェ',
  ),
  BasicCharacterLocalizedRow(
    character: 'í',
    pronunciationKo: '이', pronunciationEn: 'ee', pronunciationJa: 'イ',
    exampleWord: 'sí', exampleGlossKo: '네', exampleGlossEn: 'yes', exampleGlossJa: 'はい',
  ),
  BasicCharacterLocalizedRow(
    character: 'ó',
    pronunciationKo: '오', pronunciationEn: 'oh', pronunciationJa: 'オ',
    exampleWord: 'sólo', exampleGlossKo: '만', exampleGlossEn: 'only', exampleGlossJa: 'だけ',
  ),
  BasicCharacterLocalizedRow(
    character: 'ú',
    pronunciationKo: '우', pronunciationEn: 'oo', pronunciationJa: 'ウ',
    exampleWord: 'tú', exampleGlossKo: '너', exampleGlossEn: 'you', exampleGlossJa: 'あなた',
  ),
  BasicCharacterLocalizedRow(
    character: 'ü',
    pronunciationKo: '우', pronunciationEn: 'w', pronunciationJa: 'ウ',
    exampleWord: 'pingüino', exampleGlossKo: '펭귄', exampleGlossEn: 'penguin', exampleGlossJa: 'ペンギン',
  ),
  BasicCharacterLocalizedRow(
    character: '¿',
    pronunciationKo: '의문문 앞', pronunciationEn: 'opens question', pronunciationJa: '疑問文の前',
    exampleWord: '¿Cómo?', exampleGlossKo: '어떻게?', exampleGlossEn: 'How?', exampleGlossJa: 'どう？',
  ),
  BasicCharacterLocalizedRow(
    character: '¡',
    pronunciationKo: '감탄문 앞', pronunciationEn: 'opens exclamation', pronunciationJa: '感嘆文の前',
    exampleWord: '¡Hola!', exampleGlossKo: '안녕!', exampleGlossEn: 'Hello!', exampleGlossJa: 'こんにちは！',
  ),
];

/// 스페인어 특수 문자 — 문자 · 로컬 발음 · 예시 3열.
const BasicCharacterChartOption kBasicCharacterEspBasicChart =
    BasicCharacterChartOption(
  id: kBasicCharacterChartIdEspBasic,
  localizedRows: _espLocalizedRows,
);
