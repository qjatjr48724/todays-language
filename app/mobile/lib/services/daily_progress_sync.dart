import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/curriculum_state.dart';
import '../utils/kst_date.dart';

// `quiz`는 현재 "오늘의 마무리" 점검 진행도를 의미합니다.
enum DailyProgressKind { word, sentence, quiz }

/// Functions `DAILY_WORD_COUNT` / `DAILY_SENTENCE_COUNT` / wrap-up deck과 동기화
const int kDailyWordGoalDefault = 15;
const int kDailySentenceGoalDefault = 5;
const int kDailyQuizGoalDefault = 13;

/// 언어별 당일 진척도 맵 필드 (`KOR` / `JPN` / `USA` …)
const String kByLanguageField = 'byLanguage';

/// [docs/FIRESTORE_MIN_SCHEMA.md] — `users/{uid}/daily_progress/{dateKst}`
class DailyProgressView {
  const DailyProgressView({
    required this.dateKst,
    required this.wordGoal,
    required this.wordDone,
    required this.sentenceGoal,
    required this.sentenceDone,
    required this.quizGoal,
    required this.quizDone,
    required this.progressPercent,
  });

  final String dateKst;
  final int wordGoal;
  final int wordDone;
  final int sentenceGoal;
  final int sentenceDone;
  final int quizGoal;
  final int quizDone;

  /// 당일 전체 진행률 — 언어 중 가장 높은 학습률(0~100).
  final int progressPercent;

  static DailyProgressView fromMap(String dateKst, Map<String, dynamic> m) {
    int iv(String k, int def) {
      final v = m[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      return def;
    }

    return DailyProgressView(
      dateKst: m['dateKst'] as String? ?? dateKst,
      wordGoal: iv('wordGoal', kDailyWordGoalDefault),
      wordDone: iv('wordDone', 0),
      sentenceGoal: iv('sentenceGoal', kDailySentenceGoalDefault),
      sentenceDone: iv('sentenceDone', 0),
      quizGoal: iv('quizGoal', kDailyQuizGoalDefault),
      quizDone: iv('quizDone', 0),
      progressPercent: iv('progressPercent', 0).clamp(0, 100),
    );
  }
}


/// 언어 코드를 daily_progress `byLanguage` 키(alpha-3)로 통일합니다.
String normalizeDailyProgressLanguageCode(String raw) {
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


/// 언어별 단어·문장·마무리 완료 수.
class LanguageProgressSlice {
  const LanguageProgressSlice({
    required this.wordDone,
    required this.sentenceDone,
    required this.quizDone,
  });

  final int wordDone;
  final int sentenceDone;
  final int quizDone;

  static const LanguageProgressSlice empty = LanguageProgressSlice(
    wordDone: 0,
    sentenceDone: 0,
    quizDone: 0,
  );

  Map<String, int> toFirestoreMap() => {
        'wordDone': wordDone,
        'sentenceDone': sentenceDone,
        'quizDone': quizDone,
      };

  LanguageProgressSlice copyWith({
    int? wordDone,
    int? sentenceDone,
    int? quizDone,
  }) {
    return LanguageProgressSlice(
      wordDone: wordDone ?? this.wordDone,
      sentenceDone: sentenceDone ?? this.sentenceDone,
      quizDone: quizDone ?? this.quizDone,
    );
  }
}


int _intFromDynamic(dynamic v, int def) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  return def;
}


LanguageProgressSlice parseLanguageProgressSlice(Map<String, dynamic>? raw) {
  if (raw == null || raw.isEmpty) return LanguageProgressSlice.empty;
  return LanguageProgressSlice(
    wordDone: _intFromDynamic(raw['wordDone'], 0),
    sentenceDone: _intFromDynamic(raw['sentenceDone'], 0),
    quizDone: _intFromDynamic(raw['quizDone'], 0),
  );
}


Map<String, LanguageProgressSlice> parseByLanguageField(dynamic raw) {
  if (raw is! Map) return <String, LanguageProgressSlice>{};
  final out = <String, LanguageProgressSlice>{};
  for (final entry in raw.entries) {
    final lang = normalizeDailyProgressLanguageCode(entry.key.toString());
    if (entry.value is Map) {
      out[lang] = parseLanguageProgressSlice(
        Map<String, dynamic>.from(entry.value as Map),
      );
    }
  }
  return out;
}


Map<String, dynamic> serializeByLanguageField(
  Map<String, LanguageProgressSlice> byLanguage,
) {
  return byLanguage.map(
    (lang, slice) => MapEntry(lang, slice.toFirestoreMap()),
  );
}


/// 구버전(최상위 wordDone 등) 문서를 `byLanguage`로 이전합니다.
Map<String, LanguageProgressSlice> migrateLegacyProgressToByLanguage(
  Map<String, dynamic> data, {
  required String fallbackLanguage,
}) {
  final existing = parseByLanguageField(data[kByLanguageField]);
  if (existing.isNotEmpty) return existing;

  final lang = normalizeDailyProgressLanguageCode(fallbackLanguage);
  final legacy = LanguageProgressSlice(
    wordDone: _intFromDynamic(data['wordDone'], 0),
    sentenceDone: _intFromDynamic(data['sentenceDone'], 0),
    quizDone: _intFromDynamic(data['quizDone'], 0),
  );
  if (legacy.wordDone == 0 &&
      legacy.sentenceDone == 0 &&
      legacy.quizDone == 0) {
    return existing;
  }
  return {lang: legacy};
}


int computeSliceProgressPercent({
  required LanguageProgressSlice slice,
  required int wordGoal,
  required int sentenceGoal,
  required int quizGoal,
}) {
  final totalGoal = wordGoal + sentenceGoal + quizGoal;
  if (totalGoal <= 0) return 0;
  final totalDone = slice.wordDone + slice.sentenceDone + slice.quizDone;
  return ((totalDone / totalGoal) * 100).round().clamp(0, 100);
}


/// 당일 학습률이 가장 높은 언어의 진행률(0~100)을 반환합니다.
int computeMaxProgressPercentAcrossLanguages({
  required Map<String, LanguageProgressSlice> byLanguage,
  required int wordGoal,
  required int sentenceGoal,
  required int quizGoal,
}) {
  if (byLanguage.isEmpty) return 0;
  var maxPercent = 0;
  for (final slice in byLanguage.values) {
    final percent = computeSliceProgressPercent(
      slice: slice,
      wordGoal: wordGoal,
      sentenceGoal: sentenceGoal,
      quizGoal: quizGoal,
    );
    if (percent > maxPercent) maxPercent = percent;
  }
  return maxPercent;
}


LanguageProgressSlice sliceForLanguage(
  Map<String, LanguageProgressSlice> byLanguage,
  String targetLanguage,
) {
  return byLanguage[normalizeDailyProgressLanguageCode(targetLanguage)] ??
      LanguageProgressSlice.empty;
}


bool isLanguageSliceComplete({
  required LanguageProgressSlice slice,
  required int wordGoal,
  required int sentenceGoal,
  required int quizGoal,
}) {
  return slice.wordDone >= wordGoal &&
      slice.sentenceDone >= sentenceGoal &&
      slice.quizDone >= quizGoal;
}


DailyProgressView buildDailyProgressView({
  required String dateKst,
  required int wordGoal,
  required int sentenceGoal,
  required int quizGoal,
  required LanguageProgressSlice slice,
  required int displayProgressPercent,
}) {
  return DailyProgressView(
    dateKst: dateKst,
    wordGoal: wordGoal,
    wordDone: slice.wordDone,
    sentenceGoal: sentenceGoal,
    sentenceDone: slice.sentenceDone,
    quizGoal: quizGoal,
    quizDone: slice.quizDone,
    progressPercent: displayProgressPercent.clamp(0, 100),
  );
}


// --- D-1: 당일 15/5/13 완료 시 커리큘럼 일차(learningDay) +1 ---

/// `daily_progress/{dateKst}` — 해당 KST 날짜 완료로 learningDay +1 처리 여부
const String kCurriculumDayAdvancedField = 'curriculumDayAdvanced';


/// 일일 목표(단어·문장·마무리)를 모두 달성했는지 확인합니다.
bool isDailyProgressComplete(DailyProgressView progress) {
  return progress.wordDone >= progress.wordGoal &&
      progress.sentenceDone >= progress.sentenceGoal &&
      progress.quizDone >= progress.quizGoal;
}


/// Firestore 맵 기준 — 언어 중 하나라도 당일 목표를 달성했는지 확인합니다.
bool isDailyProgressMapComplete(Map<String, dynamic> data) {
  final wordGoal = _intFromDynamic(data['wordGoal'], kDailyWordGoalDefault);
  final sentenceGoal =
      _intFromDynamic(data['sentenceGoal'], kDailySentenceGoalDefault);
  final quizGoal = _intFromDynamic(data['quizGoal'], kDailyQuizGoalDefault);

  final byLanguage = parseByLanguageField(data[kByLanguageField]);
  if (byLanguage.isNotEmpty) {
    for (final slice in byLanguage.values) {
      if (isLanguageSliceComplete(
        slice: slice,
        wordGoal: wordGoal,
        sentenceGoal: sentenceGoal,
        quizGoal: quizGoal,
      )) {
        return true;
      }
    }
    return false;
  }

  // 구버전 최상위 필드 호환
  return _intFromDynamic(data['wordDone'], 0) >= wordGoal &&
      _intFromDynamic(data['sentenceDone'], 0) >= sentenceGoal &&
      _intFromDynamic(data['quizDone'], 0) >= quizGoal;
}


/// 커리큘럼 모드(초·중)에서 learningDay를 올릴 수 있는지 확인합니다.
bool canAdvanceLearningDayForUser(Map<String, dynamic> userData) {
  final state = CurriculumState.fromUserData(userData);
  if (state.learningMode != 'curriculum') return false;

  final level =
      CurriculumState.normalizeLearningLevel(userData['level'] as String?);
  if (level == 'advanced') return false;

  return state.learningDay < CurriculumState.totalDays;
}


/// 트랜잭션 안에서 일일 완료 시 learningDay +1 (중복 방지).
Future<bool> tryAdvanceLearningDayInTransaction(
  Transaction tx, {
  required DocumentReference<Map<String, dynamic>> userRef,
  required DocumentReference<Map<String, dynamic>> progressRef,
  required Map<String, dynamic> progressData,
}) async {
  if (!isDailyProgressMapComplete(progressData)) return false;
  if (progressData[kCurriculumDayAdvancedField] == true) return false;

  final userSnap = await tx.get(userRef);
  final userData = userSnap.data() ?? <String, dynamic>{};

  if (!canAdvanceLearningDayForUser(userData)) {
    tx.set(
      progressRef,
      {kCurriculumDayAdvancedField: true},
      SetOptions(merge: true),
    );
    return false;
  }

  final currentDay = CurriculumState.fromUserData(userData).learningDay;
  final nextDay = (currentDay + 1).clamp(1, CurriculumState.totalDays);

  tx.set(
    userRef,
    {
      'learningDay': nextDay,
      'updatedAt': FieldValue.serverTimestamp(),
    },
    SetOptions(merge: true),
  );
  tx.set(
    progressRef,
    {kCurriculumDayAdvancedField: true},
    SetOptions(merge: true),
  );
  return true;
}


/// 특정 KST 날짜 문서가 완료됐으면 learningDay +1을 시도합니다.
Future<bool> tryAdvanceLearningDayForDate(User user, String dateKst) async {
  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final progressRef = userRef.collection('daily_progress').doc(dateKst);

  return FirebaseFirestore.instance.runTransaction((tx) async {
    final progressSnap = await tx.get(progressRef);
    if (!progressSnap.exists) return false;

    final data = progressSnap.data() ?? <String, dynamic>{};
    return tryAdvanceLearningDayInTransaction(
      tx,
      userRef: userRef,
      progressRef: progressRef,
      progressData: data,
    );
  });
}


/// 과거 완료·미반영 일차를 순서대로 보정합니다 (D-1 미구현 기간 백필).
Future<int> reconcilePendingLearningDayAdvances(User user) async {
  final today = kstNowDate();
  var advancedCount = 0;

  for (var daysAgo = 30; daysAgo >= 0; daysAgo--) {
    final dateKst = formatYyyyMmDd(today.subtract(Duration(days: daysAgo)));
    final progressed = await tryAdvanceLearningDayForDate(user, dateKst);
    if (progressed) advancedCount += 1;
  }
  return advancedCount;
}


DailyProgressView _viewFromFirestoreData({
  required String dateKst,
  required Map<String, dynamic> data,
  required String targetLanguage,
}) {
  final wordGoal = _intFromDynamic(data['wordGoal'], kDailyWordGoalDefault);
  final sentenceGoal =
      _intFromDynamic(data['sentenceGoal'], kDailySentenceGoalDefault);
  final quizGoal = _intFromDynamic(data['quizGoal'], kDailyQuizGoalDefault);

  final byLanguage = migrateLegacyProgressToByLanguage(
    data,
    fallbackLanguage: targetLanguage,
  );
  final slice = sliceForLanguage(byLanguage, targetLanguage);
  final maxPercent = computeMaxProgressPercentAcrossLanguages(
    byLanguage: byLanguage,
    wordGoal: wordGoal,
    sentenceGoal: sentenceGoal,
    quizGoal: quizGoal,
  );

  return buildDailyProgressView(
    dateKst: dateKst,
    wordGoal: wordGoal,
    sentenceGoal: sentenceGoal,
    quizGoal: quizGoal,
    slice: slice,
    displayProgressPercent: maxPercent,
  );
}


/// 오늘(KST) 문서가 없으면 스키마 기본값으로 생성하고, 있으면 `updatedAt`만 갱신합니다.
///
/// [targetLanguage]가 주어지면 해당 언어의 단어·문장·마무리 진척도를 반환하고,
/// 전체 진행률(`progressPercent`)은 당일 가장 높은 언어 학습률을 사용합니다.
Future<DailyProgressView> ensureTodayDailyProgress(
  User user, {
  String? targetLanguage,
}) async {
  final dateKst = todayKstYyyyMmDd();
  final ref = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('daily_progress')
      .doc(dateKst);

  final lang = normalizeDailyProgressLanguageCode(targetLanguage ?? 'JPN');

  final snap = await ref.get();
  if (!snap.exists) {
    await ref.set({
      'dateKst': dateKst,
      'wordGoal': kDailyWordGoalDefault,
      'sentenceGoal': kDailySentenceGoalDefault,
      'quizGoal': kDailyQuizGoalDefault,
      kByLanguageField: <String, dynamic>{},
      'progressPercent': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  } else {
    final data = snap.data() ?? <String, dynamic>{};
    final byLanguage = migrateLegacyProgressToByLanguage(
      data,
      fallbackLanguage: lang,
    );
    if (data[kByLanguageField] == null && byLanguage.isNotEmpty) {
      await ref.set(
        {
          kByLanguageField: serializeByLanguageField(byLanguage),
          'progressPercent': computeMaxProgressPercentAcrossLanguages(
            byLanguage: byLanguage,
            wordGoal: _intFromDynamic(data['wordGoal'], kDailyWordGoalDefault),
            sentenceGoal:
                _intFromDynamic(data['sentenceGoal'], kDailySentenceGoalDefault),
            quizGoal: _intFromDynamic(data['quizGoal'], kDailyQuizGoalDefault),
          ),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } else {
      await ref.set(
        {'updatedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    }
  }

  final after = await ref.get();
  final data = after.data() ?? {};
  return _viewFromFirestoreData(
    dateKst: dateKst,
    data: data,
    targetLanguage: lang,
  );
}


/// 오늘(KST) 진도를 1회 증가시키고 progressPercent까지 갱신합니다.
///
/// - [targetLanguage] 언어 슬라이스만 증가합니다.
/// - 전체 `progressPercent`는 당일 가장 높은 언어 학습률로 저장합니다.
Future<DailyProgressView> incrementTodayDailyProgress(
  User user, {
  required DailyProgressKind kind,
  required String targetLanguage,
}) async {
  final dateKst = todayKstYyyyMmDd();
  final ref = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('daily_progress')
      .doc(dateKst);

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final lang = normalizeDailyProgressLanguageCode(targetLanguage);

  return FirebaseFirestore.instance.runTransaction((tx) async {
    final snap = await tx.get(ref);
    final data = snap.data() ?? <String, dynamic>{};

    final wordGoal = _intFromDynamic(data['wordGoal'], kDailyWordGoalDefault);
    final sentenceGoal =
        _intFromDynamic(data['sentenceGoal'], kDailySentenceGoalDefault);
    final quizGoal = _intFromDynamic(data['quizGoal'], kDailyQuizGoalDefault);

    var byLanguage = migrateLegacyProgressToByLanguage(
      data,
      fallbackLanguage: lang,
    );
    var slice = sliceForLanguage(byLanguage, lang);

    switch (kind) {
      case DailyProgressKind.word:
        slice = slice.copyWith(
          wordDone: (slice.wordDone + 1).clamp(0, wordGoal),
        );
      case DailyProgressKind.sentence:
        slice = slice.copyWith(
          sentenceDone: (slice.sentenceDone + 1).clamp(0, sentenceGoal),
        );
      case DailyProgressKind.quiz:
        slice = slice.copyWith(
          quizDone: (slice.quizDone + 1).clamp(0, quizGoal),
        );
    }

    byLanguage = Map<String, LanguageProgressSlice>.from(byLanguage)
      ..[lang] = slice;

    final maxPercent = computeMaxProgressPercentAcrossLanguages(
      byLanguage: byLanguage,
      wordGoal: wordGoal,
      sentenceGoal: sentenceGoal,
      quizGoal: quizGoal,
    );

    final progressPayload = <String, dynamic>{
      'dateKst': dateKst,
      'wordGoal': wordGoal,
      'sentenceGoal': sentenceGoal,
      'quizGoal': quizGoal,
      kByLanguageField: serializeByLanguageField(byLanguage),
      'progressPercent': maxPercent,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    tx.set(ref, progressPayload, SetOptions(merge: true));

    await tryAdvanceLearningDayInTransaction(
      tx,
      userRef: userRef,
      progressRef: ref,
      progressData: progressPayload,
    );

    return buildDailyProgressView(
      dateKst: dateKst,
      wordGoal: wordGoal,
      sentenceGoal: sentenceGoal,
      quizGoal: quizGoal,
      slice: slice,
      displayProgressPercent: maxPercent,
    );
  });
}


/// 오늘(KST) 진도를 0으로 초기화하고 progressPercent까지 갱신합니다.
///
/// - goal 값은 유지합니다.
/// - 모든 언어 슬라이스를 초기화합니다.
Future<DailyProgressView> resetTodayDailyProgress(
  User user, {
  String targetLanguage = 'JPN',
}) async {
  final dateKst = todayKstYyyyMmDd();
  final ref = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('daily_progress')
      .doc(dateKst);

  final resetView = await FirebaseFirestore.instance.runTransaction((tx) async {
    final snap = await tx.get(ref);
    final data = snap.data() ?? <String, dynamic>{};

    final wordGoal = _intFromDynamic(data['wordGoal'], kDailyWordGoalDefault);
    final sentenceGoal =
        _intFromDynamic(data['sentenceGoal'], kDailySentenceGoalDefault);
    final quizGoal = _intFromDynamic(data['quizGoal'], kDailyQuizGoalDefault);

    tx.set(
      ref,
      {
        'dateKst': dateKst,
        'wordGoal': wordGoal,
        'sentenceGoal': sentenceGoal,
        'quizGoal': quizGoal,
        kByLanguageField: <String, dynamic>{},
        'progressPercent': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return buildDailyProgressView(
      dateKst: dateKst,
      wordGoal: wordGoal,
      sentenceGoal: sentenceGoal,
      quizGoal: quizGoal,
      slice: LanguageProgressSlice.empty,
      displayProgressPercent: 0,
    );
  });

  // 진행률 초기화 시, 퀴즈·단어·문장 개인 커서 문서를 제거합니다 (글로벌 세트는 Functions 소유).
  final cursorCol = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('daily_quiz_cursor');
  final wordCursorCol = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('daily_word_cursor');
  final sentenceCursorCol = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('daily_sentence_cursor');

  final batch = FirebaseFirestore.instance.batch();
  final cursorSnap =
      await cursorCol.where('dateKst', isEqualTo: dateKst).get();
  for (final doc in cursorSnap.docs) {
    batch.delete(doc.reference);
  }
  final wordCursorSnap =
      await wordCursorCol.where('dateKst', isEqualTo: dateKst).get();
  for (final doc in wordCursorSnap.docs) {
    batch.delete(doc.reference);
  }
  final sentenceCursorSnap =
      await sentenceCursorCol.where('dateKst', isEqualTo: dateKst).get();
  for (final doc in sentenceCursorSnap.docs) {
    batch.delete(doc.reference);
  }
  await batch.commit();

  return resetView;
}


/// Firestore 일일 진도 맵을 [targetLanguage] 기준 뷰로 변환합니다.
DailyProgressView dailyProgressViewForLanguage(
  String dateKst,
  Map<String, dynamic> data, {
  required String targetLanguage,
}) {
  return _viewFromFirestoreData(
    dateKst: dateKst,
    data: data,
    targetLanguage: targetLanguage,
  );
}
