import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/chat_message.dart';

void main() {
  group('ChatMessage.validateOutgoingText', () {
    test('trims and accepts non-empty text', () {
      expect(ChatMessage.validateOutgoingText('  hello  '), 'hello');
    });

    test('rejects empty text', () {
      expect(ChatMessage.validateOutgoingText('   '), isNull);
    });

    test('rejects text over max length', () {
      final long = 'a' * (ChatMessage.maxTextLength + 1);
      expect(ChatMessage.validateOutgoingText(long), isNull);
    });
  });

  group('ChatMessage.fromFirestore', () {
    test('parses stored fields', () {
      final m = ChatMessage.fromFirestore('id1', {
        'uid': 'u1',
        'displayName': 'Tester',
        'text': 'Hi',
        'createdAtMs': 1000,
        'targetLanguage': 'jpn',
      });
      expect(m.id, 'id1');
      expect(m.targetLanguage, 'JPN');
      expect(m.text, 'Hi');
    });
  });
}
