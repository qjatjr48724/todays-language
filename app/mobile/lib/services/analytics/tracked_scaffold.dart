import 'package:flutter/material.dart';

import 'analytics_screen_scope.dart';

/// [AnalyticsScreenScope] + [Scaffold] 단축 래퍼.
Widget trackedScaffold({
  required String screenName,
  required Widget scaffold,
}) {
  return AnalyticsScreenScope(
    screenName: screenName,
    child: scaffold,
  );
}
