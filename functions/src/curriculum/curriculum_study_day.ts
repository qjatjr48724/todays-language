import { adminPreviewLearningDayForLanguage } from "../admin/curriculum_preview";
import { isAdminToolsUid } from "../admin/admin_tools_auth";
import type { UserLearningProfile } from "../learning_sets/user_learning_profile";
import {
  curriculumReviewDayForLanguage,
  isValidCurriculumReviewDay,
} from "./curriculum_review";
import { learningDayForLanguage } from "./curriculum_state";

/** 단어·문장 조회용 일차 — 관리자 프리뷰 > 복습 일차 > 실제 일차 */
export function resolveWordSentenceStudyDay(
  uid: string,
  userData: Record<string, unknown>,
  targetLanguage: string,
  actualLearningDay: number
): number {
  if (isAdminToolsUid(uid)) {
    const admin = adminPreviewLearningDayForLanguage(userData, targetLanguage);
    if (admin != null) {
      return admin;
    }
  }
  const review = curriculumReviewDayForLanguage(userData, targetLanguage);
  if (
    review != null &&
    isValidCurriculumReviewDay(review, actualLearningDay)
  ) {
    return review;
  }
  return actualLearningDay;
}

export function applyWordSentenceStudyDayToProfile(
  uid: string,
  userData: Record<string, unknown>,
  profile: UserLearningProfile
): UserLearningProfile {
  const actualLearningDay = learningDayForLanguage(
    userData,
    profile.targetLanguage
  );
  return {
    ...profile,
    learningDay: resolveWordSentenceStudyDay(
      uid,
      userData,
      profile.targetLanguage,
      actualLearningDay
    ),
  };
}
