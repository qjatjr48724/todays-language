import 'analytics_params.dart';

/// PII·자유 텍스트가 Analytics/Crashlytics로 나가지 않도록 화이트리스트 검증.
class AnalyticsGuard {
  /// 금지 키(화이트리스트 외·민감 키워드 포함 시 거부).
  static const blockedKeyFragments = <String>[
    'email',
    'password',
    'uid',
    'user_id',
    'userid',
    'message',
    'content',
    'text',
    'body',
    'name',
    'phone',
    'address',
    'token',
    'secret',
    'nickname',
    'display',
  ];

  static Map<String, Object> sanitizeParams(Map<String, Object?> raw) {
    final out = <String, Object>{};
    for (final entry in raw.entries) {
      final key = entry.key.trim();
      if (key.isEmpty) continue;
      if (!_isAllowedKey(key)) continue;
      final value = entry.value;
      if (value == null) continue;
      final sanitized = _sanitizeValue(value);
      if (sanitized != null) {
        out[key] = sanitized;
      }
    }
    return out;
  }

  static bool _isAllowedKey(String key) {
    return AnalyticsParamKeys.allowedKeys.contains(key);
  }

  static Object? _sanitizeValue(Object value) {
    if (value is bool || value is int) return value;
    if (value is double) return value.round();
    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty || trimmed.length > 64) return null;
      if (_looksLikePii(trimmed)) return null;
      return trimmed;
    }
    return null;
  }

  static bool _looksLikePii(String value) {
    if (value.contains('@')) return true;
    if (RegExp(r'^\d{10,}$').hasMatch(value)) return true;
    return false;
  }

  /// Crashlytics 로그/커스텀 키용 짧은 라벨.
  static String? safeLabel(String? value, {int maxLen = 48}) {
    if (value == null) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed.length > maxLen) return null;
    if (_looksLikePii(trimmed)) return null;
    return trimmed;
  }
}
