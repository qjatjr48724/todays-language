import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/chat_message.dart';
import 'package:mobile/utils/chat_message_timeline.dart';

ChatMessage _msg(int ms, {String text = 'hi'}) {
  return ChatMessage(
    id: 'id-$ms',
    uid: 'u1',
    displayName: 'Tester',
    text: text,
    createdAtMs: ms,
    targetLanguage: 'JPN',
  );
}

void main() {
  group('chat KST time', () {
    test('formatKstHhMm는 KST 기준 HH:mm을 반환', () {
      // 2026-06-14 14:35 KST = 2026-06-14 05:35 UTC
      final ms = DateTime.utc(2026, 6, 14, 5, 35).millisecondsSinceEpoch;
      expect(formatKstHhMm(ms), '14:35');
    });
  });

  group('buildChatTimeline', () {
    test('같은 날 메시지는 날짜 구분선 1회만 표시', () {
      final day1a = DateTime.utc(2026, 6, 14, 0, 0).millisecondsSinceEpoch;
      final day1b = DateTime.utc(2026, 6, 14, 12, 0).millisecondsSinceEpoch;

      final items = buildChatTimeline([
        _msg(day1a),
        _msg(day1b),
      ]);

      expect(items.length, 3);
      expect(items[0].type, ChatTimelineItemType.dateDivider);
      expect(items[1].type, ChatTimelineItemType.message);
      expect(items[2].type, ChatTimelineItemType.message);
    });

    test('KST 자정 이후 첫 메시지에 날짜 구분선 추가', () {
      // 2026-06-14 23:00 KST
      final day1 = DateTime.utc(2026, 6, 14, 14, 0).millisecondsSinceEpoch;
      // 2026-06-15 01:00 KST
      final day2 = DateTime.utc(2026, 6, 14, 16, 0).millisecondsSinceEpoch;

      final items = buildChatTimeline([
        _msg(day1),
        _msg(day2),
      ]);

      expect(items.length, 4);
      expect(items[0].type, ChatTimelineItemType.dateDivider);
      expect(items[1].type, ChatTimelineItemType.message);
      expect(items[2].type, ChatTimelineItemType.dateDivider);
      expect(items[3].type, ChatTimelineItemType.message);
    });
  });
}
