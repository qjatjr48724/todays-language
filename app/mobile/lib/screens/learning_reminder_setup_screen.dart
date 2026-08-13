import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/analytics/analytics_navigation.dart';
import '../services/analytics/analytics_screens.dart';
import '../services/analytics/tracked_scaffold.dart';
import '../services/app_notification_preferences.dart';
import '../services/learning_reminder_preferences.dart';
import '../services/learning_reminder_scheduler.dart';
import '../utils/learning_reminder_time.dart';
import 'main_nav_screen.dart';

/// 언어 설정 직후 학습 리마인드 시각 온보딩.
class LearningReminderSetupScreen extends StatefulWidget {
  const LearningReminderSetupScreen({super.key});

  @override
  State<LearningReminderSetupScreen> createState() =>
      _LearningReminderSetupScreenState();
}

class _LearningReminderSetupScreenState
    extends State<LearningReminderSetupScreen> {
  static const _dropdownVisibleItems = 5;
  static const _dropdownMenuMaxHeight =
      _dropdownVisibleItems * kMinInteractiveDimension;

  int _hour = LearningReminderTime.defaultHour;
  int _minute = LearningReminderTime.defaultMinute;
  bool _busy = false;

  Future<void> _goHome() async {
    if (!mounted) return;
    pushAndRemoveUntilAnalyticsScreen(
      context,
      screenName: AnalyticsScreens.mainNav,
      builder: (_) => const MainNavScreen(),
      predicate: (route) => false,
    );
  }


  Future<void> _onSkip() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await LearningReminderPreferences.markSkipped();
      await LearningReminderScheduler.cancel();
      await _goHome();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }


  Future<void> _onConfirm() async {
    if (_busy) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _busy = true);
    try {
      var granted =
          await AppNotificationPreferences.isSystemPermissionGranted();
      if (!granted) {
        if (!mounted) return;
        final shouldRequest = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(l10n.learning_reminder_permission_title),
                content: Text(l10n.learning_reminder_permission_message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: Text(l10n.learning_reminder_permission_later),
                  ),
                  FilledButton(
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: Text(l10n.learning_reminder_permission_allow),
                  ),
                ],
              ),
            ) ??
            false;
        if (!shouldRequest) {
          await LearningReminderPreferences.markSkipped();
          await LearningReminderScheduler.cancel();
          await _goHome();
          return;
        }
        granted = await AppNotificationPreferences.requestSystemPermission();
        if (!granted) {
          if (!mounted) return;
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(l10n.notification_permission_title),
              content: Text(l10n.notification_permission_settings_needed),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(l10n.notification_permission_dialog_close),
                ),
              ],
            ),
          );
          await LearningReminderPreferences.markSkipped();
          await LearningReminderScheduler.cancel();
          await _goHome();
          return;
        }
      }

      await AppNotificationPreferences.setEnabled(true);
      await LearningReminderPreferences.markEnabled(
        hour: _hour,
        minute: _minute,
      );
      await LearningReminderScheduler.syncFromPreferences(
        title: l10n.learning_reminder_notification_title,
        body: l10n.learning_reminder_notification_body,
      );
      await _goHome();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final hours = LearningReminderTime.hourOptions();
    final minutes = LearningReminderTime.minuteOptions();

    return trackedScaffold(
      screenName: AnalyticsScreens.learningReminderSetup,
      scaffold: Scaffold(
        appBar: AppBar(
          title: Text(l10n.learning_reminder_setup_appbar_title),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.learning_reminder_setup_heading,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.learning_reminder_setup_description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 28),
                Text(
                  l10n.learning_reminder_time_label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        key: ValueKey('reminder-hour-$_hour'),
                        initialValue: _hour,
                        menuMaxHeight: _dropdownMenuMaxHeight,
                        decoration: InputDecoration(
                          labelText: l10n.learning_reminder_hour_label,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          for (final h in hours)
                            DropdownMenuItem(
                              value: h,
                              child: Text(h.toString().padLeft(2, '0')),
                            ),
                        ],
                        onChanged: _busy
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
                        key: ValueKey('reminder-minute-$_minute'),
                        initialValue: _minute,
                        menuMaxHeight: _dropdownMenuMaxHeight,
                        decoration: InputDecoration(
                          labelText: l10n.learning_reminder_minute_label,
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          for (final m in minutes)
                            DropdownMenuItem(
                              value: m,
                              child: Text(m.toString().padLeft(2, '0')),
                            ),
                        ],
                        onChanged: _busy
                            ? null
                            : (v) {
                                if (v == null) return;
                                setState(() => _minute = v);
                              },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.learning_reminder_time_hint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _busy ? null : _onConfirm,
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.learning_reminder_confirm),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: _busy ? null : _onSkip,
                  child: Text(l10n.learning_reminder_decline),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
