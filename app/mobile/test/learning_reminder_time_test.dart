import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/utils/learning_reminder_time.dart';

void main() {
  test('accepts 08:00 and 20:50', () {
    expect(LearningReminderTime.isValid(hour: 8, minute: 0), isTrue);
    expect(LearningReminderTime.isValid(hour: 20, minute: 50), isTrue);
  });


  test('rejects outside range or non-10-minute steps', () {
    expect(LearningReminderTime.isValid(hour: 7, minute: 50), isFalse);
    expect(LearningReminderTime.isValid(hour: 21, minute: 0), isFalse);
    expect(LearningReminderTime.isValid(hour: 9, minute: 5), isFalse);
    expect(LearningReminderTime.isValid(hour: 20, minute: 60), isFalse);
  });


  test('clamp snaps invalid values into allowed window', () {
    final clamped = LearningReminderTime.clamp(hour: 3, minute: 7);
    expect(clamped.hour, LearningReminderTime.minHour);
    expect(clamped.minute, 0);
  });


  test('minute options are 10-minute steps', () {
    expect(LearningReminderTime.minuteOptions(), [0, 10, 20, 30, 40, 50]);
  });
}
