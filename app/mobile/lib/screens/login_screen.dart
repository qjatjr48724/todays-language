import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  static const _testEmail = 'test@test.com';
  static const _testPassword = 'test1234';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _messageForAuthException(e));
    } catch (_) {
      setState(() => _errorMessage = '알 수 없는 오류가 발생했습니다.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _messageForAuthException(e));
    } catch (_) {
      setState(() => _errorMessage = '알 수 없는 오류가 발생했습니다.');
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('시작하기', style: t.headlineSmall),
                const SizedBox(height: 6),
                Text(
                  '이메일로 로그인/회원가입을 진행합니다.',
                  style: t.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: '이메일',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return '이메일을 입력해 주세요.';
                    if (!s.contains('@')) return '올바른 이메일 형식이 아닙니다.';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: '비밀번호',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final s = v ?? '';
                    if (s.isEmpty) return '비밀번호를 입력해 주세요.';
                    if (s.length < 6) return '비밀번호는 6자 이상이어야 합니다.';
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: scheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _loading ? null : _signIn,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('로그인'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _loading ? null : _register,
                  child: const Text('회원가입'),
                ),
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
                  'Google/Apple 로그인은 이후 단계에서 추가됩니다.',
                  style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
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
    case 'user-disabled':
      return '이 계정은 사용할 수 없습니다.';
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return '이메일 또는 비밀번호가 올바르지 않습니다.';
    case 'email-already-in-use':
      return '이미 사용 중인 이메일입니다.';
    case 'weak-password':
      return '비밀번호가 너무 짧습니다.';
    case 'too-many-requests':
      return '시도가 너무 많습니다. 잠시 후 다시 시도해 주세요.';
    default:
      return e.message ?? '인증에 실패했습니다. (${e.code})';
  }
}
