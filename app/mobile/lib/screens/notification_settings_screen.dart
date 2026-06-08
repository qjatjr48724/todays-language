import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../l10n/app_localizations.dart';
import '../services/app_notification_preferences.dart';


/// 앱 알림 on/off 토글. 시스템 권한과 별도로 즉시 반영됩니다.
class NotificationSettingsScreen extends StatefulWidget {
    const NotificationSettingsScreen({super.key});

    @override
    State<NotificationSettingsScreen> createState() =>
        _NotificationSettingsScreenState();
}


class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with WidgetsBindingObserver {
    bool _loading = true;
    bool _busy = false;
    bool _appEnabled = false;
    bool _systemGranted = false;


    @override
    void initState() {
        super.initState();
        WidgetsBinding.instance.addObserver(this);
        _refreshStatus();
    }


    @override
    void dispose() {
        WidgetsBinding.instance.removeObserver(this);
        super.dispose();
    }


    @override
    void didChangeAppLifecycleState(AppLifecycleState state) {
        if (state == AppLifecycleState.resumed) {
            _refreshStatus();
        }
    }


    Future<void> _refreshStatus() async {
        setState(() => _loading = true);
        final appEnabled = await AppNotificationPreferences.isEnabled();
        final systemGranted =
            await AppNotificationPreferences.isSystemPermissionGranted();
        if (!mounted) return;
        setState(() {
            _appEnabled = appEnabled;
            _systemGranted = systemGranted;
            _loading = false;
        });
    }


    Future<void> _onToggleChanged(bool enable) async {
        if (_busy || _loading) return;
        setState(() => _busy = true);
        try {
            await AppNotificationPreferences.setEnabled(enable);
            if (!mounted) return;
            setState(() => _appEnabled = enable);

            if (enable) {
                final granted =
                    await AppNotificationPreferences.requestSystemPermission();
                if (!mounted) return;
                setState(() => _systemGranted = granted);

                if (!granted) {
                    final status = await Permission.notification.status;
                    if (!mounted) return;
                    final l10n = AppLocalizations.of(context)!;
                    if (status.isPermanentlyDenied) {
                        await _showOpenSettingsDialog();
                    } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    l10n.settings_notification_status_system_needed,
                                ),
                            ),
                        );
                    }
                }
            }
        } finally {
            if (mounted) setState(() => _busy = false);
        }
    }


    Future<void> _showOpenSettingsDialog() async {
        final l10n = AppLocalizations.of(context)!;
        await showDialog<void>(
            context: context,
            builder: (context) {
                return AlertDialog(
                    title: Text(l10n.notification_permission_title),
                    content: Text(
                        l10n.notification_permission_settings_needed,
                    ),
                    actions: [
                        TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                                l10n.notification_permission_dialog_close,
                            ),
                        ),
                        TextButton(
                            onPressed: () async {
                                Navigator.of(context).pop();
                                await openAppSettings();
                            },
                            child: Text(
                                l10n.notification_permission_open_settings,
                            ),
                        ),
                    ],
                );
            },
        );
    }


    String _statusLabel(AppLocalizations l10n) {
        if (!_appEnabled) {
            return l10n.settings_notification_status_app_off;
        }
        if (_systemGranted) {
            return l10n.settings_notification_status_app_on;
        }
        return l10n.settings_notification_status_system_needed;
    }


    @override
    Widget build(BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        final scheme = Theme.of(context).colorScheme;
        final toggleEnabled = !_loading && !_busy;

        return Scaffold(
            appBar: AppBar(title: Text(l10n.settings_notification_tile)),
            body: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                            Text(
                                l10n.settings_notification_toggle_description,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 24),
                            Card(
                                child: _loading
                                    ? const Padding(
                                        padding: EdgeInsets.all(24),
                                        child: Center(
                                            child: CircularProgressIndicator(),
                                        ),
                                    )
                                    : SwitchListTile(
                                        secondary: Icon(
                                            _appEnabled
                                                ? Icons
                                                    .notifications_active_outlined
                                                : Icons
                                                    .notifications_off_outlined,
                                            color: _appEnabled
                                                ? scheme.primary
                                                : scheme.outline,
                                        ),
                                        title: Text(
                                            l10n.settings_notification_tile,
                                        ),
                                        subtitle: Text(_statusLabel(l10n)),
                                        value: _appEnabled,
                                        onChanged: toggleEnabled
                                            ? _onToggleChanged
                                            : null,
                                    ),
                            ),
                            if (_busy) ...[
                                const SizedBox(height: 16),
                                const Center(
                                    child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                        ),
                                    ),
                                ),
                            ],
                        ],
                    ),
                ),
            ),
        );
    }
}
