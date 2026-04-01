import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'email_login_screen.dart';

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
                onPressed: _loading
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('구글 로그인은 다음 단계에서 연결합니다.')),
                        );
                      },
                child: const Text('구글로 시작하기'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _loading
                    ? null
                    : () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('애플 로그인은 다음 단계에서 연결합니다.')),
                        );
                      },
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
