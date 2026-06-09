import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/chat_repository.dart';
import 'chat_room_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key, ChatRepository? chatRepository})
      : _chatRepository = chatRepository;

  final ChatRepository? _chatRepository;

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


  Future<void> _openChatRoom(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final repo = _chatRepository ?? ChatRepository();
    final targetLanguage = await repo.loadUserTargetLanguage();
    if (!context.mounted) return;
    if (targetLanguage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.chat_language_not_ready)),
      );
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          targetLanguage: targetLanguage,
          repository: repo,
        ),
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
              onTap: () => _openChatRoom(context),
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
