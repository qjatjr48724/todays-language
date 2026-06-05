import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/curriculum_state.dart';

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
}
