import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/app_notification_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
    TestWidgetsFlutterBinding.ensureInitialized();

    setUp(() {
        SharedPreferences.setMockInitialValues({});
    });


    test('setEnabled false stores preference', () async {
        await AppNotificationPreferences.setEnabled(false);
        expect(await AppNotificationPreferences.isEnabled(), isFalse);
    });


    test('setEnabled true stores preference', () async {
        await AppNotificationPreferences.setEnabled(true);
        expect(await AppNotificationPreferences.isEnabled(), isTrue);
    });


    test('shouldDeliver is false when app notifications disabled', () async {
        await AppNotificationPreferences.setEnabled(false);
        expect(await AppNotificationPreferences.shouldDeliver(), isFalse);
    });
}
