import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/wrap_up_quiz_builder.dart';

void main() {
  group('buildWrapUpQuizQuestions', () {
    test('returns empty when fewer than 4 deck entries', () {
      final q = buildWrapUpQuizQuestions(
        items: const [
          WrapUpDeckEntry(kind: 'word', meaningKo: '가다', answer: 'いく'),
          WrapUpDeckEntry(kind: 'word', meaningKo: '학교', answer: 'がっこう'),
        ],
        wordKindLabel: '단어',
        sentenceKindLabel: '문장',
        random: _fixedRandom(),
      );
      expect(q, isEmpty);
    });

    test('answerAudioPath is preserved on quiz question', () {
      const items = [
        WrapUpDeckEntry(
          kind: 'word',
          meaningKo: '가다',
          answer: 'いく',
          answerAudioPath: 'learning_audio/JPN/word1.mp3',
        ),
        WrapUpDeckEntry(kind: 'word', meaningKo: '학교', answer: 'がっこう'),
        WrapUpDeckEntry(kind: 'word', meaningKo: '오다', answer: 'くる'),
        WrapUpDeckEntry(
          kind: 'sentence',
          meaningKo: '학교에 가요',
          answer: 'がっこうにいく。',
          answerAudioPath: 'learning_audio/JPN/sent1.mp3',
        ),
      ];

      final q = buildWrapUpQuizQuestions(
        items: items,
        wordKindLabel: '단어',
        sentenceKindLabel: '문장',
        random: _fixedRandom(),
      );

      final withAudio = q.where((e) => e.answerAudioPath != null).toList();
      expect(withAudio, isNotEmpty);
      for (final question in withAudio) {
        expect(question.choices[question.correctIndex], question.correctAnswer);
        expect(question.answerAudioPath, isNotEmpty);
      }
    });

    test('each question has 4 choices with one correct answer', () {
      final items = [
        const WrapUpDeckEntry(kind: 'word', meaningKo: '가다', answer: 'いく'),
        const WrapUpDeckEntry(kind: 'word', meaningKo: '학교', answer: 'がっこう'),
        const WrapUpDeckEntry(kind: 'word', meaningKo: '오다', answer: 'くる'),
        const WrapUpDeckEntry(kind: 'sentence', meaningKo: '학교에 가요', answer: 'がっこうにいく。'),
      ];

      final q = buildWrapUpQuizQuestions(
        items: items,
        wordKindLabel: '단어',
        sentenceKindLabel: '문장',
        random: _fixedRandom(),
      );

      expect(q.length, 4);
      for (final question in q) {
        expect(question.choices.length, 4);
        expect(question.choices[question.correctIndex], question.correctAnswer);
        expect(question.choices.toSet().length, 4);
      }
    });
  });
}

/// shuffle 시드 고정용(테스트 결정론).
Random _fixedRandom() => Random(42);
