import '../l10n/app_localizations.dart';

/// ISO-3166-1 alpha-3 대상 언어 코드를 UI 라벨로 변환한다.
String targetLanguageLabel(String code, AppLocalizations l10n) {
  switch (code.toUpperCase()) {
    case 'KOR':
      return l10n.language_kor_label;
    case 'JPN':
      return l10n.language_jpn_label;
    case 'ESP':
      return l10n.language_esp_label;
    case 'USA':
      return l10n.language_usa_label;
    default:
      return code.toUpperCase();
  }
}
