import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'email_register_screen.dart';
import '../l10n/app_localizations.dart';

class EmailLoginScreen extends StatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  State<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends State<EmailLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      setState(() => _errorMessage = _messageForAuthException(e, context));
    } catch (_) {
      setState(() => _errorMessage = l10n.email_login_error_unknown);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.email_login_appbar_title)),
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
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.email_login_email_label,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final s = v?.trim() ?? '';
                    if (s.isEmpty) return l10n.email_login_validate_email_required;
                    if (!s.contains('@')) {
                      return l10n.email_login_validate_email_format;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: l10n.email_login_password_label,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    final s = v ?? '';
                    if (s.isEmpty) return l10n.email_login_validate_password_required;
                    if (s.length < 6) return l10n.email_login_validate_password_min;
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(_errorMessage!, style: TextStyle(color: scheme.error)),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: _loading ? null : _signIn,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.email_login_button),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l10n.email_login_to_register_prefix,
                        style: TextStyle(color: scheme.onSurfaceVariant)),
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const EmailRegisterScreen(),
                                ),
                              );
                            },
                      child: Text(l10n.email_login_to_register_button),
                    ),
                  ],
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
      return l10n.email_login_error_invalid_email;
    case 'user-disabled':
      return l10n.email_login_error_user_disabled;
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
      return l10n.email_login_error_credentials;
    case 'too-many-requests':
      return l10n.email_login_error_too_many_requests;
    default:
      return e.message ?? l10n.email_login_error_failed(e.code);
  }
}
