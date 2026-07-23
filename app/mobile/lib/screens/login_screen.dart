import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'email_login_screen.dart';
import 'main_nav_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/analytics/analytics_action_log.dart';
import '../services/analytics/analytics_navigation.dart';
import '../services/analytics/analytics_screens.dart';
import '../services/analytics/tracked_scaffold.dart';
import '../services/auth_session_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSub;

  /// 디버그 전용 테스트 계정 — 릴리즈 빌드에는 UI·호출 경로 없음
  static const _testEmail = 'test@test.com';
  static const _testPassword = 'test1234';

  @override
  void initState() {
    super.initState();
    // AuthGate 바깥에서 LoginScreen이 열리는 경우에도, 로그인 성공 시 홈으로 전환되게 합니다.
    _authSub = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) return;
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavScreen()),
      );
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }


  /// 테스트 계정 로그인 — 없으면 자동 가입 후 로그인
  Future<void> _signInTestAccount() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await logAuthAttempt('debug_test');
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _testEmail,
        password: _testPassword,
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await AuthSessionService().claimSession(user);
      }
      await logAuthResult(authMethod: 'debug_test', success: true);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _testEmail,
          password: _testPassword,
        );
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _testEmail,
          password: _testPassword,
        );
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await AuthSessionService().claimSession(user);
        }
        await logAuthResult(authMethod: 'debug_test', success: true);
        return;
      }
      if (!mounted) return;
      await logAuthResult(authMethod: 'debug_test', success: false);
      setState(() => _errorMessage = _messageForAuthException(e, context));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.login_test_unknown_error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return trackedScaffold(
      screenName: AnalyticsScreens.login,
      scaffold: Scaffold(
      appBar: AppBar(title: Text(l10n.login_appbar_title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.login_welcome_title, style: t.headlineSmall),
              const SizedBox(height: 6),
              Text(
                l10n.login_welcome_subtitle,
                style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _loading
                    ? null
                    : () {
                        pushAnalyticsScreen(
                          context,
                          screenName: AnalyticsScreens.emailLogin,
                          builder: (_) => const EmailLoginScreen(),
                        );
                      },
                child: Text(l10n.login_email_button),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: scheme.error),
                ),
              ],
              if (kDebugMode) ...[
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _signInTestAccount,
                  icon: const Icon(Icons.bolt),
                  label: Text(l10n.login_debug_test_login),
                ),
              ],
            ],
          ),
        ),
      ),
    ),
    );
  }
}


String _messageForAuthException(FirebaseAuthException e, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  switch (e.code) {
    case 'invalid-email':
      return l10n.login_error_invalid_email;
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return l10n.login_error_credentials;
    case 'too-many-requests':
      return l10n.login_error_too_many_requests;
    default:
      return l10n.login_error_unknown(e.code);
  }
}
