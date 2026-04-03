import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/kst_date.dart';

// `quiz`는 현재 "오늘의 마무리" 점검 진행도를 의미합니다.
enum DailyProgressKind { word, sentence, quiz }

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
      wordGoal: iv('wordGoal', 30),
      wordDone: iv('wordDone', 0),
      sentenceGoal: iv('sentenceGoal', 10),
      sentenceDone: iv('sentenceDone', 0),
      quizGoal: iv('quizGoal', 25),
      quizDone: iv('quizDone', 0),
      progressPercent: iv('progressPercent', 0).clamp(0, 100),
    );
  }
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
      'wordGoal': 30,
      'wordDone': 0,
      'sentenceGoal': 10,
      'sentenceDone': 0,
      'quizGoal': 25,
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

  return FirebaseFirestore.instance.runTransaction((tx) async {
    final snap = await tx.get(ref);
    final data = snap.data() ?? <String, dynamic>{};

    int iv(String k, int def) {
      final v = data[k];
      if (v is int) return v;
      if (v is num) return v.toInt();
      return def;
    }

    final wordGoal = iv('wordGoal', 30);
    final sentenceGoal = iv('sentenceGoal', 10);
    final quizGoal = iv('quizGoal', 25);

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

    tx.set(
      ref,
      {
        'dateKst': dateKst,
        'wordGoal': wordGoal,
        'wordDone': wordDone,
        'sentenceGoal': sentenceGoal,
        'sentenceDone': sentenceDone,
        'quizGoal': quizGoal,
        'quizDone': quizDone,
        'progressPercent': percent,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
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

    final wordGoal = iv('wordGoal', 30);
    final sentenceGoal = iv('sentenceGoal', 10);
    final quizGoal = iv('quizGoal', 25);

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
