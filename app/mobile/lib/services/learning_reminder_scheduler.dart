import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'app_notification_preferences.dart';
import 'learning_reminder_preferences.dart';
import '../utils/learning_reminder_time.dart';

/// 매일 학습 리마인드 로컬 알림 예약/취소.
class LearningReminderScheduler {
  LearningReminderScheduler._();

  static const notificationId = 41001;
  static const androidChannelId = 'learning_reminder';
  static const androidChannelName = 'Learning reminder';

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;


  /// 앱 시작 시 1회 호출. 타임존·플러그인 초기화 후 기존 스케줄 재등록.
  static Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: darwinInit,
        macOS: darwinInit,
      ),
    );

    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          androidChannelId,
          androidChannelName,
          importance: Importance.defaultImportance,
        ),
      );
    }

    _initialized = true;
    await syncFromPreferences();
  }


  /// prefs + 앱/시스템 알림 허용 여부에 맞게 예약하거나 취소한다.
  static Future<void> syncFromPreferences({
    String? title,
    String? body,
  }) async {
    if (!_initialized) return;

    final enabled = await LearningReminderPreferences.isEnabled();
    final canDeliver = await AppNotificationPreferences.shouldDeliver();
    if (!enabled || !canDeliver) {
      await cancel();
      return;
    }

    final time = await LearningReminderPreferences.loadTime();
    await scheduleDaily(
      hour: time.hour,
      minute: time.minute,
      title: title ?? 'Today\'s Language',
      body: body ?? 'Time to study today.',
    );
  }


  static Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    final clamped = LearningReminderTime.clamp(hour: hour, minute: minute);
    final when = _nextInstanceOf(clamped.hour, clamped.minute);

    const androidDetails = AndroidNotificationDetails(
      androidChannelId,
      androidChannelName,
      channelDescription: 'Daily learning reminder',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const darwinDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    await _plugin.zonedSchedule(
      id: notificationId,
      title: title,
      body: body,
      scheduledDate: when,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    if (kDebugMode) {
      debugPrint(
        '[LearningReminder] scheduled daily at '
        '${LearningReminderTime.formatHm(clamped.hour, clamped.minute)} '
        'next=$when',
      );
    }
  }


  static Future<void> cancel() async {
    if (!_initialized) return;
    await _plugin.cancel(id: notificationId);
  }


  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
