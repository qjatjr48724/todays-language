import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/learning_reminder_preferences.dart';
import 'package:mobile/utils/learning_reminder_time.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });


  test('markSkipped completes setup without enabling', () async {
    await LearningReminderPreferences.markSkipped();
    expect(await LearningReminderPreferences.isSetupDone(), isTrue);
    expect(await LearningReminderPreferences.isEnabled(), isFalse);
  });


  test('markEnabled stores clamped time and enables', () async {
    await LearningReminderPreferences.markEnabled(hour: 9, minute: 20);
    expect(await LearningReminderPreferences.isSetupDone(), isTrue);
    expect(await LearningReminderPreferences.isEnabled(), isTrue);
    final time = await LearningReminderPreferences.loadTime();
    expect(time.hour, 9);
    expect(time.minute, 20);
  });


  test('resetForLanguageFlow clears setup and reminder prefs', () async {
    await LearningReminderPreferences.markEnabled(hour: 10, minute: 30);
    await LearningReminderPreferences.resetForLanguageFlow();
    expect(await LearningReminderPreferences.isSetupDone(), isFalse);
    expect(await LearningReminderPreferences.isEnabled(), isFalse);
    final time = await LearningReminderPreferences.loadTime();
    expect(time.hour, LearningReminderTime.defaultHour);
    expect(time.minute, LearningReminderTime.defaultMinute);
  });
}
