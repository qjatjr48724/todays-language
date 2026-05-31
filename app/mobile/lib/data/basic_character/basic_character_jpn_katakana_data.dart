import '../../models/basic_character_entry.dart';
import 'basic_character_kana_rows.dart';

const String kBasicCharacterChartIdJpnKatakana = 'jpn_katakana';

/// 일본어 가타카나 — あ행·か行… 구역별 3열 표.
final BasicCharacterChartOption kBasicCharacterJpnKatakanaChart =
    BasicCharacterChartOption(
  id: kBasicCharacterChartIdJpnKatakana,
  localizedSections: buildKatakanaLocalizedSections(),
);
