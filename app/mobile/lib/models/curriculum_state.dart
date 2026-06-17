/// 사용자 커리큘럼 학습 상태 — `users/{uid}` 필드 (Functions `curriculum_state.ts`와 동기).
///
/// learningDay: **학습 대상 언어(alpha-3)별** 커리큘럼 진행 일차(1..50).
/// 당일 단어·문장·마무리(15/5/13) 전부 완료 시 해당 언어만 +1 (D-1).
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

  /// `users/{uid}.learningDayByLanguage`
  static const String learningDayByLanguageField = 'learningDayByLanguage';

  /// 관리자 커리큘럼 테스트 일차 — `users/{uid}.adminCurriculumPreviewDayByLanguage`
  static const String adminCurriculumPreviewDayByLanguageField =
      'adminCurriculumPreviewDayByLanguage';

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

  /// [targetLanguage]가 주어지면 해당 언어의 `learningDayByLanguage` 값을 사용합니다.
  static CurriculumState fromUserData(
    Map<String, dynamic>? data, {
    String? targetLanguage,
  }) {
    final d = data ?? <String, dynamic>{};
    final def = defaults();
    final idRaw = (d['curriculumId'] as String?)?.trim();
    final lang = _normalizeLanguageCode(
      targetLanguage ?? (d['targetLanguage'] as String?) ?? 'JPN',
    );
    return CurriculumState(
      curriculumId: (idRaw == null || idRaw.isEmpty) ? def.curriculumId : idRaw,
      curriculumPhase: _parsePhase(d['curriculumPhase']) ?? def.curriculumPhase,
      learningDay: learningDayForLanguage(d, lang),
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

  static String _normalizeLanguageCode(String raw) {
    final v = raw.trim();
    if (v.isEmpty) return 'JPN';
    switch (v.toLowerCase()) {
      case 'ja':
        return 'JPN';
      case 'es':
        return 'ESP';
      default:
        return v.toUpperCase();
    }
  }

  static Map<String, int> parseLearningDayByLanguage(dynamic raw) {
    if (raw is! Map) return <String, int>{};
    final out = <String, int>{};
    for (final entry in raw.entries) {
      final lang = _normalizeLanguageCode(entry.key.toString());
      final n = entry.value is num ? (entry.value as num).toInt() : int.tryParse('${entry.value}');
      if (n != null) out[lang] = _clampLearningDay(n);
    }
    return out;
  }

  /// 구버전 최상위 `learningDay` → `learningDayByLanguage` 이전
  static Map<String, int> migrateLegacyLearningDayToByLanguage(
    Map<String, dynamic> data, {
    required String fallbackLanguage,
  }) {
    final existing = parseLearningDayByLanguage(data[learningDayByLanguageField]);
    if (existing.isNotEmpty) return existing;

    final lang = _normalizeLanguageCode(fallbackLanguage);
    if (data['learningDay'] == null) return <String, int>{};
    return {lang: _clampLearningDay(data['learningDay'])};
  }

  /// 특정 학습 언어의 커리큘럼 일차(1..50)
  static int learningDayForLanguage(
    Map<String, dynamic> data,
    String targetLanguage,
  ) {
    final lang = _normalizeLanguageCode(targetLanguage);
    final byLang = migrateLegacyLearningDayToByLanguage(
      data,
      fallbackLanguage: targetLanguage,
    );
    return byLang[lang] ?? defaults().learningDay;
  }

  static Map<String, int> parseAdminPreviewDayByLanguage(dynamic raw) {
    if (raw is! Map) return <String, int>{};
    final out = <String, int>{};
    for (final entry in raw.entries) {
      final lang = _normalizeLanguageCode(entry.key.toString());
      final n = entry.value is num ? (entry.value as num).toInt() : int.tryParse('${entry.value}');
      if (n != null) out[lang] = _clampLearningDay(n);
    }
    return out;
  }

  /// 관리자 테스트 일차(없으면 null)
  static int? adminPreviewDayForLanguage(
    Map<String, dynamic> data,
    String targetLanguage,
  ) {
    final lang = _normalizeLanguageCode(targetLanguage);
    final day = parseAdminPreviewDayByLanguage(
      data[adminCurriculumPreviewDayByLanguageField],
    )[lang];
    return day != null && day >= 1 ? day : null;
  }

  /// 관리자 프리뷰가 있으면 우선, 없으면 실제 learningDay
  static int effectiveLearningDayForLanguage(
    Map<String, dynamic> data,
    String targetLanguage,
  ) {
    final preview = adminPreviewDayForLanguage(data, targetLanguage);
    if (preview != null) return preview;
    return learningDayForLanguage(data, targetLanguage);
  }

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
