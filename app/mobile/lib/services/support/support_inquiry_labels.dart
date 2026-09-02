import '../../l10n/app_localizations.dart';


String supportInquiryCategoryLabel(AppLocalizations l10n, String category) {
  switch (category) {
    case 'bug':
      return l10n.support_inquiry_category_bug;
    case 'account':
      return l10n.support_inquiry_category_account;
    case 'suggestion':
      return l10n.support_inquiry_category_suggestion;
    default:
      return l10n.support_inquiry_category_other;
  }
}


String supportInquiryStatusLabel(AppLocalizations l10n, String status) {
  switch (status) {
    case 'answered':
      return l10n.support_inquiry_status_answered;
    case 'closed':
      return l10n.support_inquiry_status_closed;
    default:
      return l10n.support_inquiry_status_open;
  }
}
