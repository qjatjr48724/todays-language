import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/support_portal_config.dart';
import '../../l10n/app_localizations.dart';
import '../../services/analytics/analytics_navigation.dart';
import '../../services/analytics/analytics_screens.dart';
import '../../services/support/support_inquiry_labels.dart';
import '../../services/support/support_inquiry_repository.dart';
import 'support_inquiry_detail_screen.dart';


/// 설정 — 문의 내역 목록.
class SupportInquiriesScreen extends StatelessWidget {
  const SupportInquiriesScreen({super.key});


  Future<void> _openSupportPortal(BuildContext context) async {
    final uri = Uri.parse(supportPortalLoginUrl());
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.support_portal_open_failed)),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.support_inquiries_screen_title)),
        body: Center(child: Text(l10n.my_info_login_required)),
      );
    }

    final repo = SupportInquiryRepository();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.support_inquiries_screen_title)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openSupportPortal(context),
        icon: const Icon(Icons.open_in_new),
        label: Text(l10n.support_inquiries_new_button),
      ),
      body: StreamBuilder<List<SupportInquiry>>(
        stream: repo.watchMyInquiries(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(l10n.support_inquiries_load_failed));
          }

          final items = snapshot.data ?? const [];
          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.support_inquiries_empty,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.support_inquiries_web_hint,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                child: ListTile(
                  title: Text(item.subject),
                  subtitle: Text(
                    '${supportInquiryCategoryLabel(l10n, item.category)} · '
                    '${supportInquiryStatusLabel(l10n, item.status)}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    pushAnalyticsScreen(
                      context,
                      screenName: AnalyticsScreens.supportInquiryDetail,
                      builder: (_) => SupportInquiryDetailScreen(inquiryId: item.id),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
