import {
  globalCurriculumSentenceSetRef,
  globalCurriculumWordSetRef,
} from "./refs";
import {
  sentenceContentDedupKey,
  wordContentDedupKey,
} from "./content_dedup_keys";

type WordLike = { word?: unknown };
type SentenceLike = { sentence?: unknown };

/** 파싱·테스트용 — 단어 항목에서 dedup 키 수집 */
export function collectWordDedupKeysFromItems(
  items: Iterable<WordLike>
): Set<string> {
  const keys = new Set<string>();
  for (const item of items) {
    const raw = item.word;
    if (typeof raw !== "string") {
      continue;
    }
    const key = wordContentDedupKey(raw);
    if (key) {
      keys.add(key);
    }
  }
  return keys;
}

/** 파싱·테스트용 — 문장 항목에서 dedup 키 수집 */
export function collectSentenceDedupKeysFromItems(
  items: Iterable<SentenceLike>
): Set<string> {
  const keys = new Set<string>();
  for (const item of items) {
    const raw = item.sentence;
    if (typeof raw !== "string") {
      continue;
    }
    const key = sentenceContentDedupKey(raw);
    if (key) {
      keys.add(key);
    }
  }
  return keys;
}

/**
 * 커리큘럼 N일차 생성 전 — 1..N-1일차에 이미 나온 단어 headword 키.
 */
export async function loadPriorCurriculumWordDedupKeys(
  targetLanguage: string,
  level: string,
  phase: number,
  learningDay: number
): Promise<Set<string>> {
  if (learningDay <= 1) {
    return new Set();
  }

  const keys = new Set<string>();
  const snaps = await Promise.all(
    Array.from({ length: learningDay - 1 }, (_, i) =>
      globalCurriculumWordSetRef(
        targetLanguage,
        level,
        phase,
        i + 1
      ).get()
    )
  );

  for (const snap of snaps) {
    const words = snap.data()?.words;
    if (!Array.isArray(words)) {
      continue;
    }
    for (const key of collectWordDedupKeysFromItems(words as WordLike[])) {
      keys.add(key);
    }
  }

  return keys;
}

/**
 * 커리큘럼 N일차 생성 전 — 1..N-1일차에 이미 나온 문장 키.
 */
export async function loadPriorCurriculumSentenceDedupKeys(
  targetLanguage: string,
  level: string,
  phase: number,
  learningDay: number
): Promise<Set<string>> {
  if (learningDay <= 1) {
    return new Set();
  }

  const keys = new Set<string>();
  const snaps = await Promise.all(
    Array.from({ length: learningDay - 1 }, (_, i) =>
      globalCurriculumSentenceSetRef(
        targetLanguage,
        level,
        phase,
        i + 1
      ).get()
    )
  );

  for (const snap of snaps) {
    const sentences = snap.data()?.sentences;
    if (!Array.isArray(sentences)) {
      continue;
    }
    for (const key of collectSentenceDedupKeysFromItems(
      sentences as SentenceLike[]
    )) {
      keys.add(key);
    }
  }

  return keys;
}
