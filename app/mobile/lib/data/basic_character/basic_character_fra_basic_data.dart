import '../../models/basic_character_entry.dart';

const String kBasicCharacterChartIdFraBasic = 'fra_basic';

const List<BasicCharacterLocalizedRow> _fraLocalizedRows = [
  BasicCharacterLocalizedRow(
    character: 'é',
    pronunciationKo: '에', pronunciationEn: 'ay', pronunciationJa: 'エ',
    exampleWord: 'été', exampleGlossKo: '여름', exampleGlossEn: 'summer', exampleGlossJa: '夏',
  ),
  BasicCharacterLocalizedRow(
    character: 'è',
    pronunciationKo: '에', pronunciationEn: 'eh', pronunciationJa: 'エ',
    exampleWord: 'père', exampleGlossKo: '아버지', exampleGlossEn: 'father', exampleGlossJa: '父',
  ),
  BasicCharacterLocalizedRow(
    character: 'ê',
    pronunciationKo: '에', pronunciationEn: 'eh', pronunciationJa: 'エ',
    exampleWord: 'fête', exampleGlossKo: '축제', exampleGlossEn: 'party', exampleGlossJa: '祭り',
  ),
  BasicCharacterLocalizedRow(
    character: 'ë',
    pronunciationKo: '에', pronunciationEn: 'eh', pronunciationJa: 'エ',
    exampleWord: 'Noël', exampleGlossKo: '크리스마스', exampleGlossEn: 'Christmas', exampleGlossJa: 'クリスマス',
  ),
  BasicCharacterLocalizedRow(
    character: 'à',
    pronunciationKo: '아', pronunciationEn: 'ah', pronunciationJa: 'ア',
    exampleWord: 'là', exampleGlossKo: '거기', exampleGlossEn: 'there', exampleGlossJa: 'そこ',
  ),
  BasicCharacterLocalizedRow(
    character: 'â',
    pronunciationKo: '아', pronunciationEn: 'ah', pronunciationJa: 'ア',
    exampleWord: 'pâte', exampleGlossKo: '반죽', exampleGlossEn: 'dough', exampleGlossJa: '生地',
  ),
  BasicCharacterLocalizedRow(
    character: 'ù',
    pronunciationKo: '우', pronunciationEn: 'oo', pronunciationJa: 'ウ',
    exampleWord: 'où', exampleGlossKo: '어디', exampleGlossEn: 'where', exampleGlossJa: 'どこ',
  ),
  BasicCharacterLocalizedRow(
    character: 'û',
    pronunciationKo: '우', pronunciationEn: 'oo', pronunciationJa: 'ウ',
    exampleWord: 'sûr', exampleGlossKo: '확실한', exampleGlossEn: 'sure', exampleGlossJa: '確か',
  ),
  BasicCharacterLocalizedRow(
    character: 'ü',
    pronunciationKo: '위', pronunciationEn: 'ew', pronunciationJa: 'ユ',
    exampleWord: 'aiguë', exampleGlossKo: '날카로운', exampleGlossEn: 'sharp', exampleGlossJa: '鋭い',
  ),
  BasicCharacterLocalizedRow(
    character: 'ô',
    pronunciationKo: '오', pronunciationEn: 'oh', pronunciationJa: 'オ',
    exampleWord: 'hôtel', exampleGlossKo: '호텔', exampleGlossEn: 'hotel', exampleGlossJa: 'ホテル',
  ),
  BasicCharacterLocalizedRow(
    character: 'î',
    pronunciationKo: '이', pronunciationEn: 'ee', pronunciationJa: 'イ',
    exampleWord: 'île', exampleGlossKo: '섬', exampleGlossEn: 'island', exampleGlossJa: '島',
  ),
  BasicCharacterLocalizedRow(
    character: 'ï',
    pronunciationKo: '이', pronunciationEn: 'ee', pronunciationJa: 'イ',
    exampleWord: 'naïf', exampleGlossKo: '순진한', exampleGlossEn: 'naive', exampleGlossJa: '素朴',
  ),
  BasicCharacterLocalizedRow(
    character: 'ç',
    pronunciationKo: '스', pronunciationEn: 's', pronunciationJa: 'ス',
    exampleWord: 'français', exampleGlossKo: '프랑스어', exampleGlossEn: 'French', exampleGlossJa: 'フランス語',
  ),
  BasicCharacterLocalizedRow(
    character: 'œ',
    pronunciationKo: '어', pronunciationEn: 'eu', pronunciationJa: 'ウー',
    exampleWord: 'œuf', exampleGlossKo: '달걀', exampleGlossEn: 'egg', exampleGlossJa: '卵',
  ),
  BasicCharacterLocalizedRow(
    character: 'æ',
    pronunciationKo: '에', pronunciationEn: 'eh', pronunciationJa: 'エ',
    exampleWord: 'curriculum vitæ', exampleGlossKo: '이력서', exampleGlossEn: 'CV', exampleGlossJa: '履歴書',
  ),
];

/// 프랑스어 특수 문자 — 문자 · 로컬 발음 · 예시 3열.
const BasicCharacterChartOption kBasicCharacterFraBasicChart =
    BasicCharacterChartOption(
  id: kBasicCharacterChartIdFraBasic,
  localizedRows: _fraLocalizedRows,
);
