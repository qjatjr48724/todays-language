import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  Widget _menuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.community_tab_title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _menuTile(
              icon: Icons.forum_outlined,
              title: l10n.community_menu_chat,
              subtitle: l10n.community_menu_chat_subtitle,
              onTap: null,
            ),
            const SizedBox(height: 12),
            _menuTile(
              icon: Icons.verified_outlined,
              title: l10n.community_menu_certificates,
              subtitle: l10n.community_menu_certificates_subtitle,
              onTap: null,
            ),
            const SizedBox(height: 12),
            _menuTile(
              icon: Icons.menu_book_outlined,
              title: l10n.community_menu_phrase_guide,
              subtitle: l10n.community_menu_phrase_guide_subtitle,
              onTap: null,
            ),
          ],
        ),
      ),
    );
  }
}

