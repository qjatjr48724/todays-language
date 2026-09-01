import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/analytics/analytics_navigation.dart';
import '../services/analytics/analytics_screens.dart';

class PasswordResetScreen extends StatefulWidget {
  const PasswordResetScreen({
    super.key,
    this.initialEmail,
  });

  /// 이메일 로그인 화면에서 넘어온 이메일을 미리 채웁니다.
  final String? initialEmail;

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _loading = false;
  bool _sent = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _sent = true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = _messageForAuthException(e, context));
    } catch (_) {
      if (!mounted) return;
      setState(() => _errorMessage = l10n.password_reset_error_unknown);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.password_reset_appbar_title)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _sent ? _buildSuccess(context) : _buildForm(context, scheme),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, ColorScheme scheme) {
    final l10n = AppLocalizations.of(context)!;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.password_reset_description,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            textInputAction: TextInputAction.done,
            enabled: !_loading,
            decoration: InputDecoration(
              labelText: l10n.email_login_email_label,
              border: const OutlineInputBorder(),
            ),
            validator: (v) {
              final s = v?.trim() ?? '';
              if (s.isEmpty) return l10n.email_login_validate_email_required;
              if (!s.contains('@')) {
                return l10n.email_login_validate_email_format;
              }
              return null;
            },
            onFieldSubmitted: (_) {
              if (!_loading) _sendResetEmail();
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 8),
            Text(_errorMessage!, style: TextStyle(color: scheme.error)),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _loading ? null : _sendResetEmail,
            child: _loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.password_reset_button),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.mark_email_read_outlined, size: 48, color: scheme.primary),
        const SizedBox(height: 16),
        Text(
          l10n.password_reset_success,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.password_reset_back_to_login),
        ),
      ],
    );
  }
}


String _messageForAuthException(FirebaseAuthException e, BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  switch (e.code) {
    case 'invalid-email':
      return l10n.password_reset_error_invalid_email;
    case 'too-many-requests':
      return l10n.password_reset_error_too_many_requests;
    default:
      return l10n.password_reset_error_failed(e.code);
  }
}


/// Analytics 계측과 함께 비밀번호 찾기 화면을 엽니다.
void openPasswordResetScreen(
  BuildContext context, {
  String? initialEmail,
}) {
  pushAnalyticsScreen(
    context,
    screenName: AnalyticsScreens.passwordReset,
    builder: (_) => PasswordResetScreen(initialEmail: initialEmail),
  );
}
