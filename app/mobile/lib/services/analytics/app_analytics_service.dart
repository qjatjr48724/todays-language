import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

import 'analytics_events.dart';
import 'analytics_guard.dart';
import 'analytics_params.dart';

/// Firebase Analytics 래퍼 — 릴리스 빌드에서만 전송, PII 화이트리스트 적용.
class AppAnalyticsService {
  AppAnalyticsService._();

  static final AppAnalyticsService instance = AppAnalyticsService._();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  String? _lastScreen;

  /// `--dart-define=ANALYTICS_FORCE_ENABLE=true` 로 디버그에서만 강제 활성화.
  static bool get collectionEnabled {
    const force = bool.fromEnvironment('ANALYTICS_FORCE_ENABLE');
    return force || kReleaseMode;
  }

  Future<void> logScreenView(String screenName) async {
    if (!collectionEnabled) return;
    final safe = AnalyticsGuard.safeLabel(screenName);
    if (safe == null) return;

    _lastScreen = safe;

    await _analytics.logScreenView(screenName: safe);
  }

  Future<void> logScreenDwell(String screenName, Duration dwell) async {
    if (!collectionEnabled) return;
    final safe = AnalyticsGuard.safeLabel(screenName);
    if (safe == null) return;
    final sec = dwell.inSeconds.clamp(0, 86400);
    if (sec <= 0) return;

    await logEvent(
      AnalyticsEvents.screenDwell,
      {
        AnalyticsParamKeys.screenName: safe,
        AnalyticsParamKeys.durationSec: sec,
      },
    );
  }

  Future<void> logAppSessionStart() async {
    if (!collectionEnabled) return;
    await logEvent(
      AnalyticsEvents.appSessionStart,
      {
        AnalyticsParamKeys.hourKst: kstHourNow(),
        AnalyticsParamKeys.timeBand: kstTimeBandForNow(),
      },
    );
  }

  Future<void> logAppBackground() async {
    if (!collectionEnabled) return;
    final screen = _lastScreen;
    if (screen == null) return;
    await logEvent(
      AnalyticsEvents.appBackground,
      {AnalyticsParamKeys.screenName: screen},
    );
  }

  Future<void> logEvent(
    String name,
    Map<String, Object?> params,
  ) async {
    if (!collectionEnabled) return;
    final eventName = AnalyticsGuard.safeLabel(name, maxLen: 40);
    if (eventName == null) return;
    final sanitized = AnalyticsGuard.sanitizeParams(params);
    try {
      if (sanitized.isEmpty) {
        await _analytics.logEvent(name: eventName);
        return;
      }
      await _analytics.logEvent(name: eventName, parameters: sanitized);
    } catch (e, st) {
      assert(() {
        debugPrint('[AppAnalyticsService] logEvent failed: $eventName $e');
        debugPrint('$st');
        return true;
      }());
    }
  }

  Future<void> onScreenDisposed(String screenName, DateTime enteredAt) async {
    await logScreenDwell(screenName, DateTime.now().difference(enteredAt));
    if (_lastScreen == screenName) {
      _lastScreen = null;
    }
  }

  String? get lastScreen => _lastScreen;
}
