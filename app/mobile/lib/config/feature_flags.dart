import '../models/curriculum_state.dart';

/// 앱 기능 on/off — 재활성화 시 true로 되돌리면 됩니다.
/// Functions `LEARNING_DIFFICULTY_UI_ENABLED`와 함께 유지합니다.
const bool kLearningDifficultyUiEnabled = false;


/// 난이도 UI 비활성 시 초급 고정.
String effectiveLearningLevel(String? raw) {
  if (!kLearningDifficultyUiEnabled) {
    return 'beginner';
  }
  return CurriculumState.normalizeLearningLevel(raw);
}
