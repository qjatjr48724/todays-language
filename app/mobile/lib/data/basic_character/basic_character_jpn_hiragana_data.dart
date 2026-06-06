import '../../models/basic_character_entry.dart';
import 'basic_character_kana_rows.dart';

const String kBasicCharacterChartIdJpnHiragana = 'jpn_hiragana';

/// 일본어 히라가나 — 청음·탁음·반탁음·요음·촉음·장음 탭별 3열 표.
final BasicCharacterChartOption kBasicCharacterJpnHiraganaChart =
    BasicCharacterChartOption(
  id: kBasicCharacterChartIdJpnHiragana,
  localizedSections: buildHiraganaLocalizedSections(),
  jpnKanaSectionsByTab: buildHiraganaSectionsByTab(),
);
