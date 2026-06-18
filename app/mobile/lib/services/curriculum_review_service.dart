import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/curriculum_state.dart';

/// Functions `curriculum_set_keys.ts`와 동일 — `JPN_beginner_1_7`
String curriculumSetDocId({
  required String targetLanguage,
  required String level,
  required int curriculumPhase,
  required int learningDay,
}) {
  final tl = targetLanguage.trim().toUpperCase();
  final lv = level.trim().toLowerCase();
  final phase = curriculumPhase == 2 ? 2 : 1;
  final day = learningDay.clamp(1, CurriculumState.totalDays);
  return '${tl}_${lv}_${phase}_$day';
}

const String kGlobalLearningSetOwnerUid = 'global_learning_set_owner';

class CurriculumReviewDayItem {
  const CurriculumReviewDayItem({
    required this.learningDay,
    required this.ready,
  });

  final int learningDay;
  final bool ready;
}

/// 현재 일차 미만(1..N-1) 일차 목록 — 앱에서 계산, Firestore로 세트 준비 여부만 조회.
Future<List<CurriculumReviewDayItem>> loadPriorCurriculumReviewDays({
  required int currentLearningDay,
  required String targetLanguage,
  required String level,
  required int curriculumPhase,
}) async {
  if (currentLearningDay <= 1) {
    return const [];
  }

  final owner = FirebaseFirestore.instance
      .collection('users')
      .doc(kGlobalLearningSetOwnerUid);
  final wordCol = owner.collection('curriculum_word_sets');
  final sentenceCol = owner.collection('curriculum_sentence_sets');

  final items = <CurriculumReviewDayItem>[];
  for (var day = currentLearningDay - 1; day >= 1; day--) {
    final docId = curriculumSetDocId(
      targetLanguage: targetLanguage,
      level: level,
      curriculumPhase: curriculumPhase,
      learningDay: day,
    );
    final results = await Future.wait([
      wordCol.doc(docId).get(),
      sentenceCol.doc(docId).get(),
    ]);
    final wordData = results[0].data();
    final sentenceData = results[1].data();
    final words = wordData?['words'];
    final sentences = sentenceData?['sentences'];
    final ready = words is List &&
        words.isNotEmpty &&
        sentences is List &&
        sentences.isNotEmpty;
    items.add(CurriculumReviewDayItem(learningDay: day, ready: ready));
  }
  return items;
}

/// `users/{uid}.curriculumReviewDayByLanguage` — null이면 복습 해제.
Future<void> saveCurriculumReviewDay({
  required String uid,
  required String targetLanguage,
  int? learningDay,
}) async {
  final lang = CurriculumState.normalizeLanguageCodeForStorage(targetLanguage);
  final docRef = FirebaseFirestore.instance.collection('users').doc(uid);
  final snap = await docRef.get();
  final data = snap.data() ?? <String, dynamic>{};
  final byLang = CurriculumState.parseCurriculumReviewDayByLanguage(
    data[CurriculumState.curriculumReviewDayByLanguageField],
  );
  if (learningDay == null) {
    byLang.remove(lang);
  } else {
    byLang[lang] = learningDay;
  }
  await docRef.set(
    {CurriculumState.curriculumReviewDayByLanguageField: byLang},
    SetOptions(merge: true),
  );
}
