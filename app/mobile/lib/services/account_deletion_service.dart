import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/firebase_functions_config.dart';
import 'account_reauth_helper.dart';
import 'auth_session_service.dart';


/// 회원 탈퇴 — 재인증 후 서버에서 Firestore·Auth 데이터를 삭제합니다.
class AccountDeletionService {
  AccountDeletionService({
    FirebaseAuth? auth,
    HttpsCallable? deleteAccountCallable,
    AuthSessionService? sessionService,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _deleteAccountCallable =
            deleteAccountCallable ?? callableDeleteAccount(),
        _sessionService = sessionService ?? AuthSessionService();


  final FirebaseAuth _auth;
  final HttpsCallable _deleteAccountCallable;
  final AuthSessionService _sessionService;


  /// 로그인 방식에 맞게 재인증합니다.
  Future<void> reauthenticate({
    required User user,
    String? password,
  }) async {
    final method = resolveAccountReauthMethod(user);

    switch (method) {
      case AccountReauthMethod.emailPassword:
        final email = user.email?.trim();
        if (email == null || email.isEmpty) {
          throw FirebaseAuthException(
            code: 'missing-email',
            message: 'email-missing',
          );
        }
        final pwd = password?.trim() ?? '';
        if (pwd.isEmpty) {
          throw FirebaseAuthException(
            code: 'missing-password',
            message: 'password-missing',
          );
        }
        final credential = EmailAuthProvider.credential(
          email: email,
          password: pwd,
        );
        await user.reauthenticateWithCredential(credential);
      case AccountReauthMethod.google:
        await user.reauthenticateWithProvider(GoogleAuthProvider());
      case AccountReauthMethod.apple:
        await user.reauthenticateWithProvider(AppleAuthProvider());
    }
  }


  /// 재인증 후 Callable로 계정·데이터를 삭제하고 로컬 세션을 정리합니다.
  Future<void> deleteAccountAfterReauth({
    required User user,
    String? password,
  }) async {
    await reauthenticate(user: user, password: password);
    await _deleteAccountCallable.call<Map<String, dynamic>>({});
    await _sessionService.clearLocalSession();
    await _auth.signOut();
  }
}
