import 'package:firebase_auth/firebase_auth.dart';

/// 계정 삭제 전 재인증 방식.
enum AccountReauthMethod {
  emailPassword,
  google,
  apple,
}


/// Firebase Auth `providerData` 기준 재인증 방식을 결정합니다.
AccountReauthMethod resolveAccountReauthMethod(User user) {
  final providerIds = user.providerData.map((p) => p.providerId).toSet();

  if (providerIds.contains('password')) {
    return AccountReauthMethod.emailPassword;
  }
  if (providerIds.contains('google.com')) {
    return AccountReauthMethod.google;
  }
  if (providerIds.contains('apple.com')) {
    return AccountReauthMethod.apple;
  }

  return AccountReauthMethod.emailPassword;
}
