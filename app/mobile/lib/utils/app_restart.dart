import 'package:flutter/foundation.dart';

/// [AppRoot]에 등록된 핸들러로 위젯 트리를 재구성해 앱을 재시작합니다.
class AppRestart {
  AppRestart._();

  static VoidCallback? _handler;

  /// [AppRoot.initState]에서 1회 등록합니다.
  static void register(VoidCallback handler) {
    _handler = handler;
  }

  static void restart() {
    final handler = _handler;
    if (handler == null) {
      assert(() {
        debugPrint('AppRestart.restart: handler not registered');
        return true;
      }());
      return;
    }
    handler();
  }
}
