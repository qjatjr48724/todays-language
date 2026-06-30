import 'analytics_events.dart';
import 'analytics_guard.dart';
import 'analytics_params.dart';
import 'app_analytics_service.dart';
import 'app_crashlytics_service.dart';

/// 화면·기능별 공통 Analytics 이벤트 헬퍼.
Future<void> logTabSelect(String tabName) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.tabSelect,
    {AnalyticsParamKeys.tabName: tabName},
  );
}

Future<void> logHomeCardTap(String cardId, {bool locked = false}) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.homeCardTap,
    {
      AnalyticsParamKeys.cardId: cardId,
      AnalyticsParamKeys.locked: locked,
    },
  );
}

Future<void> logLearningMarkDone({
  required String screenName,
  required String targetLanguage,
  required String level,
  bool reviewMode = false,
}) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.learningMarkDone,
    {
      AnalyticsParamKeys.screenName: screenName,
      AnalyticsParamKeys.targetLanguage: targetLanguage.toUpperCase(),
      AnalyticsParamKeys.level: level,
      AnalyticsParamKeys.reviewMode: reviewMode,
    },
  );
}

Future<void> logLearningNextSample({
  required String screenName,
  bool reviewMode = false,
}) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.learningNextSample,
    {
      AnalyticsParamKeys.screenName: screenName,
      AnalyticsParamKeys.reviewMode: reviewMode,
    },
  );
}

Future<void> logLearningRelearnStart({required String screenName}) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.learningRelearnStart,
    {AnalyticsParamKeys.screenName: screenName},
  );
}

Future<void> logWrapUpStart() {
  return AppAnalyticsService.instance.logEvent(AnalyticsEvents.wrapUpStart, {});
}

Future<void> logWrapUpComplete({required String progressBucket}) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.wrapUpComplete,
    {AnalyticsParamKeys.progressBucket: progressBucket},
  );
}

Future<void> logReviewDaySelect(int day) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.reviewDaySelect,
    {AnalyticsParamKeys.day: day},
  );
}

Future<void> logReviewTabSelect(String tab) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.reviewTabSelect,
    {AnalyticsParamKeys.tabName: tab},
  );
}

Future<void> logProgressMonthChange(int monthDelta) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.progressMonthChange,
    {AnalyticsParamKeys.monthDelta: monthDelta},
  );
}

Future<void> logProgressDayOpen(String dateKey) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.progressDayOpen,
    {AnalyticsParamKeys.dateKey: dateKey},
  );
}

Future<void> logCommunityMenuTap(String menuId) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.communityMenuTap,
    {AnalyticsParamKeys.menuId: menuId},
  );
}

Future<void> logChatMessageSend() {
  return AppAnalyticsService.instance.logEvent(AnalyticsEvents.chatMessageSend, {});
}

Future<void> logCertificationOpen({
  required String certId,
  required String entryPoint,
}) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.certificationOpen,
    {
      AnalyticsParamKeys.certId: certId,
      AnalyticsParamKeys.entryPoint: entryPoint,
    },
  );
}

Future<void> logCharacterTabSelect(String charTab) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.characterTabSelect,
    {AnalyticsParamKeys.charTab: charTab},
  );
}

Future<void> logAuthAttempt(String authMethod) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.authAttempt,
    {AnalyticsParamKeys.authMethod: authMethod},
  );
}

Future<void> logAuthResult({
  required String authMethod,
  required bool success,
}) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.authResult,
    {
      AnalyticsParamKeys.authMethod: authMethod,
      AnalyticsParamKeys.success: success,
    },
  );
}

Future<void> logLanguageSetupComplete({required String targetLanguage}) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.languageSetupComplete,
    {AnalyticsParamKeys.targetLanguage: targetLanguage.toUpperCase()},
  );
}

Future<void> logConsentComplete() {
  return AppAnalyticsService.instance.logEvent(AnalyticsEvents.consentComplete, {});
}

Future<void> logSettingsToggle({
  required String settingId,
  required bool enabled,
}) {
  return AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.settingsToggle,
    {
      AnalyticsParamKeys.settingId: settingId,
      AnalyticsParamKeys.enabled: enabled,
    },
  );
}

Future<void> logCallableFailure(Object error, StackTrace stack) {
  final code = AnalyticsGuard.safeLabel(error.runtimeType.toString());
  AppAnalyticsService.instance.logEvent(
    AnalyticsEvents.callableError,
    {if (code != null) AnalyticsParamKeys.errorCode: code},
  );
  return AppCrashlyticsService.instance.recordError(
    error,
    stack,
    errorCode: code,
  );
}
