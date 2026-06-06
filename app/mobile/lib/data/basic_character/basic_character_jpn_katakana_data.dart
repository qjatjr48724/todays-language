import '../../models/basic_character_entry.dart';
import 'basic_character_kana_rows.dart';

const String kBasicCharacterChartIdJpnKatakana = 'jpn_katakana';

/// 일본어 가타카나 — 청음·탁음·반탁음·요음·촉음·장음 탭별 3열 표.
final BasicCharacterChartOption kBasicCharacterJpnKatakanaChart =
    BasicCharacterChartOption(
  id: kBasicCharacterChartIdJpnKatakana,
  localizedSections: buildKatakanaLocalizedSections(),
  jpnKanaSectionsByTab: buildKatakanaSectionsByTab(),
);
