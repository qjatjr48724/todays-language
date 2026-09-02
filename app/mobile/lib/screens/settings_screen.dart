import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/support_portal_config.dart';
import '../l10n/app_localizations.dart';
import '../services/analytics/analytics_navigation.dart';
import '../services/analytics/analytics_screens.dart';
import '../services/target_language_picker.dart';
import 'admin_tools_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'support_inquiries_screen.dart';
import 'terms_of_service_screen.dart';


/// 앱 설정 — 언어·알림·약관·관리자 도구.
class SettingsScreen extends StatelessWidget {
    const SettingsScreen({super.key});

    static const _testAdminUid = AdminToolsScreen.testAdminUid;

    static const _titleFontSize = 12.8;


    Widget _settingsButton({
        required BuildContext context,
        required IconData icon,
        required String title,
        required VoidCallback onPressed,
    }) {
        final theme = Theme.of(context);
        return SizedBox(
            width: double.infinity,
            child: FilledButton(
                onPressed: onPressed,
                style: FilledButton.styleFrom(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                    ),
                ),
                child: Row(
                    children: [
                        Icon(icon, size: 22),
                        Expanded(
                            child: Text(
                                title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontSize: _titleFontSize,
                                ),
                            ),
                        ),
                        Icon(
                            Icons.chevron_right,
                            size: 22,
                            color: theme.colorScheme.onPrimary
                                .withValues(alpha: 0.85),
                        ),
                    ],
                ),
            ),
        );
    }


    @override
    Widget build(BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        final user = FirebaseAuth.instance.currentUser;
        final isAdmin = user?.uid == _testAdminUid;

        return Scaffold(
            appBar: AppBar(title: Text(l10n.settings_screen_title)),
            body: SafeArea(
                child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                        _settingsButton(
                            context: context,
                            icon: Icons.language,
                            title: l10n.settings_language_change_tile,
                            onPressed: () => openTargetLanguagePicker(context),
                        ),
                        const SizedBox(height: 12),
                        _settingsButton(
                            context: context,
                            icon: Icons.notifications_outlined,
                            title: l10n.settings_notification_tile,
                            onPressed: () {
                                pushAnalyticsScreen(
                                    context,
                                    screenName: AnalyticsScreens.notificationSettings,
                                    builder: (_) =>
                                        const NotificationSettingsScreen(),
                                );
                            },
                        ),
                        const SizedBox(height: 12),
                        _settingsButton(
                            context: context,
                            icon: Icons.mail_outline,
                            title: l10n.settings_support_new_tile,
                            onPressed: () async {
                                final uri = Uri.parse(supportPortalLoginUrl());
                                final launched = await launchUrl(
                                    uri,
                                    mode: LaunchMode.externalApplication,
                                );
                                if (!launched && context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                l10n.support_portal_open_failed,
                                            ),
                                        ),
                                    );
                                }
                            },
                        ),
                        const SizedBox(height: 12),
                        _settingsButton(
                            context: context,
                            icon: Icons.support_agent_outlined,
                            title: l10n.settings_support_inquiries_tile,
                            onPressed: () {
                                pushAnalyticsScreen(
                                    context,
                                    screenName: AnalyticsScreens.supportInquiries,
                                    builder: (_) =>
                                        const SupportInquiriesScreen(),
                                );
                            },
                        ),
                        const SizedBox(height: 12),
                        _settingsButton(
                            context: context,
                            icon: Icons.privacy_tip_outlined,
                            title: l10n.privacy_policy_screen_title,
                            onPressed: () {
                                PrivacyPolicyScreen.open(
                                    context,
                                    readOnly: true,
                                );
                            },
                        ),
                        const SizedBox(height: 12),
                        _settingsButton(
                            context: context,
                            icon: Icons.description_outlined,
                            title: l10n.terms_of_service_screen_title,
                            onPressed: () {
                                TermsOfServiceScreen.open(
                                    context,
                                    readOnly: true,
                                );
                            },
                        ),
                        if (isAdmin) ...[
                            const SizedBox(height: 12),
                            _settingsButton(
                                context: context,
                                icon: Icons.admin_panel_settings_outlined,
                                title: l10n.settings_admin_tile,
                                onPressed: () {
                                    pushAnalyticsScreen(
                                        context,
                                        screenName: AnalyticsScreens.adminTools,
                                        builder: (_) =>
                                            const AdminToolsScreen(),
                                    );
                                },
                            ),
                        ],
                    ],
                ),
            ),
        );
    }
}
