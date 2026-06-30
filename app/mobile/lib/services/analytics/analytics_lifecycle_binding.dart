import 'package:flutter/widgets.dart';

import 'app_analytics_service.dart';

/// 앱 포그라운드·백그라운드 — 세션 시간대·이탈 화면 계측.
class AnalyticsLifecycleBinding extends WidgetsBindingObserver {
  AnalyticsLifecycleBinding._();

  static final AnalyticsLifecycleBinding instance = AnalyticsLifecycleBinding._();

  bool _installed = false;

  void install() {
    if (_installed) return;
    WidgetsBinding.instance.addObserver(this);
    _installed = true;
    AppAnalyticsService.instance.logAppSessionStart();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      AppAnalyticsService.instance.logAppSessionStart();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      AppAnalyticsService.instance.logAppBackground();
    }
  }
}
