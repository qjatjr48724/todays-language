import '../../models/basic_character_entry.dart';
import 'basic_character_kana_rows.dart';

const String kBasicCharacterChartIdJpnHiragana = 'jpn_hiragana';

/// 일본어 히라가나 — あ행·か行… 구역별 3열 표.
final BasicCharacterChartOption kBasicCharacterJpnHiraganaChart =
    BasicCharacterChartOption(
  id: kBasicCharacterChartIdJpnHiragana,
  localizedSections: buildHiraganaLocalizedSections(),
);
