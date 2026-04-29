import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'email_login_screen.dart';
import '../services/user_profile_sync.dart';
import 'main_nav_screen.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String? _errorMessage;
  StreamSubscription<User?>? _authSub;

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

  String _randomNonce([int length = 32]) {
    const charset = '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final rand = Random.secure();
    return List.generate(length, (_) => charset[rand.nextInt(charset.length)]).join();
  }

  String _sha256OfString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> _signInWithGoogle() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await GoogleSignIn.instance.initialize();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception('Google ID token is missing');
      }
      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final result = await FirebaseAuth.instance.signInWithCredential(credential);
      if (result.user != null) {
        await ensureUserProfileDocument(result.user!);
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _messageForAuthException(e, context));
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.login_google_failed(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithApple() async {
    final l10n = AppLocalizations.of(context)!;
    if (!Platform.isIOS) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.login_apple_not_supported)),
      );
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final rawNonce = _randomNonce();
      final nonce = _sha256OfString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );

      final oauth = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final result = await FirebaseAuth.instance.signInWithCredential(oauth);
      if (result.user != null) {
        await ensureUserProfileDocument(result.user!);
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return;
      if (!mounted) return;
      setState(() => _errorMessage = l10n.login_apple_failed(e.message));
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _messageForAuthException(e, context));
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.login_apple_failed_generic(e.toString()));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInTestAccount() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _testEmail,
        password: _testPassword,
      );
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
        return;
      }
      if (!mounted) return;
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

    return Scaffold(
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
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const EmailLoginScreen(),
                          ),
                        );
                      },
                child: Text(l10n.login_email_button),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _loading ? null : _signInWithGoogle,
                child: Text(l10n.login_google_button),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _loading ? null : _signInWithApple,
                child: Text(l10n.login_apple_button),
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
              const SizedBox(height: 16),
              Text(
                l10n.login_pass_hint,
                style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
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
      return e.message ?? l10n.login_error_unknown(e.code);
  }
}
