/**
 * 사용자 커리큘럼 학습 상태 — `users/{uid}` 필드 정본.
 * 캘린더(KST dateKst)와 분리된 learningDay / phase 기준.
 *
 * learningDay 진행 규칙(D-1):
 * - 당일 단어·문장·마무리(15/5/13) 전부 완료 시 learningDay +1 (앱 트랜잭션).
 * - 미완료 시 KST 날짜가 바뀌어도 learningDay 유지 (daily_progress만 당일 0부터).
 * - 1..50 clamp, daily_progress.curriculumDayAdvanced 로 중복 +1 방지.
 */

import {
  CURRICULUM_CORE_V1_ID,
  CURRICULUM_CORE_V1_TOTAL_DAYS,
} from "./core_v1_rotation";

export type CurriculumPhase = 1 | 2;

export type LearningMode = "curriculum" | "review" | "free_study";

export type CycleReviewStatus =
  | "none"
  | "available"
  | "in_progress"
  | "completed"
  | "skipped";

export type CurriculumState = {
  curriculumId: string;
  curriculumPhase: CurriculumPhase;
  learningDay: number;
  learningMode: LearningMode;
  cycleReviewStatus: CycleReviewStatus;
};

export const CURRICULUM_PHASE_MIN = 1 as const;
export const CURRICULUM_PHASE_MAX = 2 as const;

export const LEARNING_LEVELS = ["beginner", "intermediate", "advanced"] as const;
export type LearningLevel = (typeof LEARNING_LEVELS)[number];

/** 앱 `kLearningDifficultyUiEnabled`와 동기 — false면 초급만 사용·선생성 */
export const LEARNING_DIFFICULTY_UI_ENABLED = false;

export const FORCED_LEARNING_LEVEL: LearningLevel = "beginner";

export function effectiveLearningLevel(raw: unknown): LearningLevel {
  if (!LEARNING_DIFFICULTY_UI_ENABLED) {
    return FORCED_LEARNING_LEVEL;
  }
  return normalizeLearningLevel(raw);
}

export const DEFAULT_CURRICULUM_STATE: CurriculumState = {
  curriculumId: CURRICULUM_CORE_V1_ID,
  curriculumPhase: 1,
  learningDay: 1,
  learningMode: "curriculum",
  cycleReviewStatus: "none",
};

const LEARNING_MODES: readonly LearningMode[] = ["curriculum", "review", "free_study"];
const CYCLE_REVIEW_STATUSES: readonly CycleReviewStatus[] = [
  "none",
  "available",
  "in_progress",
  "completed",
  "skipped",
];

/** learningDay를 1..TOTAL 범위로 보정 */
export function clampLearningDay(raw: number): number {
  if (!Number.isFinite(raw)) return 1;
  const day = Math.floor(raw);
  if (day < 1) return 1;
  if (day > CURRICULUM_CORE_V1_TOTAL_DAYS) return CURRICULUM_CORE_V1_TOTAL_DAYS;
  return day;
}

export function normalizeLearningLevel(raw: unknown, fallback: LearningLevel = "beginner"): LearningLevel {
  const v = String(raw ?? "").trim().toLowerCase();
  if ((LEARNING_LEVELS as readonly string[]).includes(v)) {
    return v as LearningLevel;
  }
  return fallback;
}

export function parseCurriculumPhase(raw: unknown): CurriculumPhase | undefined {
  const n = typeof raw === "number" ? raw : Number.parseInt(String(raw ?? ""), 10);
  if (n === 1 || n === 2) return n;
  return undefined;
}

export function parseLearningMode(raw: unknown): LearningMode | undefined {
  const v = String(raw ?? "").trim().toLowerCase();
  if ((LEARNING_MODES as readonly string[]).includes(v)) {
    return v as LearningMode;
  }
  return undefined;
}

export function parseCycleReviewStatus(raw: unknown): CycleReviewStatus | undefined {
  const v = String(raw ?? "").trim().toLowerCase();
  if ((CYCLE_REVIEW_STATUSES as readonly string[]).includes(v)) {
    return v as CycleReviewStatus;
  }
  return undefined;
}

/** Firestore users/{uid} 문서에서 커리큘럼 상태 읽기(누락·잘못된 값은 기본값 보정) */
export function curriculumStateFromUserData(
  data: Record<string, unknown> | undefined
): CurriculumState {
  const d = data ?? {};
  const curriculumIdRaw = String(d.curriculumId ?? "").trim();
  const curriculumId =
    curriculumIdRaw.length > 0 ? curriculumIdRaw : DEFAULT_CURRICULUM_STATE.curriculumId;

  return {
    curriculumId,
    curriculumPhase: parseCurriculumPhase(d.curriculumPhase) ?? DEFAULT_CURRICULUM_STATE.curriculumPhase,
    learningDay: clampLearningDay(Number(d.learningDay ?? DEFAULT_CURRICULUM_STATE.learningDay)),
    learningMode: parseLearningMode(d.learningMode) ?? DEFAULT_CURRICULUM_STATE.learningMode,
    cycleReviewStatus:
      parseCycleReviewStatus(d.cycleReviewStatus) ?? DEFAULT_CURRICULUM_STATE.cycleReviewStatus,
  };
}

/**
 * 기존 유저 백필용 — 키가 없을 때만 기본값 채움(이미 저장된 진행은 덮어쓰지 않음).
 */
export function curriculumStateBackfillPatch(
  existing: Record<string, unknown> | undefined
): Record<string, unknown> {
  const d = existing ?? {};
  const patch: Record<string, unknown> = {};

  if (d.curriculumId == null || String(d.curriculumId).trim() === "") {
    patch.curriculumId = DEFAULT_CURRICULUM_STATE.curriculumId;
  }
  if (parseCurriculumPhase(d.curriculumPhase) === undefined) {
    patch.curriculumPhase = DEFAULT_CURRICULUM_STATE.curriculumPhase;
  }
  if (d.learningDay == null || !Number.isFinite(Number(d.learningDay))) {
    patch.learningDay = DEFAULT_CURRICULUM_STATE.learningDay;
  } else {
    const clamped = clampLearningDay(Number(d.learningDay));
    if (clamped !== Number(d.learningDay)) {
      patch.learningDay = clamped;
    }
  }
  if (parseLearningMode(d.learningMode) === undefined) {
    patch.learningMode = DEFAULT_CURRICULUM_STATE.learningMode;
  }
  if (parseCycleReviewStatus(d.cycleReviewStatus) === undefined) {
    patch.cycleReviewStatus = DEFAULT_CURRICULUM_STATE.cycleReviewStatus;
  }
  if (d.level == null || String(d.level).trim() === "") {
    patch.level = "beginner";
  }

  return patch;
}

/** Firestore merge 저장용 평면 객체 */
export function curriculumStateToFirestore(state: CurriculumState): Record<string, unknown> {
  return {
    curriculumId: state.curriculumId,
    curriculumPhase: state.curriculumPhase,
    learningDay: clampLearningDay(state.learningDay),
    learningMode: state.learningMode,
    cycleReviewStatus: state.cycleReviewStatus,
  };
}
