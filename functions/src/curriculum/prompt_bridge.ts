import { curriculumContextForPrompt, formatCurriculumDayForPrompt } from "./core_v1_rotation";
import type { CurriculumPromptContext } from "../prompts";

/** learningDay → Firestore 커리큘럼 세트에 저장할 한글 주제명 */
export function curriculumTopicLabelsKoForDay(learningDay: number): string[] {
  const ctx = curriculumContextForPrompt(learningDay);
  return ctx ? [...ctx.topicLabelsKo] : [];
}

/** learningDay → OpenAI 프롬프트용 커리큘럼 컨텍스트 */
export function curriculumPromptContextForDay(
  learningDay: number,
  curriculumPhase: number
): CurriculumPromptContext | undefined {
  const ctx = curriculumContextForPrompt(learningDay);
  if (!ctx) return undefined;
  return {
    curriculumId: ctx.curriculumId,
    learningDay: ctx.learningDay,
    totalDays: ctx.totalDays,
    curriculumPhase,
    category: ctx.category,
    topicIds: ctx.topicIds,
    topicLabelsKo: ctx.topicLabelsKo,
    promptScopeEn: ctx.promptScopeEn,
    scopeLine: formatCurriculumDayForPrompt(learningDay),
  };
}
