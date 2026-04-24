import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// [docs/FIRESTORE_MIN_SCHEMA.md]의 `users/{uid}` 최소 필드를 맞춥니다.
Future<void> ensureUserProfileDocument(User user) async {
  final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final snap = await doc.get();
  final exists = snap.exists;
  final current = snap.data() ?? <String, dynamic>{};

  String normalizeAlpha3OrDefault(String? raw, {required String fallback}) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return fallback;
    // alpha-2 → alpha-3 정규화 (레거시 데이터 정리)
    switch (v.toLowerCase()) {
      case 'ko':
        return 'KOR';
      case 'ja':
        return 'JPN';
      case 'es':
        return 'ESP';
      default:
        return v.toUpperCase();
    }
  }

  final nativeLanguage = normalizeAlpha3OrDefault(
    current['nativeLanguage'] as String?,
    fallback: 'KOR',
  );
  final targetLanguage = normalizeAlpha3OrDefault(
    current['targetLanguage'] as String?,
    fallback: 'JPN',
  );

  final data = <String, dynamic>{
    'email': user.email,
    'displayName': user.displayName ?? '',
    'provider': _providerLabel(user),
    // ISO-3166-1 alpha-3 (국가 코드) 표기 사용: JPN/ESP/...
    'nativeLanguage': nativeLanguage,
    'targetLanguage': targetLanguage,
    'timezone': 'Asia/Seoul',
    'lastLoginAt': FieldValue.serverTimestamp(),

    // 레거시 필드 정리(구버전 가입 폼/실험용 필드 제거)
    'birthDate': FieldValue.delete(),
    'phoneNumber': FieldValue.delete(),
    'termsAgreed': FieldValue.delete(),
    'privacyAgreed': FieldValue.delete(),
    'registerMethod': FieldValue.delete(),
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
