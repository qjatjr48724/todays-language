import '../l10n/app_localizations.dart';

/// 영어 알파벳 행 예시 — `단어 뜻` 형식, [AppLocalizations]로 UI 로케일별 제공.
class BasicCharacterEngExample {
  BasicCharacterEngExample._();

  static String forLetter(AppLocalizations l10n, String letter) {
    switch (letter.toUpperCase()) {
      case 'A':
        return l10n.basic_characters_eng_example_a;
      case 'B':
        return l10n.basic_characters_eng_example_b;
      case 'C':
        return l10n.basic_characters_eng_example_c;
      case 'D':
        return l10n.basic_characters_eng_example_d;
      case 'E':
        return l10n.basic_characters_eng_example_e;
      case 'F':
        return l10n.basic_characters_eng_example_f;
      case 'G':
        return l10n.basic_characters_eng_example_g;
      case 'H':
        return l10n.basic_characters_eng_example_h;
      case 'I':
        return l10n.basic_characters_eng_example_i;
      case 'J':
        return l10n.basic_characters_eng_example_j;
      case 'K':
        return l10n.basic_characters_eng_example_k;
      case 'L':
        return l10n.basic_characters_eng_example_l;
      case 'M':
        return l10n.basic_characters_eng_example_m;
      case 'N':
        return l10n.basic_characters_eng_example_n;
      case 'O':
        return l10n.basic_characters_eng_example_o;
      case 'P':
        return l10n.basic_characters_eng_example_p;
      case 'Q':
        return l10n.basic_characters_eng_example_q;
      case 'R':
        return l10n.basic_characters_eng_example_r;
      case 'S':
        return l10n.basic_characters_eng_example_s;
      case 'T':
        return l10n.basic_characters_eng_example_t;
      case 'U':
        return l10n.basic_characters_eng_example_u;
      case 'V':
        return l10n.basic_characters_eng_example_v;
      case 'W':
        return l10n.basic_characters_eng_example_w;
      case 'X':
        return l10n.basic_characters_eng_example_x;
      case 'Y':
        return l10n.basic_characters_eng_example_y;
      case 'Z':
        return l10n.basic_characters_eng_example_z;
      default:
        return '';
    }
  }
}
