import { CURRICULUM_CORE_V1_TOTAL_DAYS } from "../curriculum/core_v1_rotation";
import {
  globalCurriculumSentenceSetRef,
  globalCurriculumWordSetRef,
} from "./refs";

export type CurriculumPregenPair = {
  targetLanguage: string;
  level: string;
};

export type CurriculumPregenDayResult = {
  targetLanguage: string;
  level: string;
  learningDay: number;
  status: "created" | "skipped" | "failed";
  error?: string;
};

export type CurriculumPregenSummary = {
  phase: number;
  startDay: number;
  endDay: number;
  created: number;
  skipped: number;
  failed: number;
  results: CurriculumPregenDayResult[];
};

type CurriculumWordSetDoc = {
  words?: unknown[];
};

type CurriculumSentenceSetDoc = {
  sentences?: unknown[];
};

/** phase 1 일차(단어+문장) 세트가 이미 채워져 있는지 */
export async function isCurriculumPhase1DayMaterialized(
  targetLanguage: string,
  level: string,
  learningDay: number,
  phase = 1
): Promise<boolean> {
  const wordSnap = await globalCurriculumWordSetRef(
    targetLanguage,
    level,
    phase,
    learningDay
  ).get();
  const wdata = wordSnap.data() as CurriculumWordSetDoc | undefined;
  if (!Array.isArray(wdata?.words) || wdata.words.length === 0) {
    return false;
  }

  const sentenceSnap = await globalCurriculumSentenceSetRef(
    targetLanguage,
    level,
    phase,
    learningDay
  ).get();
  const sdata = sentenceSnap.data() as CurriculumSentenceSetDoc | undefined;
  return Array.isArray(sdata?.sentences) && sdata.sentences.length > 0;
}

/**
 * 1단계(phase 1) 커리큘럼 50일치 선생성(일차 1→50, 조합별).
 * - 이미 있는 일차는 skip
 * - maxDaysToCreate 미지정 시 빈 일차 전부 시도(seed·갭 보충)
 */
export async function pregenerateCurriculumPhase1Days(
  pairs: CurriculumPregenPair[],
  materializeDay: (
    targetLanguage: string,
    level: string,
    learningDay: number
  ) => Promise<void>,
  options?: {
    phase?: number;
    startDay?: number;
    endDay?: number;
    maxDaysToCreate?: number;
    /** 테스트·주입용 — 미지정 시 Firestore 문서 존재 여부로 판단 */
    isReady?: (
      targetLanguage: string,
      level: string,
      learningDay: number,
      phase: number
    ) => Promise<boolean>;
  }
): Promise<CurriculumPregenSummary> {
  const phase = options?.phase ?? 1;
  const isReady =
    options?.isReady ??
    ((targetLanguage, level, learningDay, p) =>
      isCurriculumPhase1DayMaterialized(targetLanguage, level, learningDay, p));
  const startDay = Math.max(1, options?.startDay ?? 1);
  const endDay = Math.min(
    CURRICULUM_CORE_V1_TOTAL_DAYS,
    options?.endDay ?? CURRICULUM_CORE_V1_TOTAL_DAYS
  );
  const maxDaysToCreate = options?.maxDaysToCreate;

  const results: CurriculumPregenDayResult[] = [];
  let created = 0;
  let skipped = 0;
  let failed = 0;

  for (let learningDay = startDay; learningDay <= endDay; learningDay += 1) {
    for (const { targetLanguage, level } of pairs) {
      try {
        const ready = await isReady(targetLanguage, level, learningDay, phase);
        if (ready) {
          skipped += 1;
          results.push({
            targetLanguage,
            level,
            learningDay,
            status: "skipped",
          });
          continue;
        }

        if (maxDaysToCreate != null && created >= maxDaysToCreate) {
          return {
            phase,
            startDay,
            endDay,
            created,
            skipped,
            failed,
            results,
          };
        }

        await materializeDay(targetLanguage, level, learningDay);
        created += 1;
        results.push({
          targetLanguage,
          level,
          learningDay,
          status: "created",
        });
      } catch (e) {
        failed += 1;
        const msg = e instanceof Error ? e.message : String(e);
        results.push({
          targetLanguage,
          level,
          learningDay,
          status: "failed",
          error: msg,
        });
      }
    }
  }

  return {
    phase,
    startDay,
    endDay,
    created,
    skipped,
    failed,
    results,
  };
}

/**
 * 스케줄러용 — (언어×난이도) 조합마다 1~50일 중 **가장 앞의 빈 일차 1개**만 생성.
 * 레거시 23:55 선생성과 같이 하루 한 번, 조합당 다음 일차만 채운다.
 */
export async function pregenerateNextMissingCurriculumDayPerPair(
  pairs: CurriculumPregenPair[],
  materializeDay: (
    targetLanguage: string,
    level: string,
    learningDay: number
  ) => Promise<void>,
  options?: {
    phase?: number;
    isReady?: (
      targetLanguage: string,
      level: string,
      learningDay: number,
      phase: number
    ) => Promise<boolean>;
  }
): Promise<CurriculumPregenSummary> {
  const phase = options?.phase ?? 1;
  const isReady =
    options?.isReady ??
    ((targetLanguage, level, learningDay, p) =>
      isCurriculumPhase1DayMaterialized(targetLanguage, level, learningDay, p));

  const results: CurriculumPregenDayResult[] = [];
  let created = 0;
  let skipped = 0;
  let failed = 0;

  for (const { targetLanguage, level } of pairs) {
    let pairHandled = false;
    for (let learningDay = 1; learningDay <= CURRICULUM_CORE_V1_TOTAL_DAYS; learningDay += 1) {
      try {
        const ready = await isReady(targetLanguage, level, learningDay, phase);
        if (!ready) {
          await materializeDay(targetLanguage, level, learningDay);
          created += 1;
          results.push({
            targetLanguage,
            level,
            learningDay,
            status: "created",
          });
          pairHandled = true;
          break;
        }
        skipped += 1;
        results.push({
          targetLanguage,
          level,
          learningDay,
          status: "skipped",
        });
      } catch (e) {
        failed += 1;
        const msg = e instanceof Error ? e.message : String(e);
        results.push({
          targetLanguage,
          level,
          learningDay,
          status: "failed",
          error: msg,
        });
        pairHandled = true;
        break;
      }
    }
    if (!pairHandled) {
      // 1~50 모두 준비됨 — 추가 생성 없음
    }
  }

  return {
    phase,
    startDay: 1,
    endDay: CURRICULUM_CORE_V1_TOTAL_DAYS,
    created,
    skipped,
    failed,
    results,
  };
}
