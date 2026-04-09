import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'email_login_screen.dart';
import '../services/user_profile_sync.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;
  String? _errorMessage;

  static const _testEmail = 'test@test.com';
  static const _testPassword = 'test1234';

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
      setState(() => _errorMessage = _messageForAuthException(e));
    } catch (e) {
      setState(() => _errorMessage = '구글 로그인에 실패했습니다: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInWithApple() async {
    if (!Platform.isIOS) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('애플 로그인은 iOS에서만 지원합니다.')),
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
      setState(() => _errorMessage = '애플 로그인에 실패했습니다: ${e.message}');
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _messageForAuthException(e));
    } catch (e) {
      setState(() => _errorMessage = '애플 로그인에 실패했습니다: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInTestAccount() async {
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
      setState(() => _errorMessage = _messageForAuthException(e));
    } catch (_) {
      setState(() => _errorMessage = '알 수 없는 오류가 발생했습니다.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Today's Language")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('시작하기', style: t.headlineSmall),
              const SizedBox(height: 6),
              Text(
                '원하는 로그인/회원가입 방식을 선택하세요.',
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
                child: const Text('이메일로 시작하기'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _loading ? null : _signInWithGoogle,
                child: const Text('구글로 시작하기'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _loading ? null : _signInWithApple,
                child: const Text('애플로 시작하기'),
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
                  label: const Text('테스트 계정으로 자동 로그인'),
                ),
              ],
              const SizedBox(height: 16),
              Text(
                '휴대폰 인증(PASS) 연동은 다음 단계에서 추가됩니다.',
                style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _messageForAuthException(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return '이메일 형식이 올바르지 않습니다.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return '이메일 또는 비밀번호가 올바르지 않습니다.';
    case 'too-many-requests':
      return '시도가 너무 많습니다. 잠시 후 다시 시도해 주세요.';
    default:
      return e.message ?? '인증에 실패했습니다. (${e.code})';
  }
}
