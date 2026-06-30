import 'package:flutter/material.dart';

import 'analytics_screen_scope.dart';

/// Analytics 계측이 포함된 화면 push.
Future<T?> pushAnalyticsScreen<T>(
  BuildContext context, {
  required String screenName,
  required WidgetBuilder builder,
}) {
  return Navigator.of(context).push<T>(
    MaterialPageRoute(
      settings: RouteSettings(name: screenName),
      builder: (ctx) => AnalyticsScreenScope(
        screenName: screenName,
        child: Builder(builder: builder),
      ),
    ),
  );
}


/// 스택을 비우고 Analytics 계측 화면으로 이동.
Future<T?> pushAndRemoveUntilAnalyticsScreen<T>(
  BuildContext context, {
  required String screenName,
  required WidgetBuilder builder,
  required RoutePredicate predicate,
}) {
  return Navigator.of(context).pushAndRemoveUntil<T>(
    MaterialPageRoute(
      settings: RouteSettings(name: screenName),
      builder: (ctx) => AnalyticsScreenScope(
        screenName: screenName,
        child: Builder(builder: builder),
      ),
    ),
    predicate,
  );
}
