import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/kst_date.dart';

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
      wordGoal: iv('wordGoal', 50),
      wordDone: iv('wordDone', 0),
      sentenceGoal: iv('sentenceGoal', 10),
      sentenceDone: iv('sentenceDone', 0),
      quizGoal: iv('quizGoal', 20),
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
      'wordGoal': 50,
      'wordDone': 0,
      'sentenceGoal': 10,
      'sentenceDone': 0,
      'quizGoal': 20,
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
