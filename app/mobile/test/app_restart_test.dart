import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/app_restart.dart';

void main() {
  test('restart invokes registered handler', () {
    var called = false;
    AppRestart.register(() => called = true);
    AppRestart.restart();
    expect(called, isTrue);
  });
}
