import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/user_profile_sync.dart';
import '../l10n/app_localizations.dart';

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
  bool _agreeTerms = false;
  bool _agreePrivacy = false;
  bool _loading = false;
  String? _errorMessage;

  static const _termsVersion = '2026-04-10';
  static const _privacyVersion = '2026-04-10';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    if (!_agreeTerms || !_agreePrivacy) {
      setState(() => _errorMessage = l10n.email_register_agree_required);
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
          // 이용동의/개인정보 동의 포맷(버전+시각) 확정
          'terms': {
            'version': _termsVersion,
            'agreedAt': FieldValue.serverTimestamp(),
          },
          'privacy': {
            'version': _privacyVersion,
            'agreedAt': FieldValue.serverTimestamp(),
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _messageForAuthException(e, context));
    } catch (_) {
      setState(() => _errorMessage = l10n.email_register_error_unknown);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.email_register_appbar_title)),
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
                  decoration: InputDecoration(
                    labelText: l10n.email_register_email_label,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return l10n.email_register_validate_email_required;
                    if (!s.contains('@')) {
                      return l10n.email_register_validate_email_format;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.email_register_password_label,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final s = v ?? '';
                    if (s.length < 6) return l10n.email_register_validate_password_min;
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.email_register_name_label,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (v) => (v?.trim().isEmpty ?? true)
                      ? l10n.email_register_validate_name_required
                      : null,
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: _agreeTerms,
                  onChanged: (v) => setState(() => _agreeTerms = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.email_register_terms_agree_title),
                  secondary: TextButton(
                    onPressed: () => _showConsentText(
                      context,
                      title: l10n.email_register_terms_agree_title,
                      version: _termsVersion,
                      body: _termsText,
                    ),
                    child: Text(l10n.email_register_view_button),
                  ),
                ),
                CheckboxListTile(
                  value: _agreePrivacy,
                  onChanged: (v) => setState(() => _agreePrivacy = v ?? false),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.email_register_privacy_agree_title),
                  secondary: TextButton(
                    onPressed: () => _showConsentText(
                      context,
                      title: l10n.email_register_privacy_agree_title,
                      version: _privacyVersion,
                      body: _privacyText,
                    ),
                    child: Text(l10n.email_register_view_button),
                  ),
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
                      : Text(l10n.email_register_button),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> _showConsentText(
  BuildContext context, {
  required String title,
  required String version,
  required String body,
}) async {
  final l10n = AppLocalizations.of(context)!;
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(l10n.email_register_consent_dialog_title(title, version)),
        content: SingleChildScrollView(child: Text(body)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.email_register_close_button),
          ),
        ],
      );
    },
  );
}

const String _termsText = '''
[서비스 이용약관]

1. 목적
본 약관은 Today's Language(이하 “서비스”) 이용과 관련한 권리·의무 및 책임사항을 규정합니다.

2. 계정
- 사용자는 이메일 또는 소셜 로그인을 통해 계정을 생성할 수 있습니다.
- 계정 정보는 서비스 제공 및 보안, 고객지원 목적에 사용됩니다.

3. 서비스 제공 및 변경
- 서비스는 기능 개선을 위해 일부 내용을 변경할 수 있습니다.

4. 금지행위
- 부정 사용, 자동화된 접근, 서비스 운영을 방해하는 행위는 금지됩니다.
''';

const String _privacyText = '''
[개인정보 처리방침]

1. 수집 항목
- 필수: 계정 식별자(uid), 이메일, 표시 이름(선택), 로그인 제공자, 언어 설정, 타임존, 학습 진도 데이터

2. 이용 목적
- 로그인/계정관리, 학습 콘텐츠 제공, 진행률 저장 및 동기화, 고객지원, 서비스 품질 개선

3. 제3자 제공
- 원칙적으로 제3자에게 제공하지 않습니다. 단, 법령에 의한 요청이 있는 경우 예외가 있을 수 있습니다.
''';

String _messageForAuthException(FirebaseAuthException e, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  switch (e.code) {
    case 'invalid-email':
      return l10n.email_register_error_invalid_email;
    case 'email-already-in-use':
      return l10n.email_register_error_email_in_use;
    case 'weak-password':
      return l10n.email_register_error_weak_password;
    default:
      return e.message ?? l10n.email_register_error_failed(e.code);
  }
}
