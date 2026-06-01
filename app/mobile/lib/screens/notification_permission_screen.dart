import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

class NotificationPermissionScreen extends StatefulWidget {
  const NotificationPermissionScreen({super.key});

  static const prefsKeyAsked = 'notificationPermissionAsked';

  /// 앱 진입 시 알림 권한 안내를 다시 보이게 합니다 (관리자 도구 등).
  static Future<void> resetAskedPref() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefsKeyAsked);
  }

  @override
  State<NotificationPermissionScreen> createState() =>
      _NotificationPermissionScreenState();
}

class _NotificationPermissionScreenState
    extends State<NotificationPermissionScreen> {
  bool _requesting = false;

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _allow() async {
    if (_requesting) return;
    setState(() => _requesting = true);
    try {
      // iOS / Android 13+ 에서만 의미 있는 권한 요청입니다.
      // 그 외 버전에서는 granted로 떨어질 수 있으며, 그 경우도 정상 처리합니다.
      if (Platform.isIOS || Platform.isAndroid) {
        PermissionStatus status;

        if (Platform.isIOS) {
          final ios = _localNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>();
          bool? granted;
          if (ios != null) {
            granted = await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            );
          } else {
            // 플러그인 등록이 꼬였거나, iOS 구현체를 찾지 못하는 경우 폴백 요청.
            status = await Permission.notification.request();
            granted = status.isGranted;
          }

          status = (granted ?? false)
              ? PermissionStatus.granted
              : PermissionStatus.denied;
        } else {
          status = await Permission.notification.request();
        }

        if (!mounted) return;

        if (status.isDenied ||
            status.isRestricted ||
            status.isPermanentlyDenied) {
          if (!mounted) return;
          final l10n = AppLocalizations.of(context)!;
          await showDialog<void>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(l10n.notification_permission_title),
                content: Text(l10n.notification_permission_settings_needed),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(l10n.notification_permission_dialog_close),
                  ),
                  TextButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await openAppSettings();
                    },
                    child: Text(l10n.notification_permission_open_settings),
                  ),
                ],
              );
            },
          );

          return;
        }
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
