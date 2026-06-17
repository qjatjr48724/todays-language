import {
  clampLearningDay,
  normalizeCurriculumLanguageCode,
} from "../curriculum/curriculum_state";
import type { UserLearningProfile } from "../learning_sets/user_learning_profile";
import { isAdminToolsUid } from "./admin_tools_auth";

/** `users/{uid}` — 관리자 커리큘럼 일차 테스트 오버라이드(언어별) */
export const ADMIN_CURRICULUM_PREVIEW_DAY_BY_LANGUAGE_FIELD =
  "adminCurriculumPreviewDayByLanguage";

export function parseAdminPreviewDayByLanguage(
  raw: unknown
): Record<string, number> {
  if (typeof raw !== "object" || raw === null) {
    return {};
  }
  const out: Record<string, number> = {};
  for (const [key, value] of Object.entries(raw)) {
    const lang = normalizeCurriculumLanguageCode(key);
    const n =
      typeof value === "number"
        ? Math.floor(value)
        : typeof value === "string"
          ? Number.parseInt(value, 10)
          : Number.NaN;
    if (Number.isFinite(n)) {
      out[lang] = clampLearningDay(n);
    }
  }
  return out;
}

export function adminPreviewLearningDayForLanguage(
  userData: Record<string, unknown>,
  targetLanguage: string
): number | null {
  const lang = normalizeCurriculumLanguageCode(targetLanguage);
  const byLang = parseAdminPreviewDayByLanguage(
    userData[ADMIN_CURRICULUM_PREVIEW_DAY_BY_LANGUAGE_FIELD]
  );
  const day = byLang[lang];
  return day != null && day >= 1 ? day : null;
}

/** 관리자 프리뷰 일차가 있으면 우선, 없으면 실제 learningDay */
export function resolveEffectiveLearningDay(
  userData: Record<string, unknown>,
  targetLanguage: string,
  actualLearningDay: number
): number {
  const preview = adminPreviewLearningDayForLanguage(userData, targetLanguage);
  return preview ?? actualLearningDay;
}

/** 관리자 커리큘럼 테스트 일차가 있으면 profile.learningDay에 반영 */
export function applyAdminPreviewToProfile(
  uid: string,
  userData: Record<string, unknown>,
  profile: UserLearningProfile
): UserLearningProfile {
  if (!isAdminToolsUid(uid)) {
    return profile;
  }
  return {
    ...profile,
    learningDay: resolveEffectiveLearningDay(
      userData,
      profile.targetLanguage,
      profile.learningDay
    ),
  };
}
