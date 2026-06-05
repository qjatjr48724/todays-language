/// 사용자 커리큘럼 학습 상태 — `users/{uid}` 필드 (Functions `curriculum_state.ts`와 동기).
class CurriculumState {
  const CurriculumState({
    required this.curriculumId,
    required this.curriculumPhase,
    required this.learningDay,
    required this.learningMode,
    required this.cycleReviewStatus,
  });

  static const String coreV1Id = 'core_v1';
  static const int totalDays = 50;
  static const int phaseMin = 1;
  static const int phaseMax = 2;

  static const Set<String> learningLevels = {'beginner', 'intermediate', 'advanced'};

  final String curriculumId;
  final int curriculumPhase;
  final int learningDay;
  final String learningMode;
  final String cycleReviewStatus;

  /// Firestore `level` 정규화 — beginner | intermediate | advanced
  static String normalizeLearningLevel(String? raw, {String fallback = 'beginner'}) {
    final v = (raw ?? '').trim().toLowerCase();
    if (learningLevels.contains(v)) return v;
    return fallback;
  }

  static CurriculumState defaults() => const CurriculumState(
        curriculumId: coreV1Id,
        curriculumPhase: 1,
        learningDay: 1,
        learningMode: 'curriculum',
        cycleReviewStatus: 'none',
      );

  static CurriculumState fromUserData(Map<String, dynamic>? data) {
    final d = data ?? <String, dynamic>{};
    final def = defaults();
    final idRaw = (d['curriculumId'] as String?)?.trim();
    return CurriculumState(
      curriculumId: (idRaw == null || idRaw.isEmpty) ? def.curriculumId : idRaw,
      curriculumPhase: _parsePhase(d['curriculumPhase']) ?? def.curriculumPhase,
      learningDay: _clampLearningDay(d['learningDay']),
      learningMode: _parseLearningMode(d['learningMode']) ?? def.learningMode,
      cycleReviewStatus:
          _parseCycleReviewStatus(d['cycleReviewStatus']) ?? def.cycleReviewStatus,
    );
  }

  /// 기존 유저 백필 — 키가 없을 때만 기본값 (진행 중 값은 덮어쓰지 않음).
  static Map<String, dynamic> backfillPatch(Map<String, dynamic>? existing) {
    final d = existing ?? <String, dynamic>{};
    final def = defaults();
    final patch = <String, dynamic>{};

    final idRaw = (d['curriculumId'] as String?)?.trim();
    if (idRaw == null || idRaw.isEmpty) {
      patch['curriculumId'] = def.curriculumId;
    }
    if (_parsePhase(d['curriculumPhase']) == null) {
      patch['curriculumPhase'] = def.curriculumPhase;
    }
    if (d['learningDay'] == null) {
      patch['learningDay'] = def.learningDay;
    } else {
      final clamped = _clampLearningDay(d['learningDay']);
      if (clamped != (d['learningDay'] as num).toInt()) {
        patch['learningDay'] = clamped;
      }
    }
    if (_parseLearningMode(d['learningMode']) == null) {
      patch['learningMode'] = def.learningMode;
    }
    if (_parseCycleReviewStatus(d['cycleReviewStatus']) == null) {
      patch['cycleReviewStatus'] = def.cycleReviewStatus;
    }
    final levelRaw = (d['level'] as String?)?.trim();
    if (levelRaw == null || levelRaw.isEmpty) {
      patch['level'] = 'beginner';
    }

    return patch;
  }

  Map<String, dynamic> toFirestore() => {
        'curriculumId': curriculumId,
        'curriculumPhase': curriculumPhase,
        'learningDay': learningDay,
        'learningMode': learningMode,
        'cycleReviewStatus': cycleReviewStatus,
      };

  static int _clampLearningDay(Object? raw) {
    final n = raw is num ? raw.toInt() : int.tryParse('$raw');
    if (n == null || n < 1) return 1;
    if (n > totalDays) return totalDays;
    return n;
  }

  static int? _parsePhase(Object? raw) {
    final n = raw is num ? raw.toInt() : int.tryParse('$raw');
    if (n == 1 || n == 2) return n;
    return null;
  }

  static String? _parseLearningMode(Object? raw) {
    final v = (raw as String?)?.trim().toLowerCase();
    const allowed = {'curriculum', 'review', 'free_study'};
    if (v != null && allowed.contains(v)) return v;
    return null;
  }

  static String? _parseCycleReviewStatus(Object? raw) {
    final v = (raw as String?)?.trim().toLowerCase();
    const allowed = {'none', 'available', 'in_progress', 'completed', 'skipped'};
    if (v != null && allowed.contains(v)) return v;
    return null;
  }
}
