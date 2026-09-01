import 'package:firebase_auth/firebase_auth.dart';

/// Functions blocking function이 던지는 재가입 차단 메시지 토큰.
const String kAccountRecreationBlockedMessageToken = 'account_recreation_blocked';

/// 탈퇴 후 7일 이내 동일 이메일 재가입 차단 오류인지 판별합니다.
bool isAccountRecreationBlockedAuthError(FirebaseAuthException e) {
  final message = e.message ?? '';
  return message.contains(kAccountRecreationBlockedMessageToken);
}
