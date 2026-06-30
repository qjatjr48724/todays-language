import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/analytics/analytics_action_log.dart';
import '../l10n/app_localizations.dart';
import '../models/chat_message.dart';
import '../services/chat_repository.dart';
import '../utils/chat_message_timeline.dart';

/// 학습 언어(`targetLanguage`) 공개 채팅방 — 텍스트만 MVP
class ChatRoomScreen extends StatefulWidget {
  const ChatRoomScreen({
    super.key,
    required this.targetLanguage,
    ChatRepository? repository,
  }) : _repository = repository;

  final String targetLanguage;
  final ChatRepository? _repository;

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  late final ChatRepository _repo;
  final _inputController = TextEditingController();
  bool _sending = false;
  String? _sendError;

  @override
  void initState() {
    super.initState();
    _repo = widget._repository ?? ChatRepository();
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  String _languageLabel(AppLocalizations l10n) {
    switch (widget.targetLanguage.toUpperCase()) {
      case 'KOR':
        return l10n.language_kor_label;
      case 'USA':
        return l10n.language_usa_label;
      case 'JPN':
        return l10n.language_jpn_label;
      default:
        return widget.targetLanguage.toUpperCase();
    }
  }

  Future<void> _sendMessage() async {
    if (_sending) return;
    final l10n = AppLocalizations.of(context)!;
    final raw = _inputController.text;
    if (ChatMessage.validateOutgoingText(raw) == null) {
      setState(() {
        _sendError = raw.trim().isEmpty
            ? l10n.chat_send_empty_error
            : l10n.chat_send_too_long_error(ChatMessage.maxTextLength);
      });
      return;
    }
    setState(() {
      _sending = true;
      _sendError = null;
    });
    try {
      await _repo.sendMessage(
        targetLanguage: widget.targetLanguage,
        text: raw,
      );
      if (!mounted) return;
      _inputController.clear();
      await logChatMessageSend();
    } catch (e) {
      if (!mounted) return;
      setState(() => _sendError = l10n.chat_send_failed(e.toString()));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.chat_room_appbar_title(_languageLabel(l10n))),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _repo.watchRecentMessages(widget.targetLanguage),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.chat_load_failed(snapshot.error.toString()),
                        style: TextStyle(color: scheme.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final messages = snapshot.data ?? const <ChatMessage>[];
                if (messages.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        l10n.chat_empty_hint,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                final timeline = buildChatTimeline(messages);
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  itemCount: timeline.length,
                  itemBuilder: (context, index) {
                    final item = timeline[index];
                    if (item.type == ChatTimelineItemType.dateDivider) {
                      return _DateDivider(
                        createdAtMs: item.createdAtMs ?? 0,
                      );
                    }
                    final m = item.message!;
                    final isMine = uid != null && m.uid == uid;
                    return _MessageBubble(message: m, isMine: isMine);
                  },
                );
              },
            ),
          ),
          if (_sendError != null) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              child: Text(
                _sendError!,
                style: TextStyle(color: scheme.error, fontSize: 13),
              ),
            ),
          ],
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _inputController,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: ChatMessage.maxTextLength,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sending ? null : (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: l10n.chat_input_hint,
                        counterText: '',
                        border: const OutlineInputBorder(),
                      ),
                      enabled: !_sending,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _sendMessage,
                    icon: _sending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                    tooltip: l10n.chat_send_button,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// KST 날짜 구분선 — `----- yyyy년 mm월 dd일 -----`
class _DateDivider extends StatelessWidget {
  const _DateDivider({required this.createdAtMs});

  final int createdAtMs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final kst = kstDateTimeFromEpochMs(createdAtMs);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: Text(
          l10n.chat_date_divider(kst.year, kst.month, kst.day),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: scheme.onSurfaceVariant,
                letterSpacing: 0.2,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}


class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
  });

  final ChatMessage message;
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final align = isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isMine ? scheme.primaryContainer : scheme.surfaceContainerHighest;
    final fg = isMine ? scheme.onPrimaryContainer : scheme.onSurface;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: align,
        children: [
          if (!isMine)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Text(
                message.displayName.isNotEmpty ? message.displayName : 'User',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(isMine ? 14 : 4),
                bottomRight: Radius.circular(isMine ? 4 : 14),
              ),
            ),
            child: Text(
              message.text,
              style: TextStyle(color: fg),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: isMine ? 0 : 4,
              right: isMine ? 4 : 0,
            ),
            child: Text(
              formatKstHhMm(message.createdAtMs),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
