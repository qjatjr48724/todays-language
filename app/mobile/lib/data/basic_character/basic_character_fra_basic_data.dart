import '../../models/basic_character_entry.dart';

const String kBasicCharacterChartIdFraBasic = 'fra_basic';

/// 프랑스어 기초 문자표.
const BasicCharacterChartOption kBasicCharacterFraBasicChart =
    BasicCharacterChartOption(
  id: kBasicCharacterChartIdFraBasic,
  entries: [
    BasicCharacterEntry(character: 'é', pronunciation: '/e/', orthography: 'accent aigu · été'),
    BasicCharacterEntry(character: 'è', pronunciation: '/ɛ/', orthography: 'accent grave · père'),
    BasicCharacterEntry(character: 'ê', pronunciation: '/ɛ/', orthography: 'accent circonflexe · fête'),
    BasicCharacterEntry(character: 'ë', pronunciation: '/ɛ/', orthography: 'tréma · Noël'),
    BasicCharacterEntry(character: 'à', pronunciation: '/a/', orthography: 'grave · là'),
    BasicCharacterEntry(character: 'â', pronunciation: '/ɑ/', orthography: 'circonflexe · pâte'),
    BasicCharacterEntry(character: 'ù', pronunciation: '/y/', orthography: 'grave · où'),
    BasicCharacterEntry(character: 'û', pronunciation: '/y/', orthography: 'circonflexe · sûr'),
    BasicCharacterEntry(character: 'ü', pronunciation: '/y/', orthography: 'tréma · français rare'),
    BasicCharacterEntry(character: 'ô', pronunciation: '/o/', orthography: 'circonflexe · hôtel'),
    BasicCharacterEntry(character: 'î', pronunciation: '/i/', orthography: 'circonflexe · île'),
    BasicCharacterEntry(character: 'ï', pronunciation: '/i/', orthography: 'tréma · naïf'),
    BasicCharacterEntry(character: 'ç', pronunciation: '/s/', orthography: 'cédille · français'),
    BasicCharacterEntry(character: 'œ', pronunciation: '/œ/', orthography: 'ligature · œuf'),
    BasicCharacterEntry(character: 'æ', pronunciation: '/ɛ/', orthography: 'ligature · curriculum vitæ'),
  ],
);
