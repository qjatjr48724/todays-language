import 'package:shared_preferences/shared_preferences.dart';

/// 이메일 로그인 화면의 「아이디 저장」 — 이메일만 보관(비밀번호 미저장).
class SavedLoginEmail {
  SavedLoginEmail._();

  static const prefsKeyEmail = 'saved_login_email';
  static const prefsKeyRemember = 'saved_login_email_remember';


  /// 저장된 이메일과 체크 여부. remember가 false이거나 이메일이 비면 null.
  static Future<({String email, bool remember})?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool(prefsKeyRemember) ?? false;
    final email = (prefs.getString(prefsKeyEmail) ?? '').trim();
    if (!remember || email.isEmpty) return null;
    return (email: email, remember: true);
  }


  /// 로그인 성공 후 반영. remember=false면 저장된 값을 지운다.
  static Future<void> persistAfterLogin({
    required bool remember,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = email.trim();
    if (!remember || trimmed.isEmpty) {
      await prefs.remove(prefsKeyEmail);
      await prefs.setBool(prefsKeyRemember, false);
      return;
    }
    await prefs.setString(prefsKeyEmail, trimmed);
    await prefs.setBool(prefsKeyRemember, true);
  }
}
