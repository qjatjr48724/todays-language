import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// [docs/FIRESTORE_MIN_SCHEMA.md]의 `users/{uid}` 최소 필드를 맞춥니다.
Future<void> ensureUserProfileDocument(User user) async {
  final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final exists = (await doc.get()).exists;

  final data = <String, dynamic>{
    'email': user.email,
    'displayName': user.displayName ?? '',
    'provider': _providerLabel(user),
    'nativeLanguage': 'ko',
    'targetLanguage': 'ja',
    'timezone': 'Asia/Seoul',
    'lastLoginAt': FieldValue.serverTimestamp(),
  };

  if (!exists) {
    data['createdAt'] = FieldValue.serverTimestamp();
  }

  await doc.set(data, SetOptions(merge: true));
}

String _providerLabel(User user) {
  if (user.providerData.isEmpty) return 'unknown';
  switch (user.providerData.first.providerId) {
    case 'password':
      return 'email';
    case 'google.com':
      return 'google';
    case 'apple.com':
      return 'apple';
    default:
      return user.providerData.first.providerId;
  }
}
