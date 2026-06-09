/// 언어별 채팅방 메시지 — `chat_rooms/{targetLanguage}/messages/{id}`
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.uid,
    required this.displayName,
    required this.text,
    required this.createdAtMs,
    required this.targetLanguage,
  });

  final String id;
  final String uid;
  final String displayName;
  final String text;
  final int createdAtMs;
  final String targetLanguage;

  static const int maxTextLength = 500;

  factory ChatMessage.fromFirestore(String id, Map<String, dynamic> data) {
    return ChatMessage(
      id: id,
      uid: (data['uid'] as String?)?.trim() ?? '',
      displayName: (data['displayName'] as String?)?.trim() ?? '',
      text: (data['text'] as String?)?.trim() ?? '',
      createdAtMs: _readCreatedAtMs(data['createdAtMs']),
      targetLanguage: (data['targetLanguage'] as String?)?.trim().toUpperCase() ?? '',
    );
  }

  /// 전송 전 본문 정규화·길이 검증
  static String? validateOutgoingText(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    if (text.length > maxTextLength) return null;
    return text;
  }

  Map<String, dynamic> toFirestoreCreate({
    required String uid,
    required String displayName,
    required String targetLanguage,
    required int createdAtMs,
  }) {
    return {
      'uid': uid,
      'displayName': displayName,
      'text': text,
      'createdAtMs': createdAtMs,
      'targetLanguage': targetLanguage.toUpperCase(),
    };
  }

  static int _readCreatedAtMs(Object? raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return 0;
  }
}
