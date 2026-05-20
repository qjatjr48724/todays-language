import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'screens/login_screen.dart';
import 'screens/main_nav_screen.dart';
import 'screens/language_setup_screen.dart';
import 'screens/target_language_setup_screen.dart';

/// 로그인 여부는 [authStateChanges] 스트림, 프로필(언어 설정)은 uid당 [get] 1회로 분기합니다.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _profileUid;
  Future<DocumentSnapshot<Map<String, dynamic>>>? _profileFuture;

  /// 동일 uid에 대해 프로필 조회 Future를 재사용합니다(AuthGate rebuild 시 중복 get 방지).
  void _ensureProfileFuture(String uid) {
    if (_profileUid == uid && _profileFuture != null) return;
    _profileUid = uid;
    _profileFuture =
        FirebaseFirestore.instance.collection('users').doc(uid).get();
  }

  void _clearProfileFuture() {
    _profileUid = null;
    _profileFuture = null;
  }

  Widget _buildProfileGate(User user) {
    _ensureProfileFuture(user.uid);
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: _profileFuture,
      builder: (context, profSnap) {
        if (profSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (profSnap.hasError) {
          final l10n = AppLocalizations.of(context)!;
          final detail = profSnap.error?.toString() ?? '';
          return Scaffold(
            body: Center(
              child: Text(
                l10n.setup_load_failed(
                  detail.isEmpty ? '-' : detail,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final data = profSnap.data?.data() ?? <String, dynamic>{};
        final languageSetupDone =
            (data['languageSetupDone'] as bool?) ?? false;
        final nativeLanguage =
            (data['nativeLanguage'] as String?)?.trim() ?? '';
        final targetLanguage =
            (data['targetLanguage'] as String?)?.trim() ?? '';

        if (languageSetupDone) {
          if (targetLanguage.isEmpty) {
            return const TargetLanguageSetupScreen();
          }
          return const MainNavScreen();
        }

        if (nativeLanguage.isNotEmpty) {
          return const TargetLanguageSetupScreen();
        }
        return const LanguageSetupScreen();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return _buildProfileGate(snapshot.data!);
        }
        _clearProfileFuture();
        return const LoginScreen();
      },
    );
  }
}
