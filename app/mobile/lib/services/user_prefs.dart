import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../config/feature_flags.dart';
import '../models/curriculum_state.dart';

class UserPrefs {
  const UserPrefs({
    required this.targetLanguage,
    required this.level,
    required this.curriculum,
    this.previewLearningDay,
  });

  final String targetLanguage;
  final String level;
  final CurriculumState curriculum;

  /// 관리자 커리큘럼 테스트 일차(없으면 null)
  final int? previewLearningDay;

  int get displayLearningDay => previewLearningDay ?? curriculum.learningDay;

  // ISO-3166-1 alpha-3 표기: 기본값 JPN
  static UserPrefs fallback() => UserPrefs(
        targetLanguage: 'JPN',
        level: 'beginner',
        curriculum: CurriculumState.defaults(),
      );
}

Future<UserPrefs> fetchUserPrefs(User user) async {
  final snap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
  final data = snap.data() ?? <String, dynamic>{};
  final targetLanguage = (data['targetLanguage'] as String?)?.trim();
  final level = (data['level'] as String?)?.trim();
  return UserPrefs(
    // ISO-3166-1 alpha-3 표기: 기본값 JPN
    targetLanguage: (targetLanguage == null || targetLanguage.isEmpty) ? 'JPN' : targetLanguage,
    level: effectiveLearningLevel(level),
    curriculum: CurriculumState.fromUserData(
      data,
      targetLanguage: (targetLanguage == null || targetLanguage.isEmpty) ? 'JPN' : targetLanguage,
    ),
    previewLearningDay: CurriculumState.adminPreviewDayForLanguage(
      data,
      (targetLanguage == null || targetLanguage.isEmpty) ? 'JPN' : targetLanguage,
    ),
  );
}

