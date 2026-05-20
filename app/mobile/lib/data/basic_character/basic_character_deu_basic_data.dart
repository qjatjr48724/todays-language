import '../../models/basic_character_entry.dart';

const String kBasicCharacterChartIdDeuBasic = 'deu_basic';

/// 독일어 기초 문자표.
const BasicCharacterChartOption kBasicCharacterDeuBasicChart =
    BasicCharacterChartOption(
  id: kBasicCharacterChartIdDeuBasic,
  entries: [
    BasicCharacterEntry(character: 'ä', pronunciation: '/ɛ/', orthography: 'Umlaut · ähnlich'),
    BasicCharacterEntry(character: 'ö', pronunciation: '/ø/', orthography: 'Umlaut · schön'),
    BasicCharacterEntry(character: 'ü', pronunciation: '/y/', orthography: 'Umlaut · Tür'),
    BasicCharacterEntry(character: 'ß', pronunciation: '/s/', orthography: 'Eszett · Straße'),
    BasicCharacterEntry(character: 'A', pronunciation: '/aː/', orthography: 'Großbuchstabe'),
    BasicCharacterEntry(character: 'O', pronunciation: '/oː/', orthography: 'Großbuchstabe'),
    BasicCharacterEntry(character: 'U', pronunciation: '/uː/', orthography: 'Großbuchstabe'),
    BasicCharacterEntry(character: 'S', pronunciation: '/z/', orthography: 's- + Vokal → /z/ (Sie)'),
  ],
);
