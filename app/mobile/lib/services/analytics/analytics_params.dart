/// Analytics에 허용하는 파라미터 키(화이트리스트). PII·자유 텍스트 금지.
abstract final class AnalyticsParamKeys {
  static const screenName = 'screen_name';
  static const durationSec = 'duration_sec';
  static const tabName = 'tab_name';
  static const targetLanguage = 'target_language';
  static const learningDay = 'learning_day';
  static const level = 'level';
  static const day = 'day';
  static const ready = 'ready';
  static const progressBucket = 'progress_bucket';
  static const timeBand = 'time_band';
  static const hourKst = 'hour_kst';
  static const errorCode = 'error_code';
  static const certId = 'cert_id';
  static const charTab = 'char_tab';
  static const enabled = 'enabled';
  static const entryPoint = 'entry_point';
  static const locked = 'locked';
  static const cardId = 'card_id';
  static const authMethod = 'auth_method';
  static const success = 'success';
  static const monthDelta = 'month_delta';
  static const dateKey = 'date_key';
  static const menuId = 'menu_id';
  static const settingId = 'setting_id';
  static const embedded = 'embedded';
  static const reviewMode = 'review_mode';

  static const allowedKeys = <String>{
    screenName,
    durationSec,
    tabName,
    targetLanguage,
    learningDay,
    level,
    day,
    ready,
    progressBucket,
    timeBand,
    hourKst,
    errorCode,
    certId,
    charTab,
    enabled,
    entryPoint,
    locked,
    cardId,
    authMethod,
    success,
    monthDelta,
    dateKey,
    menuId,
    settingId,
    embedded,
    reviewMode,
  };
}

/// KST 기준 이용 시간대 라벨.
String kstTimeBandForNow() {
  final hour = _kstHour();
  if (hour >= 5 && hour < 9) return 'dawn';
  if (hour >= 9 && hour < 12) return 'morning';
  if (hour >= 12 && hour < 18) return 'afternoon';
  if (hour >= 18 && hour < 23) return 'evening';
  return 'late_night';
}

int kstHourNow() => _kstHour();

int _kstHour() {
  final kst = DateTime.now().toUtc().add(const Duration(hours: 9));
  return kst.hour;
}

/// 진도 % 구간(캘린더·스냅샷용).
String progressBucketFromPercent(int percent) {
  final p = percent.clamp(0, 100);
  if (p >= 80) return '80_100';
  if (p >= 40) return '40_79';
  return '0_39';
}
