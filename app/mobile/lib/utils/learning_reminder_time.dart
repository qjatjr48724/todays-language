/// 학습 리마인드 시각 규칙: 매일, 08:00~20:50, 분 단위 10분.
class LearningReminderTime {
  LearningReminderTime._();

  static const minHour = 8;
  static const maxHour = 20;
  static const minuteStep = 10;
  static const defaultHour = minHour;
  static const defaultMinute = 0;


  /// 허용 시각이면 true.
  static bool isValid({required int hour, required int minute}) {
    if (hour < minHour || hour > maxHour) return false;
    if (minute < 0 || minute > 50) return false;
    if (minute % minuteStep != 0) return false;
    if (hour == maxHour && minute > 50) return false;
    return true;
  }


  /// 범위·스텝에 맞게 보정. 유효하지 않으면 기본값(08:00).
  static ({int hour, int minute}) clamp({
    required int hour,
    required int minute,
  }) {
    if (isValid(hour: hour, minute: minute)) {
      return (hour: hour, minute: minute);
    }
    final stepped = (minute ~/ minuteStep) * minuteStep;
    var h = hour;
    var m = stepped.clamp(0, 50);
    if (h < minHour) h = minHour;
    if (h > maxHour) h = maxHour;
    if (!isValid(hour: h, minute: m)) {
      return (hour: defaultHour, minute: defaultMinute);
    }
    return (hour: h, minute: m);
  }


  static List<int> hourOptions() =>
      [for (var h = minHour; h <= maxHour; h++) h];


  static List<int> minuteOptions() =>
      [for (var m = 0; m <= 50; m += minuteStep) m];


  static String formatHm(int hour, int minute) {
    final hh = hour.toString().padLeft(2, '0');
    final mm = minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }
}
