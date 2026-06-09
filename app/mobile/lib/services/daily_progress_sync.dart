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


// --- D-1: 당일 15/5/13 완료 시 커리큘럼 일차(learningDay) +1 ---

/// `daily_progress/{dateKst}` — 해당 KST 날짜 완료로 learningDay +1 처리 여부
const String kCurriculumDayAdvancedField = 'curriculumDayAdvanced';


/// 일일 목표(단어·문장·마무리)를 모두 달성했는지 확인합니다.
bool isDailyProgressComplete(DailyProgressView progress) {
  return progress.wordDone >= progress.wordGoal &&
      progress.sentenceDone >= progress.sentenceGoal &&
      progress.quizDone >= progress.quizGoal;
}


/// Firestore 맵 기준 일일 완료 여부 (트랜잭션 내부용).
bool isDailyProgressMapComplete(Map<String, dynamic> data) {
  int iv(String k, int def) {
    final v = data[k];
    if (v is int) return v;
    if (v is num) return v.toInt();
    return def;
  }

  final wordGoal = iv('wordGoal', kDailyWordGoalDefault);
  final sentenceGoal = iv('sentenceGoal', kDailySentenceGoalDefault);
  final quizGoal = iv('quizGoal', kDailyQuizGoalDefault);
  final wordDone = iv('wordDone', 0);
  final sentenceDone = iv('sentenceDone', 0);
  final quizDone = iv('quizDone', 0);

  return wordDone >= wordGoal &&
      sentenceDone >= sentenceGoal &&
      quizDone >= quizGoal;
}


/// 커리큘럼 모드(초·중)에서 learningDay를 올릴 수 있는지 확인합니다.
bool canAdvanceLearningDayForUser(Map<String, dynamic> userData) {
  final state = CurriculumState.fromUserData(userData);
  if (state.learningMode != 'curriculum') return false;

  final level = CurriculumState.normalizeLearningLevel(userData['level'] as String?);
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


/// 오늘(KST) 문서가 없으면 스키마 기본값으로 생성하고, 있으면 `updatedAt`만 갱신합니다.
Future<DailyProgressView> ensureTodayDailyProgress(User user) async {
  final dateKst = todayKstYyyyMmDd();
  final ref = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('daily_progress')
      .doc(dateKst);

  final snap = await ref.get();
  if (!snap.exists) {
    await ref.set({
      'dateKst': dateKst,
      'wordGoal': kDailyWordGoalDefault,
      'wordDone': 0,
      'sentenceGoal': kDailySentenceGoalDefault,
      'sentenceDone': 0,
      'quizGoal': kDailyQuizGoalDefault,
      'quizDone': 0,
      'progressPercent': 0,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  } else {
    await ref.set(
      {'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  final after = await ref.get();
  final data = after.data() ?? {};
  return DailyProgressView.fromMap(dateKst, data);
}

/// 오늘(KST) 진도를 1회 증가시키고 progressPercent까지 갱신합니다.
///
/// - 트랜잭션으로 동시 업데이트를 안전하게 처리합니다.
/// - goal을 초과하지 않도록 clamp 합니다.
Future<DailyProgressView> incrementTodayDailyProgress(
  User user, {
  required DailyProgressKind kind,
}) async {
  final dateKst = todayKstYyyyMmDd();
  final ref = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('daily_progress')
      .doc(dateKst);

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

  return FirebaseFirestore.instance.runTransaction((tx) async {
    final snap = await tx.get(ref);
    final data = snap.data() ?? <String, dynamic>{};

    int iv(String k, int def) {
      final v = data[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      return def;
    }

    final wordGoal = iv('wordGoal', kDailyWordGoalDefault);
    final sentenceGoal = iv('sentenceGoal', kDailySentenceGoalDefault);
    final quizGoal = iv('quizGoal', kDailyQuizGoalDefault);

    var wordDone = iv('wordDone', 0);
    var sentenceDone = iv('sentenceDone', 0);
    var quizDone = iv('quizDone', 0);

    switch (kind) {
      case DailyProgressKind.word:
        wordDone = (wordDone + 1).clamp(0, wordGoal);
      case DailyProgressKind.sentence:
        sentenceDone = (sentenceDone + 1).clamp(0, sentenceGoal);
      case DailyProgressKind.quiz:
        quizDone = (quizDone + 1).clamp(0, quizGoal);
    }

    final totalGoal = wordGoal + sentenceGoal + quizGoal;
    final totalDone = wordDone + sentenceDone + quizDone;
    final percent = totalGoal <= 0
        ? 0
        : ((totalDone / totalGoal) * 100).round().clamp(0, 100);

    final progressPayload = <String, dynamic>{
      'dateKst': dateKst,
      'wordGoal': wordGoal,
      'wordDone': wordDone,
      'sentenceGoal': sentenceGoal,
      'sentenceDone': sentenceDone,
      'quizGoal': quizGoal,
      'quizDone': quizDone,
      'progressPercent': percent,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    tx.set(ref, progressPayload, SetOptions(merge: true));

    await tryAdvanceLearningDayInTransaction(
      tx,
      userRef: userRef,
      progressRef: ref,
      progressData: progressPayload,
    );

    return DailyProgressView(
      dateKst: dateKst,
      wordGoal: wordGoal,
      wordDone: wordDone,
      sentenceGoal: sentenceGoal,
      sentenceDone: sentenceDone,
      quizGoal: quizGoal,
      quizDone: quizDone,
      progressPercent: percent,
    );
  });
}

/// 오늘(KST) 진도를 0으로 초기화하고 progressPercent까지 갱신합니다.
///
/// - goal 값은 유지합니다.
/// - 문서가 없어도 생성/병합되도록 처리합니다.
Future<DailyProgressView> resetTodayDailyProgress(User user) async {
  final dateKst = todayKstYyyyMmDd();
  final ref = FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .collection('daily_progress')
      .doc(dateKst);

  final resetView = await FirebaseFirestore.instance.runTransaction((tx) async {
    final snap = await tx.get(ref);
    final data = snap.data() ?? <String, dynamic>{};

    int iv(String k, int def) {
      final v = data[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      return def;
    }

    final wordGoal = iv('wordGoal', kDailyWordGoalDefault);
    final sentenceGoal = iv('sentenceGoal', kDailySentenceGoalDefault);
    final quizGoal = iv('quizGoal', kDailyQuizGoalDefault);

    tx.set(
      ref,
      {
        'dateKst': dateKst,
        'wordGoal': wordGoal,
        'wordDone': 0,
        'sentenceGoal': sentenceGoal,
        'sentenceDone': 0,
        'quizGoal': quizGoal,
        'quizDone': 0,
        'progressPercent': 0,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    return DailyProgressView(
      dateKst: dateKst,
      wordGoal: wordGoal,
      wordDone: 0,
      sentenceGoal: sentenceGoal,
      sentenceDone: 0,
      quizGoal: quizGoal,
      quizDone: 0,
      progressPercent: 0,
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
  final cursorSnap = await cursorCol.where('dateKst', isEqualTo: dateKst).get();
  for (final doc in cursorSnap.docs) {
    batch.delete(doc.reference);
  }
  final wordCursorSnap = await wordCursorCol.where('dateKst', isEqualTo: dateKst).get();
  for (final doc in wordCursorSnap.docs) {
    batch.delete(doc.reference);
  }
  final sentenceCursorSnap = await sentenceCursorCol.where('dateKst', isEqualTo: dateKst).get();
  for (final doc in sentenceCursorSnap.docs) {
    batch.delete(doc.reference);
  }
  await batch.commit();

  return resetView;
}
