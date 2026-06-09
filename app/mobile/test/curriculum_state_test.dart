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

    test('clampLearningDay', () {
      final state = CurriculumState.fromUserData({'learningDay': 999});
      expect(state.learningDay, CurriculumState.totalDays);
    });

    test('normalizeLearningLevel', () {
      expect(CurriculumState.normalizeLearningLevel('Intermediate'), 'intermediate');
      expect(CurriculumState.normalizeLearningLevel('invalid'), 'beginner');
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


    test('isDailyProgressMapComplete matches view rule', () {
      expect(
        isDailyProgressMapComplete({
          'wordGoal': 15,
          'wordDone': 15,
          'sentenceGoal': 5,
          'sentenceDone': 5,
          'quizGoal': 13,
          'quizDone': 13,
        }),
        isTrue,
      );
    });
  });


  group('D-1 canAdvanceLearningDayForUser', () {
    test('allows beginner curriculum user below day 50', () {
      expect(
        canAdvanceLearningDayForUser({
          'learningMode': 'curriculum',
          'level': 'beginner',
          'learningDay': 1,
        }),
        isTrue,
      );
    });


    test('blocks advanced level and non-curriculum mode', () {
      expect(
        canAdvanceLearningDayForUser({
          'learningMode': 'curriculum',
          'level': 'advanced',
          'learningDay': 1,
        }),
        isFalse,
      );
      expect(
        canAdvanceLearningDayForUser({
          'learningMode': 'free_study',
          'level': 'beginner',
          'learningDay': 1,
        }),
        isFalse,
      );
    });


    test('blocks when already at total days', () {
      expect(
        canAdvanceLearningDayForUser({
          'learningMode': 'curriculum',
          'level': 'intermediate',
          'learningDay': CurriculumState.totalDays,
        }),
        isFalse,
      );
    });
  });
}
