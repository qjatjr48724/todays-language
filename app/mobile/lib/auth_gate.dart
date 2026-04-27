import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'screens/main_nav_screen.dart';
import 'screens/language_setup_screen.dart';
import 'screens/target_language_setup_screen.dart';

/// 로그인 여부에 따라 로그인 화면 또는 홈을 보여줍니다.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

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
          final user = snapshot.data!;
          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, profSnap) {
              if (profSnap.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              final data = profSnap.data?.data() ?? <String, dynamic>{};
              final done = (data['languageSetupDone'] as bool?) ?? false;
              if (!done) {
                final hasNative = (data['nativeLanguage'] as String?)?.trim().isNotEmpty ?? false;
                if (hasNative) return const TargetLanguageSetupScreen();
                return const LanguageSetupScreen();
              }
              return const MainNavScreen();
            },
          );
        }
        return const LoginScreen();
      },
    );
  }
}
