import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/analytics/analytics_action_log.dart';
import '../l10n/app_localizations.dart';
import '../services/app_notification_preferences.dart';
import '../services/learning_reminder_preferences.dart';
import '../services/learning_reminder_scheduler.dart';
import '../utils/learning_reminder_time.dart';


/// 앱 알림 on/off 토글. 시스템 권한과 별도로 즉시 반영됩니다.
class NotificationSettingsScreen extends StatefulWidget {
    const NotificationSettingsScreen({super.key});

    @override
    State<NotificationSettingsScreen> createState() =>
        _NotificationSettingsScreenState();
}


class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with WidgetsBindingObserver {
    static const _dropdownVisibleItems = 5;
    static const _dropdownMenuMaxHeight =
        _dropdownVisibleItems * kMinInteractiveDimension;

    bool _loading = true;
    bool _busy = false;
    bool _appEnabled = false;
    bool _systemGranted = false;

    // 리마인드 시간 설정
    bool _reminderEnabled = false;
    int _hour = LearningReminderTime.defaultHour;
    int _minute = LearningReminderTime.defaultMinute;
    bool _reminderBusy = false;


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
        final reminderEnabled = await LearningReminderPreferences.isEnabled();
        final time = await LearningReminderPreferences.loadTime();
        if (!mounted) return;
        setState(() {
            _appEnabled = appEnabled;
            _systemGranted = systemGranted;
            _reminderEnabled = reminderEnabled;
            _hour = time.hour;
            _minute = time.minute;
            _loading = false;
        });
    }


    Future<void> _saveReminderTime() async {
        if (_reminderBusy) return;
        final l10n = AppLocalizations.of(context)!;
        setState(() => _reminderBusy = true);
        try {
            await LearningReminderPreferences.markEnabled(
                hour: _hour,
                minute: _minute,
            );
            await LearningReminderScheduler.syncFromPreferences(
                title: l10n.learning_reminder_notification_title,
                body: l10n.learning_reminder_notification_body,
            );
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(l10n.settings_reminder_time_saved_snackbar),
                ),
            );
            setState(() => _reminderEnabled = true);
        } finally {
            if (mounted) setState(() => _reminderBusy = false);
        }
    }


    Future<void> _onToggleChanged(bool enable) async {
        if (_busy || _loading) return;
        setState(() => _busy = true);
        try {
            await AppNotificationPreferences.setEnabled(enable);
            await logSettingsToggle(
              settingId: 'app_notifications',
              enabled: enable,
            );
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
                        child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ),
            ],

            // 리마인드 시간 설정 섹션 — 앱 알림이 ON일 때만 노출
            if (!_loading && _appEnabled) ...[
                const SizedBox(height: 28),
                Text(
                    l10n.settings_reminder_time_section_title,
                    style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                    l10n.settings_reminder_time_section_description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                    ),
                ),
                const SizedBox(height: 16),
                if (!_reminderEnabled)
                    Text(
                        l10n.settings_reminder_time_not_set,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                        ),
                    ),
                const SizedBox(height: 12),
                Row(
                    children: [
                        Expanded(
                            child: DropdownButtonFormField<int>(
                                key: ValueKey('settings-hour-$_hour'),
                                initialValue: _hour,
                                menuMaxHeight: _dropdownMenuMaxHeight,
                                decoration: InputDecoration(
                                    labelText: l10n.learning_reminder_hour_label,
                                    border: const OutlineInputBorder(),
                                ),
                                items: [
                                    for (final h in LearningReminderTime.hourOptions())
                                        DropdownMenuItem(
                                            value: h,
                                            child: Text(h.toString().padLeft(2, '0')),
                                        ),
                                ],
                                onChanged: _reminderBusy
                                    ? null
                                    : (v) {
                                        if (v == null) return;
                                        setState(() => _hour = v);
                                    },
                            ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                            child: DropdownButtonFormField<int>(
                                key: ValueKey('settings-minute-$_minute'),
                                initialValue: _minute,
                                menuMaxHeight: _dropdownMenuMaxHeight,
                                decoration: InputDecoration(
                                    labelText: l10n.learning_reminder_minute_label,
                                    border: const OutlineInputBorder(),
                                ),
                                items: [
                                    for (final m in LearningReminderTime.minuteOptions())
                                        DropdownMenuItem(
                                            value: m,
                                            child: Text(m.toString().padLeft(2, '0')),
                                        ),
                                ],
                                onChanged: _reminderBusy
                                    ? null
                                    : (v) {
                                        if (v == null) return;
                                        setState(() => _minute = v);
                                    },
                            ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                            onPressed: _reminderBusy ? null : _saveReminderTime,
                            child: _reminderBusy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(l10n.settings_reminder_time_save_button),
                        ),
                    ],
                ),
            ],
        ],
        ),
        ),
        ),
    );
  }
}
