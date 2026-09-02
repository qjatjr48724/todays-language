import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/support/support_inquiry_labels.dart';
import '../services/support/support_inquiry_repository.dart';


/// 문의 상세 — 본인 문의와 답변 스레드 조회.
class SupportInquiryDetailScreen extends StatelessWidget {
  const SupportInquiryDetailScreen({super.key, required this.inquiryId});

  final String inquiryId;


  String _formatDateTime(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.support_inquiry_detail_title)),
        body: Center(child: Text(l10n.my_info_login_required)),
      );
    }

    final repo = SupportInquiryRepository();

    return Scaffold(
      appBar: AppBar(title: Text(l10n.support_inquiry_detail_title)),
      body: StreamBuilder<SupportInquiry?>(
        stream: repo.watchInquiry(inquiryId),
        builder: (context, inquirySnapshot) {
          if (inquirySnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (inquirySnapshot.hasError || inquirySnapshot.data == null) {
            return Center(child: Text(l10n.support_inquiries_load_failed));
          }

          final inquiry = inquirySnapshot.data!;

          return StreamBuilder<List<SupportInquiryMessage>>(
            stream: repo.watchInquiryMessages(inquiryId),
            builder: (context, messagesSnapshot) {
              if (messagesSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (messagesSnapshot.hasError) {
                return Center(child: Text(l10n.support_inquiries_load_failed));
              }

              final messages = messagesSnapshot.data ?? const [];

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    inquiry.subject,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${supportInquiryCategoryLabel(l10n, inquiry.category)} · '
                    '${supportInquiryStatusLabel(l10n, inquiry.status)} · '
                    '${_formatDateTime(inquiry.createdAtMs)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 24),
                  for (final message in messages) ...[
                    Align(
                      alignment: message.authorType == 'admin'
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 320),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: message.authorType == 'admin'
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.authorType == 'admin'
                                  ? l10n.support_inquiry_message_admin
                                  : l10n.support_inquiry_message_user,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(message.text),
                            const SizedBox(height: 4),
                            Text(
                              _formatDateTime(message.createdAtMs),
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              );
            },
          );
        },
      ),
    );
  }
}
