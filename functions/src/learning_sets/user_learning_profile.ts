import * as admin from "firebase-admin";

import {
  curriculumStateFromUserData,
  normalizeLearningLevel,
} from "../curriculum/curriculum_state";

/** 커리큘럼 세트 AI 생성 대상 level (초·중) */
export const CURRICULUM_SET_LEVELS = new Set(["beginner", "intermediate"]);

export type UserLearningProfile = {
  targetLanguage: string;
  level: string;
  curriculumPhase: 1 | 2;
  learningDay: number;
};

export function isCurriculumSetLevel(level: string): boolean {
  return CURRICULUM_SET_LEVELS.has(level.trim().toLowerCase());
}

/** users/{uid}에서 학습 프로필 로드 */
export async function loadUserLearningProfile(
  db: admin.firestore.Firestore,
  uid: string,
  normalizeTargetLanguage: (code: string) => { external: string; internal: string }
): Promise<UserLearningProfile> {
  const snap = await db.collection("users").doc(uid).get();
  const data = snap.data() ?? {};
  const tl = normalizeTargetLanguage((data.targetLanguage as string) ?? "JPN");
  const level = normalizeLearningLevel(data.level);
  const state = curriculumStateFromUserData(data as Record<string, unknown>);
  return {
    targetLanguage: tl.external,
    level,
    curriculumPhase: state.curriculumPhase,
    learningDay: state.learningDay,
  };
}
