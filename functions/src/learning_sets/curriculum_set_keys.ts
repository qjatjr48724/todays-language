/**
 * 커리큘럼 기반 학습 세트 문서 키 (Phase C 연동용).
 * 레거시 KST 날짜 키(`{dateKst}_{lang}_{level}`)와 병행한다.
 */

import { clampLearningDay, parseCurriculumPhase } from "../curriculum/curriculum_state";

export const CURRICULUM_WORD_SETS_SUBCOLLECTION = "curriculum_word_sets";
export const CURRICULUM_SENTENCE_SETS_SUBCOLLECTION = "curriculum_sentence_sets";

/** `JPN_beginner_1_7` — targetLanguage(alpha-3) × level × phase × learningDay */
export function curriculumSetDocId(
  targetLanguage: string,
  level: string,
  phase: number,
  learningDay: number
): string {
  const tl = targetLanguage.trim().toUpperCase();
  const lv = level.trim().toLowerCase();
  const p = parseCurriculumPhase(phase) ?? 1;
  const day = clampLearningDay(learningDay);
  return `${tl}_${lv}_${p}_${day}`;
}
