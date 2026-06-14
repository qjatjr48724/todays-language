import '../models/chat_message.dart';

/// 채팅 타임라인 항목 — 날짜 구분선 또는 메시지.
enum ChatTimelineItemType { dateDivider, message }

class ChatTimelineItem {
  const ChatTimelineItem._({
    required this.type,
    this.message,
    this.createdAtMs,
  });

  const ChatTimelineItem.dateDivider(int createdAtMs)
      : this._(
          type: ChatTimelineItemType.dateDivider,
          createdAtMs: createdAtMs,
        );

  const ChatTimelineItem.message(ChatMessage message)
      : this._(
          type: ChatTimelineItemType.message,
          message: message,
        );

  final ChatTimelineItemType type;
  final ChatMessage? message;
  final int? createdAtMs;
}


/// epoch ms → KST 시각(UTC+9).
DateTime kstDateTimeFromEpochMs(int ms) {
  final utc = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
  final kst = utc.add(const Duration(hours: 9));
  return DateTime(
    kst.year,
    kst.month,
    kst.day,
    kst.hour,
    kst.minute,
    kst.second,
    kst.millisecond,
  );
}


/// KST 날짜 키 `yyyy-MM-dd` — 자정 기준 일별 구분용.
String kstDateKeyFromEpochMs(int ms) {
  final kst = kstDateTimeFromEpochMs(ms);
  final y = kst.year.toString().padLeft(4, '0');
  final m = kst.month.toString().padLeft(2, '0');
  final d = kst.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}


/// KST 기준 `HH:mm` 표기.
String formatKstHhMm(int ms) {
  final kst = kstDateTimeFromEpochMs(ms);
  final h = kst.hour.toString().padLeft(2, '0');
  final m = kst.minute.toString().padLeft(2, '0');
  return '$h:$m';
}


/// 오래된 순 메시지 목록에 KST 날짜 구분선을 삽입합니다.
List<ChatTimelineItem> buildChatTimeline(List<ChatMessage> messages) {
  final out = <ChatTimelineItem>[];
  String? previousDateKey;

  for (final message in messages) {
    final dateKey = kstDateKeyFromEpochMs(message.createdAtMs);
    if (previousDateKey != dateKey) {
      out.add(ChatTimelineItem.dateDivider(message.createdAtMs));
      previousDateKey = dateKey;
    }
    out.add(ChatTimelineItem.message(message));
  }

  return out;
}
