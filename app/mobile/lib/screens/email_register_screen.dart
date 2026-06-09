import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../data/legal/privacy_policy_content.dart';
import '../data/legal/terms_of_service_content.dart';
import '../l10n/app_localizations.dart';
import '../services/auth_session_service.dart';
import '../services/user_profile_sync.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';

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
  bool _termsAgreedLocked = false;
  bool _privacyAgreedLocked = false;
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _openTermsOfService({bool readOnly = false}) async {
    final agreed = await TermsOfServiceScreen.open(
      context,
      readOnly: readOnly,
    );
    if (agreed == true && mounted) {
      setState(() {
        _agreeTerms = true;
        _termsAgreedLocked = true;
      });
    }
  }


  Future<void> _openPrivacyPolicy({bool readOnly = false}) async {
    final agreed = await PrivacyPolicyScreen.open(
      context,
      readOnly: readOnly,
    );
    if (agreed == true && mounted) {
      setState(() {
        _agreePrivacy = true;
        _privacyAgreedLocked = true;
      });
    }
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
            'version': TermsOfServiceContent.version,
            'agreedAt': FieldValue.serverTimestamp(),
          },
          'privacy': {
            'version': PrivacyPolicyContent.version,
            'agreedAt': FieldValue.serverTimestamp(),
          },
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        await AuthSessionService().claimSession(credential.user!);
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
                  onChanged: _termsAgreedLocked
                      ? null
                      : (_) => _openTermsOfService(),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.email_register_terms_agree_title),
                  secondary: TextButton(
                    onPressed: () => _openTermsOfService(
                      readOnly: _termsAgreedLocked,
                    ),
                    child: Text(l10n.email_register_view_button),
                  ),
                ),
                CheckboxListTile(
                  value: _agreePrivacy,
                  onChanged: _privacyAgreedLocked
                      ? null
                      : (_) => _openPrivacyPolicy(),
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.email_register_privacy_agree_title),
                  secondary: TextButton(
                    onPressed: () => _openPrivacyPolicy(
                      readOnly: _privacyAgreedLocked,
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
