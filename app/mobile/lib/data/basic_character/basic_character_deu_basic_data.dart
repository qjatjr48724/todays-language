import '../../models/basic_character_entry.dart';

const String kBasicCharacterChartIdDeuBasic = 'deu_basic';

const List<BasicCharacterLocalizedRow> _deuLocalizedRows = [
  BasicCharacterLocalizedRow(
    character: 'ä',
    pronunciationKo: '애', pronunciationEn: 'eh', pronunciationJa: 'エ',
    exampleWord: 'ähnlich', exampleGlossKo: '비슷한', exampleGlossEn: 'similar', exampleGlossJa: '似ている',
  ),
  BasicCharacterLocalizedRow(
    character: 'ö',
    pronunciationKo: '외', pronunciationEn: 'er', pronunciationJa: 'オー',
    exampleWord: 'schön', exampleGlossKo: '아름다운', exampleGlossEn: 'beautiful', exampleGlossJa: 'きれい',
  ),
  BasicCharacterLocalizedRow(
    character: 'ü',
    pronunciationKo: '위', pronunciationEn: 'ue', pronunciationJa: 'ユー',
    exampleWord: 'Tür', exampleGlossKo: '문', exampleGlossEn: 'door', exampleGlossJa: '扉',
  ),
  BasicCharacterLocalizedRow(
    character: 'ß',
    pronunciationKo: '에스체', pronunciationEn: 'ess-tset', pronunciationJa: 'エスツェット',
    exampleWord: 'Straße', exampleGlossKo: '거리', exampleGlossEn: 'street', exampleGlossJa: '通り',
  ),
  BasicCharacterLocalizedRow(
    character: 'A',
    pronunciationKo: '대문자 A', pronunciationEn: 'capital A', pronunciationJa: '大文字A',
    exampleWord: 'Apfel', exampleGlossKo: '사과', exampleGlossEn: 'apple', exampleGlossJa: 'リンゴ',
  ),
  BasicCharacterLocalizedRow(
    character: 'O',
    pronunciationKo: '대문자 O', pronunciationEn: 'capital O', pronunciationJa: '大文字O',
    exampleWord: 'Ohr', exampleGlossKo: '귀', exampleGlossEn: 'ear', exampleGlossJa: '耳',
  ),
  BasicCharacterLocalizedRow(
    character: 'U',
    pronunciationKo: '대문자 U', pronunciationEn: 'capital U', pronunciationJa: '大文字U',
    exampleWord: 'Uhr', exampleGlossKo: '시계', exampleGlossEn: 'clock', exampleGlossJa: '時計',
  ),
  BasicCharacterLocalizedRow(
    character: 'S',
    pronunciationKo: 'Z음', pronunciationEn: 'z sound', pronunciationJa: 'Z音',
    exampleWord: 'Sie', exampleGlossKo: '당신', exampleGlossEn: 'you (formal)', exampleGlossJa: 'あなた',
  ),
];

/// 독일어 특수 문자 — 문자 · 로컬 발음 · 예시 3열.
const BasicCharacterChartOption kBasicCharacterDeuBasicChart =
    BasicCharacterChartOption(
  id: kBasicCharacterChartIdDeuBasic,
  localizedRows: _deuLocalizedRows,
);
