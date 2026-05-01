import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/app_localizations.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  static const prefsKeyAsked = 'notificationPermissionAsked';

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen> {
  bool _requesting = false;

  Future<void> _allow() async {
    if (_requesting) return;
    setState(() => _requesting = true);
    try {
      // iOS / Android 13+ 에서만 의미 있는 권한 요청입니다.
      // 그 외 버전에서는 granted로 떨어질 수 있으며, 그 경우도 정상 처리합니다.
      if (Platform.isIOS || Platform.isAndroid) {
        await Permission.notification.request();
      }
    } finally {
      if (mounted) {
        setState(() => _requesting = false);
        Navigator.of(context).pop(true);
      }
    }
  }

  void _deny() {
    Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(l10n.notification_permission_title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.notification_permission_heading,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.notification_permission_description,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _requesting ? null : _deny,
                      child: Text(l10n.notification_permission_deny_button),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: _requesting ? null : _allow,
                      child: _requesting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.notification_permission_allow_button),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

