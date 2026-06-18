import { clampLearningDay, normalizeCurriculumLanguageCode } from "./curriculum_state";

/** `users/{uid}` — 이전 일차 복습(언어별, 단어·문장만) */
export const CURRICULUM_REVIEW_DAY_BY_LANGUAGE_FIELD =
  "curriculumReviewDayByLanguage";

export function parseCurriculumReviewDayByLanguage(
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

export function curriculumReviewDayForLanguage(
  userData: Record<string, unknown>,
  targetLanguage: string
): number | null {
  const lang = normalizeCurriculumLanguageCode(targetLanguage);
  const byLang = parseCurriculumReviewDayByLanguage(
    userData[CURRICULUM_REVIEW_DAY_BY_LANGUAGE_FIELD]
  );
  const day = byLang[lang];
  return day != null && day >= 1 ? day : null;
}

/** 복습 일차는 현재 학습 일차보다 작아야 함 (1..actual-1) */
export function isValidCurriculumReviewDay(
  reviewDay: number,
  actualLearningDay: number
): boolean {
  const day = clampLearningDay(reviewDay);
  const actual = clampLearningDay(actualLearningDay);
  return day >= 1 && day < actual;
}
