import 'package:flutter/material.dart';

import 'app_analytics_service.dart';
import 'app_crashlytics_service.dart';

/// 화면 진입·체류·퇴장 Analytics/Crashlytics 계측.
class AnalyticsScreenScope extends StatefulWidget {
  const AnalyticsScreenScope({
    super.key,
    required this.screenName,
    required this.child,
  });

  final String screenName;
  final Widget child;

  @override
  State<AnalyticsScreenScope> createState() => _AnalyticsScreenScopeState();
}

class _AnalyticsScreenScopeState extends State<AnalyticsScreenScope> {
  late final DateTime _enteredAt;

  @override
  void initState() {
    super.initState();
    _enteredAt = DateTime.now();
    AppAnalyticsService.instance.logScreenView(widget.screenName);
    AppCrashlyticsService.instance.setScreen(widget.screenName);
  }

  @override
  void dispose() {
    AppAnalyticsService.instance.onScreenDisposed(
      widget.screenName,
      _enteredAt,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
