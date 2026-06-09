import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/chat_message.dart';
import 'user_profile_sync.dart';

/// 언어별 공개 채팅방 — `chat_rooms/{targetLanguage}/messages`
class ChatRepository {
  ChatRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  static const int messagePageSize = 100;

  CollectionReference<Map<String, dynamic>> _messagesRef(String targetLanguage) {
    final roomId = targetLanguage.trim().toUpperCase();
    return _db.collection('chat_rooms').doc(roomId).collection('messages');
  }

  /// 로그인 사용자의 학습 언어(alpha-3) 조회
  Future<String?> loadUserTargetLanguage() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final snap = await _db.collection('users').doc(user.uid).get();
    final raw = (snap.data()?['targetLanguage'] as String?)?.trim().toUpperCase();
    if (raw == null || raw.isEmpty) return null;
    if (!isTargetLanguageSelectable(raw)) return null;
    return raw;
  }

  /// 최근 메시지 실시간 스트림(오래된 순으로 UI에 표시)
  Stream<List<ChatMessage>> watchRecentMessages(String targetLanguage) {
    return _messagesRef(targetLanguage)
        .orderBy('createdAtMs', descending: true)
        .limit(messagePageSize)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => ChatMessage.fromFirestore(d.id, d.data()))
          .where((m) => m.text.isNotEmpty)
          .toList();
      return list.reversed.toList();
    });
  }

  /// 텍스트 메시지 전송
  Future<void> sendMessage({
    required String targetLanguage,
    required String text,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('not_signed_in');
    }
    final normalized = ChatMessage.validateOutgoingText(text);
    if (normalized == null) {
      throw ArgumentError('invalid_message_text');
    }
    final roomId = targetLanguage.trim().toUpperCase();
    if (!isTargetLanguageSelectable(roomId)) {
      throw ArgumentError('invalid_target_language');
    }

    final profileSnap = await _db.collection('users').doc(user.uid).get();
    final profile = profileSnap.data() ?? <String, dynamic>{};
    final profileTarget = (profile['targetLanguage'] as String?)?.trim().toUpperCase();
    if (profileTarget != roomId) {
      throw StateError('target_language_mismatch');
    }

    final displayName = _resolveDisplayName(user, profile);
    final payload = ChatMessage(
      id: '',
      uid: user.uid,
      displayName: displayName,
      text: normalized,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
      targetLanguage: roomId,
    ).toFirestoreCreate(
      uid: user.uid,
      displayName: displayName,
      targetLanguage: roomId,
      createdAtMs: DateTime.now().millisecondsSinceEpoch,
    );

    await _messagesRef(roomId).add(payload);
  }

  String _resolveDisplayName(User user, Map<String, dynamic> profile) {
    final fromProfile = (profile['displayName'] as String?)?.trim();
    if (fromProfile != null && fromProfile.isNotEmpty) return fromProfile;
    final fromAuth = user.displayName?.trim();
    if (fromAuth != null && fromAuth.isNotEmpty) return fromAuth;
    final email = user.email?.trim();
    if (email != null && email.contains('@')) {
      return email.split('@').first;
    }
    return 'User';
  }
}
