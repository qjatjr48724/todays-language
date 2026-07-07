import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/config/feature_flags.dart';
import 'package:mobile/models/curriculum_state.dart';
import 'package:mobile/services/daily_progress_sync.dart';

void main() {
  group('CurriculumState', () {
    test('fromUserData uses defaults for empty doc', () {
      final state = CurriculumState.fromUserData({});
      final def = CurriculumState.defaults();
      expect(state.curriculumId, def.curriculumId);
      expect(state.curriculumPhase, def.curriculumPhase);
      expect(state.learningDay, def.learningDay);
      expect(state.learningMode, def.learningMode);
      expect(state.cycleReviewStatus, def.cycleReviewStatus);
    });

    test('backfillPatch does not overwrite existing progress', () {
      final patch = CurriculumState.backfillPatch({
        'curriculumId': 'core_v1',
        'curriculumPhase': 2,
        'learningDay': 25,
        'learningMode': 'review',
        'cycleReviewStatus': 'in_progress',
        'level': 'intermediate',
      });
      expect(patch, isEmpty);
    });

    test('backfillPatch fills missing curriculum fields', () {
      final patch = CurriculumState.backfillPatch({'learningDay': 3});
      expect(patch['curriculumId'], 'core_v1');
      expect(patch['curriculumPhase'], 1);
      expect(patch['learningMode'], 'curriculum');
      expect(patch['cycleReviewStatus'], 'none');
      expect(patch['level'], 'beginner');
      expect(patch.containsKey('learningDay'), isFalse);
    });

    test('fromUserData uses per-language learningDay', () {
      final state = CurriculumState.fromUserData(
        {
          'learningDayByLanguage': {'KOR': 3, 'JPN': 1},
        },
        targetLanguage: 'JPN',
      );
      expect(state.learningDay, 1);
    });


    test('fromUserData migrates legacy learningDay', () {
      final state = CurriculumState.fromUserData(
        {'learningDay': 5, 'targetLanguage': 'KOR'},
        targetLanguage: 'KOR',
      );
      expect(state.learningDay, 5);
    });


    test('clampLearningDay', () {
      final state = CurriculumState.fromUserData(
        {'learningDayByLanguage': {'KOR': 999}},
        targetLanguage: 'KOR',
      );
      expect(state.learningDay, CurriculumState.totalDays);
    });

    test('normalizeLearningLevel', () {
      expect(CurriculumState.normalizeLearningLevel('Intermediate'), 'intermediate');
      expect(CurriculumState.normalizeLearningLevel('invalid'), 'beginner');
    });

    test('usesCurriculumLearningSets', () {
      expect(
        CurriculumState.usesCurriculumLearningSets(
          level: 'beginner',
          learningMode: 'curriculum',
        ),
        isTrue,
      );
      expect(
        CurriculumState.usesCurriculumLearningSets(
          level: 'advanced',
          learningMode: 'curriculum',
        ),
        isFalse,
      );
      expect(
        CurriculumState.usesCurriculumLearningSets(
          level: 'beginner',
          learningMode: 'free_study',
        ),
        isFalse,
      );
    });
  });


  group('effectiveLearningLevel', () {
    test('forces beginner when difficulty UI is off', () {
      expect(effectiveLearningLevel('intermediate'), 'beginner');
      expect(effectiveLearningLevel('advanced'), 'beginner');
      expect(effectiveLearningLevel('beginner'), 'beginner');
      expect(effectiveLearningLevel(null), 'beginner');
    });
  });


  group('D-1 daily progress completion', () {
    test('isDailyProgressComplete when all goals met', () {
      const view = DailyProgressView(
        dateKst: '2026-05-27',
        wordGoal: 15,
        wordDone: 15,
        sentenceGoal: 5,
        sentenceDone: 5,
        quizGoal: 13,
        quizDone: 13,
        progressPercent: 100,
      );
      expect(isDailyProgressComplete(view), isTrue);
    });


    test('isDailyProgressComplete false when any goal remains', () {
      const view = DailyProgressView(
        dateKst: '2026-05-27',
        wordGoal: 15,
        wordDone: 15,
        sentenceGoal: 5,
        sentenceDone: 5,
        quizGoal: 13,
        quizDone: 12,
        progressPercent: 99,
      );
      expect(isDailyProgressComplete(view), isFalse);
    });


    test('isLanguageDailyProgressComplete matches language slice', () {
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
  });


  group('D-1 canAdvanceLearningDayForUser', () {
    test('allows beginner curriculum user below day 50', () {
      expect(
        canAdvanceLearningDayForUser(
          {
            'learningMode': 'curriculum',
            'level': 'beginner',
            'learningDayByLanguage': {'KOR': 1},
          },
          targetLanguage: 'KOR',
        ),
        isTrue,
      );
    });


    test('blocks advanced level and non-curriculum mode', () {
      expect(
        canAdvanceLearningDayForUser(
          {
            'learningMode': 'curriculum',
            'level': 'advanced',
            'learningDayByLanguage': {'KOR': 1},
          },
          targetLanguage: 'KOR',
        ),
        isFalse,
      );
      expect(
        canAdvanceLearningDayForUser(
          {
            'learningMode': 'free_study',
            'level': 'beginner',
            'learningDayByLanguage': {'KOR': 1},
          },
          targetLanguage: 'KOR',
        ),
        isFalse,
      );
    });


    test('blocks when already at total days', () {
      expect(
        canAdvanceLearningDayForUser(
          {
            'learningMode': 'curriculum',
            'level': 'intermediate',
            'learningDayByLanguage': {'JPN': CurriculumState.totalDays},
          },
          targetLanguage: 'JPN',
        ),
        isFalse,
      );
    });

    test('effectiveLearningDayForLanguage uses admin preview when set', () {
      expect(
        CurriculumState.effectiveLearningDayForLanguage(
          {
            'learningDayByLanguage': {'JPN': 2},
            CurriculumState.adminCurriculumPreviewDayByLanguageField: {'JPN': 7},
          },
          'JPN',
        ),
        7,
      );
    });

    test('curriculumReviewDayForLanguage only returns valid prior days', () {
      expect(
        CurriculumState.curriculumReviewDayForLanguage(
          {
            'learningDayByLanguage': {'JPN': 4},
            CurriculumState.curriculumReviewDayByLanguageField: {'JPN': 3},
          },
          'JPN',
        ),
        3,
      );
      expect(
        CurriculumState.curriculumReviewDayForLanguage(
          {
            'learningDayByLanguage': {'JPN': 4},
            CurriculumState.curriculumReviewDayByLanguageField: {'JPN': 4},
          },
          'JPN',
        ),
        isNull,
      );
      expect(
        CurriculumState.canShowCurriculumReviewMenu(
          {'learningDayByLanguage': {'JPN': 1}},
          'JPN',
        ),
        isFalse,
      );
    });
  });
}
