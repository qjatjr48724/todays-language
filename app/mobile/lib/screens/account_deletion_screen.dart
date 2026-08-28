import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth_gate.dart';
import '../l10n/app_localizations.dart';
import '../services/account_deletion_service.dart';
import '../services/account_reauth_helper.dart';
import '../services/analytics/tracked_scaffold.dart';
import '../services/analytics/analytics_screens.dart';
import '../utils/account_deletion_confirm_delay.dart';


/// 회원 탈퇴 — 데이터 삭제 안내, 5초 대기, 재인증 후 계정 삭제.
class AccountDeletionScreen extends StatefulWidget {
  const AccountDeletionScreen({super.key});

  @override
  State<AccountDeletionScreen> createState() => _AccountDeletionScreenState();
}


class _AccountDeletionScreenState extends State<AccountDeletionScreen> {
  final _passwordController = TextEditingController();
  final _deletionService = AccountDeletionService();

  Timer? _delayTimer;
  int _elapsedSeconds = 0;
  bool _showVerification = false;
  bool _obscurePassword = true;
  bool _loading = false;
  String? _errorMessage;


  @override
  void initState() {
    super.initState();
    _delayTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _elapsedSeconds += 1);
      if (accountDeletionConfirmEnabled(_elapsedSeconds)) {
        _delayTimer?.cancel();
        _delayTimer = null;
      }
    });
  }


  @override
  void dispose() {
    _delayTimer?.cancel();
    _passwordController.dispose();
    super.dispose();
  }


  bool get _confirmEnabled => accountDeletionConfirmEnabled(_elapsedSeconds);


  int get _secondsUntilConfirm {
    final remaining = kAccountDeletionConfirmDelaySeconds - _elapsedSeconds;
    return remaining > 0 ? remaining : 0;
  }


  AccountReauthMethod? get _reauthMethod {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    return resolveAccountReauthMethod(user);
  }


  Future<void> _onConfirmPressed() async {
    if (!_confirmEnabled || _loading) return;
    setState(() {
      _showVerification = true;
      _errorMessage = null;
    });
  }


  Future<void> _onDeletePressed() async {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _loading) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    if (!mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(l10n.account_deletion_processing)),
              ],
            ),
          ),
        );
      },
    );

    try {
      await _deletionService.deleteAccountAfterReauth(
        user: user,
        password: _passwordController.text,
      );
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() => _errorMessage = _authErrorMessage(e, l10n));
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() => _errorMessage = e.message ?? l10n.account_deletion_failed);
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        setState(() => _errorMessage = l10n.account_deletion_failed);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  String _authErrorMessage(FirebaseAuthException e, AppLocalizations l10n) {
    switch (e.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return l10n.account_deletion_wrong_password;
      case 'too-many-requests':
        return l10n.account_deletion_too_many_requests;
      case 'missing-password':
        return l10n.account_deletion_password_required;
      case 'missing-email':
        return l10n.account_deletion_email_missing;
      case 'user-mismatch':
        return l10n.account_deletion_reauth_failed;
      default:
        return e.message ?? l10n.account_deletion_reauth_failed;
    }
  }


  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final reauthMethod = _reauthMethod;

    if (user == null) {
      return trackedScaffold(
        screenName: AnalyticsScreens.accountDeletion,
        scaffold: Scaffold(
          appBar: AppBar(title: Text(l10n.account_deletion_screen_title)),
          body: Center(
            child: Text(
              l10n.my_info_login_required,
              style: TextStyle(color: scheme.onSurfaceVariant),
            ),
          ),
        ),
      );
    }

    return trackedScaffold(
      screenName: AnalyticsScreens.accountDeletion,
      scaffold: Scaffold(
        appBar: AppBar(title: Text(l10n.account_deletion_screen_title)),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 40,
                        color: scheme.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.account_deletion_warning_title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: scheme.error,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.account_deletion_warning_body,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.account_deletion_items_header,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      ...[
                        l10n.account_deletion_item_profile,
                        l10n.account_deletion_item_progress,
                        l10n.account_deletion_item_chat,
                        l10n.account_deletion_item_account,
                      ].map(
                        (line) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('• ', style: TextStyle(color: scheme.error)),
                              Expanded(child: Text(line)),
                            ],
                          ),
                        ),
                      ),
                      if (_showVerification) ...[
                        const SizedBox(height: 24),
                        Text(
                          l10n.account_deletion_verify_header,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 12),
                        if (reauthMethod == AccountReauthMethod.emailPassword) ...[
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            autofillHints: const [AutofillHints.password],
                            decoration: InputDecoration(
                              labelText: l10n.account_deletion_password_label,
                              border: const OutlineInputBorder(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() => _obscurePassword = !_obscurePassword);
                                },
                              ),
                            ),
                            onFieldSubmitted: (_) => _onDeletePressed(),
                          ),
                        ] else if (reauthMethod == AccountReauthMethod.google) ...[
                          Text(
                            l10n.account_deletion_reauth_google_hint,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ] else ...[
                          Text(
                            l10n.account_deletion_reauth_apple_hint,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                        if (_errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            style: TextStyle(color: scheme.error),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_showVerification) ...[
                      if (!_confirmEnabled)
                        Text(
                          l10n.account_deletion_wait_seconds(_secondsUntilConfirm),
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                        ),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: _confirmEnabled && !_loading ? _onConfirmPressed : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.error,
                          foregroundColor: scheme.onError,
                          disabledBackgroundColor: scheme.error.withValues(alpha: 0.35),
                        ),
                        child: Text(l10n.account_deletion_continue_button),
                      ),
                    ] else ...[
                      FilledButton(
                        onPressed: _loading ? null : _onDeletePressed,
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.error,
                          foregroundColor: scheme.onError,
                        ),
                        child: _loading
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: scheme.onError,
                                ),
                              )
                            : Text(l10n.account_deletion_confirm_button),
                      ),
                    ],
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loading ? null : () => Navigator.of(context).pop(),
                      child: Text(l10n.common_cancel),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
