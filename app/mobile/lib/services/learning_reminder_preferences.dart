import 'package:shared_preferences/shared_preferences.dart';

import '../utils/learning_reminder_time.dart';

/// 학습 리마인드 온보딩·스케줄용 로컬 설정.
class LearningReminderPreferences {
  LearningReminderPreferences._();

  static const prefsKeySetupDone = 'learning_reminder_setup_done';
  static const prefsKeyEnabled = 'learning_reminder_enabled';
  static const prefsKeyHour = 'learning_reminder_hour';
  static const prefsKeyMinute = 'learning_reminder_minute';


  static Future<bool> isSetupDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKeySetupDone) ?? false;
  }


  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(prefsKeyEnabled) ?? false;
  }


  static Future<({int hour, int minute})> loadTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(prefsKeyHour) ?? LearningReminderTime.defaultHour;
    final minute =
        prefs.getInt(prefsKeyMinute) ?? LearningReminderTime.defaultMinute;
    return LearningReminderTime.clamp(hour: hour, minute: minute);
  }


  /// 건너뛰기 — 온보딩만 완료, 알림 예약 없음.
  static Future<void> markSkipped() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKeySetupDone, true);
    await prefs.setBool(prefsKeyEnabled, false);
  }


  /// 시간 확정 후 리마인드 사용.
  static Future<void> markEnabled({
    required int hour,
    required int minute,
  }) async {
    final clamped = LearningReminderTime.clamp(hour: hour, minute: minute);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKeySetupDone, true);
    await prefs.setBool(prefsKeyEnabled, true);
    await prefs.setInt(prefsKeyHour, clamped.hour);
    await prefs.setInt(prefsKeyMinute, clamped.minute);
  }


  /// 언어 선택 플로우 초기화 시 온보딩·알림 설정을 되돌립니다.
  static Future<void> resetForLanguageFlow() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(prefsKeySetupDone);
    await prefs.remove(prefsKeyEnabled);
    await prefs.remove(prefsKeyHour);
    await prefs.remove(prefsKeyMinute);
  }
}
