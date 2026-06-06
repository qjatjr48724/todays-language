import '../../models/basic_character_entry.dart';

import 'basic_character_kana_extended_data.dart';

/// 일본어 가나 발음 종류 탭 — 청음·탁음·반탁음·요음·촉음·장음.
enum JpnKanaPronunciationTab {
  seion,
  dakuon,
  handakuon,
  youon,
  sokuon,
  chouon,
}

/// 가나 공통 원본 — 히라가나·가타카나 표를 함께 생성합니다.
class BasicCharacterKanaSourceRow {
  const BasicCharacterKanaSourceRow({
    required this.hiragana,
    required this.katakana,
    required this.pronunciationKo,
    required this.pronunciationEn,
    required this.exampleHiragana,
    required this.exampleKatakana,
    required this.exampleGlossKo,
    required this.exampleGlossEn,
    required this.exampleGlossJa,
  });

  final String hiragana;
  final String katakana;
  final String pronunciationKo;
  final String pronunciationEn;
  final String exampleHiragana;
  final String exampleKatakana;
  final String exampleGlossKo;
  final String exampleGlossEn;
  final String exampleGlossJa;
}

const List<BasicCharacterKanaSourceRow> kBasicCharacterKanaSourceRows = [
  BasicCharacterKanaSourceRow(
    hiragana: 'あ', katakana: 'ア', pronunciationKo: '아', pronunciationEn: 'a',
    exampleHiragana: 'あめ', exampleKatakana: 'アメ',
    exampleGlossKo: '비', exampleGlossEn: 'rain', exampleGlossJa: '雨',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'い', katakana: 'イ', pronunciationKo: '이', pronunciationEn: 'i',
    exampleHiragana: 'いぬ', exampleKatakana: 'イヌ',
    exampleGlossKo: '개', exampleGlossEn: 'dog', exampleGlossJa: '犬',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'う', katakana: 'ウ', pronunciationKo: '우', pronunciationEn: 'u',
    exampleHiragana: 'うみ', exampleKatakana: 'ウミ',
    exampleGlossKo: '바다', exampleGlossEn: 'sea', exampleGlossJa: '海',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'え', katakana: 'エ', pronunciationKo: '에', pronunciationEn: 'e',
    exampleHiragana: 'えき', exampleKatakana: 'エキ',
    exampleGlossKo: '역', exampleGlossEn: 'station', exampleGlossJa: '駅',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'お', katakana: 'オ', pronunciationKo: '오', pronunciationEn: 'o',
    exampleHiragana: 'おと', exampleKatakana: 'オト',
    exampleGlossKo: '소리', exampleGlossEn: 'sound', exampleGlossJa: '音',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'か', katakana: 'カ', pronunciationKo: '카', pronunciationEn: 'ka',
    exampleHiragana: 'かさ', exampleKatakana: 'カサ',
    exampleGlossKo: '우산', exampleGlossEn: 'umbrella', exampleGlossJa: '傘',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'き', katakana: 'キ', pronunciationKo: '키', pronunciationEn: 'ki',
    exampleHiragana: 'き', exampleKatakana: 'キ',
    exampleGlossKo: '나무', exampleGlossEn: 'tree', exampleGlossJa: '木',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'く', katakana: 'ク', pronunciationKo: '쿠', pronunciationEn: 'ku',
    exampleHiragana: 'くつ', exampleKatakana: 'クツ',
    exampleGlossKo: '신발', exampleGlossEn: 'shoes', exampleGlossJa: '靴',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'け', katakana: 'ケ', pronunciationKo: '케', pronunciationEn: 'ke',
    exampleHiragana: 'けさ', exampleKatakana: 'ケサ',
    exampleGlossKo: '아침', exampleGlossEn: 'this morning', exampleGlossJa: '今朝',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'こ', katakana: 'コ', pronunciationKo: '코', pronunciationEn: 'ko',
    exampleHiragana: 'こえ', exampleKatakana: 'コエ',
    exampleGlossKo: '목소리', exampleGlossEn: 'voice', exampleGlossJa: '声',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'さ', katakana: 'サ', pronunciationKo: '사', pronunciationEn: 'sa',
    exampleHiragana: 'さかな', exampleKatakana: 'サカナ',
    exampleGlossKo: '생선', exampleGlossEn: 'fish', exampleGlossJa: '魚',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'し', katakana: 'シ', pronunciationKo: '시', pronunciationEn: 'shi',
    exampleHiragana: 'しお', exampleKatakana: 'シオ',
    exampleGlossKo: '소금', exampleGlossEn: 'salt', exampleGlossJa: '塩',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'す', katakana: 'ス', pronunciationKo: '스', pronunciationEn: 'su',
    exampleHiragana: 'すし', exampleKatakana: 'スシ',
    exampleGlossKo: '스시', exampleGlossEn: 'sushi', exampleGlossJa: '寿司',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'せ', katakana: 'セ', pronunciationKo: '세', pronunciationEn: 'se',
    exampleHiragana: 'せみ', exampleKatakana: 'セミ',
    exampleGlossKo: '매미', exampleGlossEn: 'cicada', exampleGlossJa: 'セミ',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'そ', katakana: 'ソ', pronunciationKo: '소', pronunciationEn: 'so',
    exampleHiragana: 'そら', exampleKatakana: 'ソラ',
    exampleGlossKo: '하늘', exampleGlossEn: 'sky', exampleGlossJa: '空',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'た', katakana: 'タ', pronunciationKo: '타', pronunciationEn: 'ta',
    exampleHiragana: 'たこ', exampleKatakana: 'タコ',
    exampleGlossKo: '문어', exampleGlossEn: 'octopus', exampleGlossJa: '蛸',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'ち', katakana: 'チ', pronunciationKo: '치', pronunciationEn: 'chi',
    exampleHiragana: 'ちず', exampleKatakana: 'チズ',
    exampleGlossKo: '지도', exampleGlossEn: 'map', exampleGlossJa: '地図',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'つ', katakana: 'ツ', pronunciationKo: '츠', pronunciationEn: 'tsu',
    exampleHiragana: 'つき', exampleKatakana: 'ツキ',
    exampleGlossKo: '달', exampleGlossEn: 'moon', exampleGlossJa: '月',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'て', katakana: 'テ', pronunciationKo: '테', pronunciationEn: 'te',
    exampleHiragana: 'て', exampleKatakana: 'テ',
    exampleGlossKo: '손', exampleGlossEn: 'hand', exampleGlossJa: '手',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'と', katakana: 'ト', pronunciationKo: '토', pronunciationEn: 'to',
    exampleHiragana: 'とり', exampleKatakana: 'トリ',
    exampleGlossKo: '새', exampleGlossEn: 'bird', exampleGlossJa: '鳥',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'な', katakana: 'ナ', pronunciationKo: '나', pronunciationEn: 'na',
    exampleHiragana: 'なつ', exampleKatakana: 'ナツ',
    exampleGlossKo: '여름', exampleGlossEn: 'summer', exampleGlossJa: '夏',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'に', katakana: 'ニ', pronunciationKo: '니', pronunciationEn: 'ni',
    exampleHiragana: 'にく', exampleKatakana: 'ニク',
    exampleGlossKo: '고기', exampleGlossEn: 'meat', exampleGlossJa: '肉',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'ぬ', katakana: 'ヌ', pronunciationKo: '누', pronunciationEn: 'nu',
    exampleHiragana: 'ぬの', exampleKatakana: 'ヌノ',
    exampleGlossKo: '천', exampleGlossEn: 'cloth', exampleGlossJa: '布',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'ね', katakana: 'ネ', pronunciationKo: '네', pronunciationEn: 'ne',
    exampleHiragana: 'ねこ', exampleKatakana: 'ネコ',
    exampleGlossKo: '고양이', exampleGlossEn: 'cat', exampleGlossJa: '猫',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'の', katakana: 'ノ', pronunciationKo: '노', pronunciationEn: 'no',
    exampleHiragana: 'のり', exampleKatakana: 'ノリ',
    exampleGlossKo: '김', exampleGlossEn: 'seaweed', exampleGlossJa: '海苔',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'は', katakana: 'ハ', pronunciationKo: '하', pronunciationEn: 'ha',
    exampleHiragana: 'はな', exampleKatakana: 'ハナ',
    exampleGlossKo: '꽃', exampleGlossEn: 'flower', exampleGlossJa: '花',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'ひ', katakana: 'ヒ', pronunciationKo: '히', pronunciationEn: 'hi',
    exampleHiragana: 'ひ', exampleKatakana: 'ヒ',
    exampleGlossKo: '불', exampleGlossEn: 'fire', exampleGlossJa: '火',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'ふ', katakana: 'フ', pronunciationKo: '후', pronunciationEn: 'fu',
    exampleHiragana: 'ふね', exampleKatakana: 'フネ',
    exampleGlossKo: '배', exampleGlossEn: 'ship', exampleGlossJa: '船',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'へ', katakana: 'ヘ', pronunciationKo: '헤', pronunciationEn: 'he',
    exampleHiragana: 'へび', exampleKatakana: 'ヘビ',
    exampleGlossKo: '뱀', exampleGlossEn: 'snake', exampleGlossJa: '蛇',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'ほ', katakana: 'ホ', pronunciationKo: '호', pronunciationEn: 'ho',
    exampleHiragana: 'ほし', exampleKatakana: 'ホシ',
    exampleGlossKo: '별', exampleGlossEn: 'star', exampleGlossJa: '星',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'ま', katakana: 'マ', pronunciationKo: '마', pronunciationEn: 'ma',
    exampleHiragana: 'まめ', exampleKatakana: 'マメ',
    exampleGlossKo: '콩', exampleGlossEn: 'bean', exampleGlossJa: '豆',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'み', katakana: 'ミ', pronunciationKo: '미', pronunciationEn: 'mi',
    exampleHiragana: 'みず', exampleKatakana: 'ミズ',
    exampleGlossKo: '물', exampleGlossEn: 'water', exampleGlossJa: '水',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'む', katakana: 'ム', pronunciationKo: '무', pronunciationEn: 'mu',
    exampleHiragana: 'むし', exampleKatakana: 'ムシ',
    exampleGlossKo: '벌레', exampleGlossEn: 'insect', exampleGlossJa: '虫',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'め', katakana: 'メ', pronunciationKo: '메', pronunciationEn: 'me',
    exampleHiragana: 'め', exampleKatakana: 'メ',
    exampleGlossKo: '눈', exampleGlossEn: 'eye', exampleGlossJa: '目',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'も', katakana: 'モ', pronunciationKo: '모', pronunciationEn: 'mo',
    exampleHiragana: 'もり', exampleKatakana: 'モリ',
    exampleGlossKo: '숲', exampleGlossEn: 'forest', exampleGlossJa: '森',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'や', katakana: 'ヤ', pronunciationKo: '야', pronunciationEn: 'ya',
    exampleHiragana: 'やま', exampleKatakana: 'ヤマ',
    exampleGlossKo: '산', exampleGlossEn: 'mountain', exampleGlossJa: '山',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'ゆ', katakana: 'ユ', pronunciationKo: '유', pronunciationEn: 'yu',
    exampleHiragana: 'ゆき', exampleKatakana: 'ユキ',
    exampleGlossKo: '눈', exampleGlossEn: 'snow', exampleGlossJa: '雪',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'よ', katakana: 'ヨ', pronunciationKo: '요', pronunciationEn: 'yo',
    exampleHiragana: 'よる', exampleKatakana: 'ヨル',
    exampleGlossKo: '밤', exampleGlossEn: 'night', exampleGlossJa: '夜',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'ら', katakana: 'ラ', pronunciationKo: '라', pronunciationEn: 'ra',
    exampleHiragana: 'らくだ', exampleKatakana: 'ラクダ',
    exampleGlossKo: '낙타', exampleGlossEn: 'camel', exampleGlossJa: 'ラクダ',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'り', katakana: 'リ', pronunciationKo: '리', pronunciationEn: 'ri',
    exampleHiragana: 'りす', exampleKatakana: 'リス',
    exampleGlossKo: '다람쥐', exampleGlossEn: 'squirrel', exampleGlossJa: 'リス',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'る', katakana: 'ル', pronunciationKo: '루', pronunciationEn: 'ru',
    exampleHiragana: 'るす', exampleKatakana: 'ルス',
    exampleGlossKo: '부재', exampleGlossEn: 'absence', exampleGlossJa: '留守',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'れ', katakana: 'レ', pronunciationKo: '레', pronunciationEn: 're',
    exampleHiragana: 'れきし', exampleKatakana: 'レキシ',
    exampleGlossKo: '역사', exampleGlossEn: 'history', exampleGlossJa: '歴史',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'ろ', katakana: 'ロ', pronunciationKo: '로', pronunciationEn: 'ro',
    exampleHiragana: 'ろく', exampleKatakana: 'ロク',
    exampleGlossKo: '6', exampleGlossEn: 'six', exampleGlossJa: '六',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'わ', katakana: 'ワ', pronunciationKo: '와', pronunciationEn: 'wa',
    exampleHiragana: 'わに', exampleKatakana: 'ワニ',
    exampleGlossKo: '악어', exampleGlossEn: 'crocodile', exampleGlossJa: 'ワニ',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'を', katakana: 'ヲ', pronunciationKo: '오', pronunciationEn: 'wo',
    exampleHiragana: 'ほんを', exampleKatakana: 'パンを',
    exampleGlossKo: '목적어 조사', exampleGlossEn: 'object marker', exampleGlossJa: '助詞を',
  ),
  BasicCharacterKanaSourceRow(
    hiragana: 'ん', katakana: 'ン', pronunciationKo: '응', pronunciationEn: 'n',
    exampleHiragana: 'ほん', exampleKatakana: 'ホン',
    exampleGlossKo: '책', exampleGlossEn: 'book', exampleGlossJa: '本',
  ),
];

BasicCharacterLocalizedRow kanaRowToHiragana(BasicCharacterKanaSourceRow source) {
  return BasicCharacterLocalizedRow(
    character: source.hiragana,
    pronunciationKo: source.pronunciationKo,
    pronunciationEn: source.pronunciationEn,
    pronunciationJa: source.pronunciationEn,
    exampleWord: source.exampleHiragana,
    exampleGlossKo: source.exampleGlossKo,
    exampleGlossEn: source.exampleGlossEn,
    exampleGlossJa: source.exampleGlossJa,
  );
}

BasicCharacterLocalizedRow kanaRowToKatakana(BasicCharacterKanaSourceRow source) {
  return BasicCharacterLocalizedRow(
    character: source.katakana,
    pronunciationKo: source.pronunciationKo,
    pronunciationEn: source.pronunciationEn,
    pronunciationJa: source.pronunciationEn,
    exampleWord: source.exampleKatakana,
    exampleGlossKo: source.exampleGlossKo,
    exampleGlossEn: source.exampleGlossEn,
    exampleGlossJa: source.exampleGlossJa,
  );
}

const List<String> kKanaRowGroupOrder = [
  'a', 'ka', 'sa', 'ta', 'na', 'ha', 'ma', 'ya', 'ra', 'wa', 'n',
];

const List<int> kKanaRowGroupSizes = [5, 5, 5, 5, 5, 5, 5, 3, 5, 2, 1];

List<BasicCharacterLocalizedSection> groupKanaRowsIntoSections(
  List<BasicCharacterLocalizedRow> rows, {
  List<String> groupOrder = kKanaRowGroupOrder,
  List<int> groupSizes = kKanaRowGroupSizes,
}) {
  final sections = <BasicCharacterLocalizedSection>[];
  var offset = 0;
  for (var i = 0; i < groupOrder.length; i++) {
    final size = groupSizes[i];
    sections.add(
      BasicCharacterLocalizedSection(
        sectionId: groupOrder[i],
        rows: rows.sublist(offset, offset + size),
      ),
    );
    offset += size;
  }
  return sections;
}

List<BasicCharacterLocalizedSection> _sectionsFromSourceRows(
  List<BasicCharacterKanaSourceRow> sources,
  BasicCharacterLocalizedRow Function(BasicCharacterKanaSourceRow) mapper, {
  required List<String> groupOrder,
  required List<int> groupSizes,
}) {
  return groupKanaRowsIntoSections(
    [for (final row in sources) mapper(row)],
    groupOrder: groupOrder,
    groupSizes: groupSizes,
  );
}

List<BasicCharacterLocalizedSection> _singleSection(
  String sectionId,
  List<BasicCharacterKanaSourceRow> sources,
  BasicCharacterLocalizedRow Function(BasicCharacterKanaSourceRow) mapper,
) {
  return [
    BasicCharacterLocalizedSection(
      sectionId: sectionId,
      rows: [for (final row in sources) mapper(row)],
    ),
  ];
}

List<BasicCharacterLocalizedRow> buildHiraganaLocalizedRows() {
  return [
    for (final row in kBasicCharacterKanaSourceRows) kanaRowToHiragana(row),
  ];
}

List<BasicCharacterLocalizedRow> buildKatakanaLocalizedRows() {
  return [
    for (final row in kBasicCharacterKanaSourceRows) kanaRowToKatakana(row),
  ];
}

String jpnKanaTabKey(JpnKanaPronunciationTab tab) => tab.name;

List<BasicCharacterLocalizedSection> buildHiraganaLocalizedSections() {
  return buildHiraganaSectionsByTab()[jpnKanaTabKey(JpnKanaPronunciationTab.seion)]!;
}

List<BasicCharacterLocalizedSection> buildKatakanaLocalizedSections() {
  return buildKatakanaSectionsByTab()[jpnKanaTabKey(JpnKanaPronunciationTab.seion)]!;
}

Map<String, List<BasicCharacterLocalizedSection>> buildHiraganaSectionsByTab() {
  return {
    jpnKanaTabKey(JpnKanaPronunciationTab.seion): groupKanaRowsIntoSections(
      buildHiraganaLocalizedRows(),
    ),
    jpnKanaTabKey(JpnKanaPronunciationTab.dakuon): _sectionsFromSourceRows(
      kBasicCharacterKanaDakuonRows,
      kanaRowToHiragana,
      groupOrder: kKanaDakuonGroupOrder,
      groupSizes: kKanaDakuonGroupSizes,
    ),
    jpnKanaTabKey(JpnKanaPronunciationTab.handakuon): _sectionsFromSourceRows(
      kBasicCharacterKanaHandakuonRows,
      kanaRowToHiragana,
      groupOrder: kKanaHandakuonGroupOrder,
      groupSizes: kKanaHandakuonGroupSizes,
    ),
    jpnKanaTabKey(JpnKanaPronunciationTab.youon): _sectionsFromSourceRows(
      kBasicCharacterKanaYouonRows,
      kanaRowToHiragana,
      groupOrder: kKanaYouonGroupOrder,
      groupSizes: kKanaYouonGroupSizes,
    ),
    jpnKanaTabKey(JpnKanaPronunciationTab.sokuon): _singleSection(
      'sokuon',
      kBasicCharacterKanaSokuonRows,
      kanaRowToHiragana,
    ),
    jpnKanaTabKey(JpnKanaPronunciationTab.chouon): _singleSection(
      'chouon',
      kBasicCharacterKanaChouonRows,
      kanaRowToHiragana,
    ),
  };
}

Map<String, List<BasicCharacterLocalizedSection>> buildKatakanaSectionsByTab() {
  return {
    jpnKanaTabKey(JpnKanaPronunciationTab.seion): groupKanaRowsIntoSections(
      buildKatakanaLocalizedRows(),
    ),
    jpnKanaTabKey(JpnKanaPronunciationTab.dakuon): _sectionsFromSourceRows(
      kBasicCharacterKanaDakuonRows,
      kanaRowToKatakana,
      groupOrder: kKanaDakuonGroupOrder,
      groupSizes: kKanaDakuonGroupSizes,
    ),
    jpnKanaTabKey(JpnKanaPronunciationTab.handakuon): _sectionsFromSourceRows(
      kBasicCharacterKanaHandakuonRows,
      kanaRowToKatakana,
      groupOrder: kKanaHandakuonGroupOrder,
      groupSizes: kKanaHandakuonGroupSizes,
    ),
    jpnKanaTabKey(JpnKanaPronunciationTab.youon): _sectionsFromSourceRows(
      kBasicCharacterKanaYouonRows,
      kanaRowToKatakana,
      groupOrder: kKanaYouonGroupOrder,
      groupSizes: kKanaYouonGroupSizes,
    ),
    jpnKanaTabKey(JpnKanaPronunciationTab.sokuon): _singleSection(
      'sokuon',
      kBasicCharacterKanaSokuonRows,
      kanaRowToKatakana,
    ),
    jpnKanaTabKey(JpnKanaPronunciationTab.chouon): _singleSection(
      'chouon',
      kBasicCharacterKanaChouonRows,
      kanaRowToKatakana,
    ),
  };
}
