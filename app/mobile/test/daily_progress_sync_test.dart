import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/daily_progress_sync.dart';

void main() {
  group('언어별 일일 진도', () {
    test('computeMaxProgressPercentAcrossLanguages는 최고 학습률을 반환', () {
      final byLanguage = <String, LanguageProgressSlice>{
        'KOR': const LanguageProgressSlice(
          wordDone: 5,
          sentenceDone: 0,
          quizDone: 0,
        ),
        'JPN': const LanguageProgressSlice(
          wordDone: 10,
          sentenceDone: 2,
          quizDone: 0,
        ),
      };

      final max = computeMaxProgressPercentAcrossLanguages(
        byLanguage: byLanguage,
        wordGoal: 15,
        sentenceGoal: 5,
        quizGoal: 13,
      );

      // JPN: (10+2)/(15+5+13) = 12/33 ≈ 36%
      expect(max, 36);
    });


    test('sliceForLanguage는 미학습 언어를 0으로 반환', () {
      final byLanguage = <String, LanguageProgressSlice>{
        'KOR': const LanguageProgressSlice(
          wordDone: 5,
          sentenceDone: 0,
          quizDone: 0,
        ),
      };

      final jpn = sliceForLanguage(byLanguage, 'JPN');
      expect(jpn.wordDone, 0);
      expect(jpn.sentenceDone, 0);
      expect(jpn.quizDone, 0);
    });


    test('migrateLegacyProgressToByLanguage는 구버전 최상위 필드를 이전', () {
      final migrated = migrateLegacyProgressToByLanguage(
        {
          'wordDone': 5,
          'sentenceDone': 1,
          'quizDone': 0,
        },
        fallbackLanguage: 'KOR',
      );

      expect(migrated['KOR']?.wordDone, 5);
      expect(migrated['KOR']?.sentenceDone, 1);
    });


    test('isLanguageDailyProgressComplete는 해당 언어만 완료 판정', () {
      expect(
        isLanguageDailyProgressComplete(
          {
            'wordGoal': 15,
            'sentenceGoal': 5,
            'quizGoal': 13,
            kByLanguageField: {
              'KOR': {'wordDone': 5, 'sentenceDone': 0, 'quizDone': 0},
              'JPN': {
                'wordDone': 15,
                'sentenceDone': 5,
                'quizDone': 13,
              },
            },
          },
          'JPN',
        ),
        isTrue,
      );
      expect(
        isLanguageDailyProgressComplete(
          {
            'wordGoal': 15,
            'sentenceGoal': 5,
            'quizGoal': 13,
            kByLanguageField: {
              'KOR': {'wordDone': 5, 'sentenceDone': 0, 'quizDone': 0},
            },
          },
          'KOR',
        ),
        isFalse,
      );
    });


    test('dailyProgressEntriesByLanguage는 언어별 슬라이스 목록을 반환', () {
      final entries = dailyProgressEntriesByLanguage(
        '2026-05-28',
        {
          'wordGoal': 15,
          'sentenceGoal': 5,
          'quizGoal': 13,
          kByLanguageField: {
            'KOR': {'wordDone': 5, 'sentenceDone': 0, 'quizDone': 0},
            'JPN': {'wordDone': 10, 'sentenceDone': 2, 'quizDone': 0},
          },
        },
        preferredLanguage: 'JPN',
      );

      expect(entries.length, 2);
      expect(entries.first.languageCode, 'JPN');
      expect(entries.first.view.wordDone, 10);
      expect(entries.last.languageCode, 'KOR');
      expect(entries.last.view.wordDone, 5);
    });
  });
}
