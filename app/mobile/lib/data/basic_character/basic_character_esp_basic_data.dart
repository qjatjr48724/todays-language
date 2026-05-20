import '../../models/basic_character_entry.dart';

const String kBasicCharacterChartIdEspBasic = 'esp_basic';

/// 스페인어 기초 문자표.
const BasicCharacterChartOption kBasicCharacterEspBasicChart =
    BasicCharacterChartOption(
  id: kBasicCharacterChartIdEspBasic,
  entries: [
    BasicCharacterEntry(character: 'ñ', pronunciation: '/ɲ/', orthography: 'eñe · año'),
    BasicCharacterEntry(character: 'á', pronunciation: '/a/', orthography: 'tilde aguda · más'),
    BasicCharacterEntry(character: 'é', pronunciation: '/e/', orthography: 'tilde aguda · café'),
    BasicCharacterEntry(character: 'í', pronunciation: '/i/', orthography: 'tilde aguda · sí'),
    BasicCharacterEntry(character: 'ó', pronunciation: '/o/', orthography: 'tilde aguda · sólo'),
    BasicCharacterEntry(character: 'ú', pronunciation: '/u/', orthography: 'tilde aguda · tú'),
    BasicCharacterEntry(character: 'ü', pronunciation: '/w/', orthography: 'diéresis · pingüino'),
    BasicCharacterEntry(character: '¿', pronunciation: '—', orthography: 'signo de apertura'),
    BasicCharacterEntry(character: '¡', pronunciation: '—', orthography: 'signo de apertura'),
  ],
);
