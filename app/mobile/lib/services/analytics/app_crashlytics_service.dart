import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import 'analytics_guard.dart';
import 'analytics_params.dart';
import 'app_analytics_service.dart';

/// Firebase Crashlytics — uid·이메일 등 PII 미설정.
class AppCrashlyticsService {
  AppCrashlyticsService._();

  static final AppCrashlyticsService instance = AppCrashlyticsService._();

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  Future<void> initialize() async {
    await _crashlytics.setCrashlyticsCollectionEnabled(
      AppAnalyticsService.collectionEnabled,
    );
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      if (AppAnalyticsService.collectionEnabled) {
        _crashlytics.recordFlutterFatalError(details);
      }
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      if (AppAnalyticsService.collectionEnabled) {
        _crashlytics.recordError(error, stack, fatal: true);
      }
      return true;
    };
  }

  Future<void> setScreen(String screenName) async {
    if (!AppAnalyticsService.collectionEnabled) return;
    final safe = AnalyticsGuard.safeLabel(screenName);
    if (safe == null) return;
    await _crashlytics.setCustomKey(AnalyticsParamKeys.screenName, safe);
  }

  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? errorCode,
    bool fatal = false,
  }) async {
    if (!AppAnalyticsService.collectionEnabled) return;
    final code = AnalyticsGuard.safeLabel(errorCode, maxLen: 64);
    if (code != null) {
      await _crashlytics.setCustomKey(AnalyticsParamKeys.errorCode, code);
    }
    await _crashlytics.recordError(
      error,
      stack,
      fatal: fatal,
      reason: code,
    );
  }
}
