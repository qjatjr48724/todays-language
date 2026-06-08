import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/target_language_picker.dart';
import 'admin_tools_screen.dart';
import 'notification_settings_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';


/// 앱 설정 — 언어·알림·약관·관리자 도구.
class SettingsScreen extends StatelessWidget {
    const SettingsScreen({super.key});

    static const _testAdminUid = AdminToolsScreen.testAdminUid;


    Widget _settingsTile({
        required BuildContext context,
        required IconData icon,
        required String title,
        String? subtitle,
        required VoidCallback onTap,
    }) {
        return Card(
            child: ListTile(
                leading: Icon(icon),
                title: Text(title),
                subtitle: subtitle == null ? null : Text(subtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: onTap,
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
                        _settingsTile(
                            context: context,
                            icon: Icons.language,
                            title: l10n.settings_language_change_tile,
                            subtitle: l10n.settings_language_change_subtitle,
                            onTap: () => openTargetLanguagePicker(context),
                        ),
                        const SizedBox(height: 12),
                        _settingsTile(
                            context: context,
                            icon: Icons.notifications_outlined,
                            title: l10n.settings_notification_tile,
                            subtitle: l10n.settings_notification_subtitle,
                            onTap: () {
                                Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const NotificationSettingsScreen(),
                                    ),
                                );
                            },
                        ),
                        const SizedBox(height: 12),
                        _settingsTile(
                            context: context,
                            icon: Icons.privacy_tip_outlined,
                            title: l10n.privacy_policy_screen_title,
                            onTap: () {
                                PrivacyPolicyScreen.open(
                                    context,
                                    readOnly: true,
                                );
                            },
                        ),
                        const SizedBox(height: 12),
                        _settingsTile(
                            context: context,
                            icon: Icons.description_outlined,
                            title: l10n.terms_of_service_screen_title,
                            onTap: () {
                                TermsOfServiceScreen.open(
                                    context,
                                    readOnly: true,
                                );
                            },
                        ),
                        if (isAdmin) ...[
                            const SizedBox(height: 12),
                            _settingsTile(
                                context: context,
                                icon: Icons.admin_panel_settings_outlined,
                                title: l10n.settings_admin_tile,
                                subtitle: l10n.settings_admin_subtitle,
                                onTap: () {
                                    Navigator.of(context).push(
                                        MaterialPageRoute<void>(
                                            builder: (_) =>
                                                const AdminToolsScreen(),
                                        ),
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
