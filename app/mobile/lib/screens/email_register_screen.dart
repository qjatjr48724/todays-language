import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/user_profile_sync.dart';

class EmailRegisterScreen extends StatefulWidget {
  const EmailRegisterScreen({super.key});

  @override
  State<EmailRegisterScreen> createState() => _EmailRegisterScreenState();
}

class _EmailRegisterScreenState extends State<EmailRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _birthController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _birthController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms || !_agreePrivacy) {
      setState(() => _errorMessage = '약관 및 개인정보 수집에 모두 동의해 주세요.');
      return;
    }
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await credential.user?.updateDisplayName(_nameController.text.trim());
      if (credential.user != null) {
        await ensureUserProfileDocument(credential.user!);
        await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
          'displayName': _nameController.text.trim(),
          'birthDate': _birthController.text.trim(),
          'phoneNumber': _phoneController.text.trim(),
          'termsAgreed': true,
          'privacyAgreed': true,
          'registerMethod': 'email',
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
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
    return Scaffold(
      appBar: AppBar(title: const Text('이메일 회원가입')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: '이메일', border: OutlineInputBorder()),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return '이메일을 입력해 주세요.';
                    if (!s.contains('@')) return '올바른 이메일 형식이 아닙니다.';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: '비밀번호', border: OutlineInputBorder()),
                  validator: (v) {
                    final s = v ?? '';
                    if (s.length < 6) return '비밀번호는 6자 이상이어야 합니다.';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: '이름', border: OutlineInputBorder()),
                  validator: (v) => (v?.trim().isEmpty ?? true) ? '이름을 입력해 주세요.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _birthController,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(
                    labelText: '생년월일 (YYYY-MM-DD)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v?.trim().isEmpty ?? true) ? '생년월일을 입력해 주세요.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: '전화번호(인증)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v?.trim().isEmpty ?? true) ? '전화번호를 입력해 주세요.' : null,
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: _agreeTerms,
                  onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('서비스 약관 동의'),
                ),
                CheckboxListTile(
                  value: _agreePrivacy,
                  onChanged: (v) => setState(() => _agreePrivacy = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  title: const Text('개인정보 수집 동의'),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(_errorMessage!, style: TextStyle(color: scheme.error)),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _loading ? null : _register,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('회원가입 완료'),
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
    case 'email-already-in-use':
      return '이미 사용 중인 이메일입니다.';
    case 'weak-password':
      return '비밀번호가 너무 짧습니다.';
    default:
      return e.message ?? '회원가입에 실패했습니다. (${e.code})';
  }
}
