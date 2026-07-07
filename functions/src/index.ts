export { seedCountryCatalog, syncCountryFlags } from "./metadata/callables";
export { scheduledSyncCountryFlags } from "./metadata/schedules";
export { getWrapUpDeck } from "./wrap_up/callables";
export { cleanupLegacyFirestoreDocs } from "./maintenance/cleanup";
export { setAdminCurriculumPreviewDay } from "./admin/curriculum_admin_callables";

import {
  buildDailySentenceBatchSystemPrompt,
  buildDailySentenceBatchUserPromptJson,
  buildDailyWordBatchSystemPrompt,
  buildDailyWordBatchUserPromptJson,
  buildSentenceSystemPrompt,
  buildSentenceUserPromptJson,
  buildWordSystemPrompt,
  buildWordUserPromptJson,
  type CurriculumPromptContext,
} from "./prompts";
import {
  curriculumPromptContextForDay,
  curriculumTopicLabelsKoForDay,
} from "./curriculum/prompt_bridge";
import {
  CURRICULUM_CORE_V1_ID,
  getCurriculumDaySpec,
} from "./curriculum/core_v1_rotation";
import { onCall, HttpsError } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";
import { curriculumSetDocId } from "./learning_sets/curriculum_set_keys";
import {
  globalCurriculumSentenceSetRef,
  globalCurriculumWordSetRef,
  globalTodaySentenceSetRef,
  globalTodayWordSetRef,
} from "./learning_sets/refs";
import {
  isCurriculumPhase1DayMaterialized,
  pregenerateCurriculumPhase1Days,
  type CurriculumPregenPair,
} from "./learning_sets/curriculum_pregen";
import {
  loadPriorCurriculumSentenceDedupKeys,
  loadPriorCurriculumWordDedupKeys,
} from "./learning_sets/curriculum_blocked_content";
import {
  blockedListForPrompt,
  sentenceContentDedupKey,
  wordContentDedupKey,
} from "./learning_sets/content_dedup_keys";
import {
  isCurriculumSetLevel,
  loadUserLearningProfile,
  type UserLearningProfile,
} from "./learning_sets/user_learning_profile";
import {
  curriculumStateFromUserData,
  clampLearningDay,
  effectiveLearningLevel,
  LEARNING_DIFFICULTY_UI_ENABLED,
  parseCurriculumPhase,
} from "./curriculum/curriculum_state";
import { applyWordSentenceStudyDayToProfile } from "./curriculum/curriculum_study_day";
import { assertAdminToolsUid } from "./admin/admin_tools_auth";
import {
  enrichSentenceItemsWithAudio,
  enrichWordItemsWithAudio,
  sentenceItemNeedsAudio,
  wordItemNeedsAudio,
} from "./learning_audio/enrich";

type GenerateWordResponse = {
  word: string;
  /** 일본어용: 히라가나만(확인용) */
  readingHira?: string;
  meaningKo: string;
  example?: string;
  /** 예문(example)의 한국어 해석·뜻 */
  exampleMeaningKo?: string;
  /** Cloud Storage 경로 — 단어 음성 */
  wordAudioPath?: string;
  /** Cloud Storage 경로 — 예문 음성 */
  exampleAudioPath?: string;
  debugSource?: "openai" | "fallback" | "daily_set" | "curriculum_set";
};

type SentenceVocabHint = {
  /** 문장에 실제로 등장하는 표기 */
  word: string;
  /** 한국어 짧은 뜻 */
  meaningKo: string;
};

type GenerateSentenceResponse = {
  sentence: string;
  /** 일본어용: 히라가나만(확인용) */
  sentenceHira?: string;
  meaningKo: string;
  /** 문장에 나온 표현·단어와 한국어 뜻 (생성 시점에 선별) */
  vocabularyHints?: SentenceVocabHint[];
  /** Cloud Storage 경로 — 문장 음성 */
  sentenceAudioPath?: string;
  debugSource?: "openai" | "fallback" | "daily_set" | "curriculum_set";
};

type StoredWordItem = {
  word: string;
  readingHira?: string;
  meaningKo: string;
  example?: string;
  exampleMeaningKo?: string;
  wordAudioPath?: string;
  exampleAudioPath?: string;
};

type DailyWordSet = {
  dateKst: string;
  targetLanguage: string;
  level: string;
  words: StoredWordItem[];
  cursor: number;
  updatedAtMs: number;
};

type StoredSentenceItem = {
  sentence: string;
  sentenceHira?: string;
  meaningKo: string;
  vocabularyHints?: SentenceVocabHint[];
  sentenceAudioPath?: string;
};

type DailySentenceSet = {
  dateKst: string;
  targetLanguage: string;
  level: string;
  sentences: StoredSentenceItem[];
  cursor: number;
  updatedAtMs: number;
};

type CurriculumWordSet = {
  curriculumId: string;
  targetLanguage: string;
  level: string;
  curriculumPhase: number;
  learningDay: number;
  topicIds: string[];
  topicLabelsKo: string[];
  words: StoredWordItem[];
  updatedAtMs: number;
};

type CurriculumSentenceSet = {
  curriculumId: string;
  targetLanguage: string;
  level: string;
  curriculumPhase: number;
  learningDay: number;
  topicIds: string[];
  topicLabelsKo: string[];
  sentences: StoredSentenceItem[];
  updatedAtMs: number;
};


const OPENAI_API_URL = "https://api.openai.com/v1/responses";
const OPENAI_MODEL = process.env.OPENAI_MODEL ?? "gpt-4.1-mini";
/** 오늘의 단어 화면 일일 목표와 동일하게 유지 */
const DAILY_WORD_COUNT = 15;
/** 오늘의 문장 화면 일일 목표와 동일하게 유지 */
const DAILY_SENTENCE_COUNT = 5;
/** 문장별 vocabularyHints 최대 개수 (과다 저장·응답 크기 방지) */
const MAX_SENTENCE_VOCAB_HINTS = 6;
/** 단어 배치 한 번에 요청할 개수 (두 배치 병렬 호출 → 문장 1회와 비슷한 체감에 가깝게) */
const DAILY_WORD_BATCH_SIZE = 15;
const DEFAULT_RETENTION_DAYS = 7;
/** 일일 단어·문장 세트 공유 소유자 (모든 유저가 동일 15/5 풀 사용, 커서만 사용자별). */
const GLOBAL_LEARNING_SET_OWNER = "global_learning_set_owner";

/** 1단계(phase 1) 커리큘럼 50일치 선생성 — 초·중 전체(난이도 UI on 시) */
const PREGEN_CURRICULUM_PAIRS_ALL: CurriculumPregenPair[] = [
  { targetLanguage: "KOR", level: "beginner" },
  { targetLanguage: "KOR", level: "intermediate" },
  { targetLanguage: "USA", level: "beginner" },
  { targetLanguage: "USA", level: "intermediate" },
  { targetLanguage: "JPN", level: "beginner" },
  { targetLanguage: "JPN", level: "intermediate" },
];

/** 난이도 UI off 시 선생성·시드 대상 (초급만) */
const PREGEN_CURRICULUM_PAIRS_BEGINNER_ONLY: CurriculumPregenPair[] = [
  { targetLanguage: "KOR", level: "beginner" },
  { targetLanguage: "USA", level: "beginner" },
  { targetLanguage: "JPN", level: "beginner" },
];

function activePregenCurriculumPairs(): CurriculumPregenPair[] {
  return LEARNING_DIFFICULTY_UI_ENABLED
    ? PREGEN_CURRICULUM_PAIRS_ALL
    : PREGEN_CURRICULUM_PAIRS_BEGINNER_ONLY;
}
const PREGEN_CURRICULUM_PHASE = 1;
admin.initializeApp();
const db = admin.firestore();

function todayKstYyyyMmDd(now = new Date()): string {
  const kst = new Date(now.getTime() + 9 * 60 * 60 * 1000);
  const y = kst.getUTCFullYear().toString().padStart(4, "0");
  const m = (kst.getUTCMonth() + 1).toString().padStart(2, "0");
  const d = kst.getUTCDate().toString().padStart(2, "0");
  return `${y}-${m}-${d}`;
}

function learningSetDocId(todayKst: string, targetLanguage: string, level: string): string {
  return `${todayKst}_${targetLanguage}_${level}`;
}

function normalizeTargetLanguage(code: string): { external: string; internal: string } {
  const raw = (code ?? "").trim();
  const upper = raw.toUpperCase();
  // external (ISO-3166-1 alpha-3)
  if (upper === "JPN") return { external: "JPN", internal: "ja" };
  if (upper === "ESP") return { external: "ESP", internal: "es" };
  if (upper === "USA") return { external: "USA", internal: "en" };
  if (upper === "FRA") return { external: "FRA", internal: "fr" };
  if (upper === "DEU") return { external: "DEU", internal: "de" };
  if (upper === "CHN") return { external: "CHN", internal: "zh" };
  if (upper === "KOR") return { external: "KOR", internal: "ko" };
  const lower = raw.toLowerCase();
  if (lower === "ja") return { external: "JPN", internal: "ja" };
  if (lower === "es") return { external: "ESP", internal: "es" };
  if (lower === "en") return { external: "USA", internal: "en" };
  if (lower === "fr") return { external: "FRA", internal: "fr" };
  if (lower === "de") return { external: "DEU", internal: "de" };
  if (lower === "zh") return { external: "CHN", internal: "zh" };
  if (lower === "ko") return { external: "KOR", internal: "ko" };
  return { external: upper.length === 3 ? upper : raw, internal: lower };
}

/** Callable 요청 + users/{uid} 프로필 병합 */
async function resolveUserLearningProfile(
  uid: string,
  requestData: Record<string, unknown> | undefined
): Promise<UserLearningProfile> {
  const userSnap = await db.collection("users").doc(uid).get();
  const userData = (userSnap.data() ?? {}) as Record<string, unknown>;
  const loaded = await loadUserLearningProfile(db, uid, normalizeTargetLanguage);
  const tl = normalizeTargetLanguage(
    (requestData?.targetLanguage ?? loaded.targetLanguage) as string
  );
  const level = effectiveLearningLevel(requestData?.level ?? loaded.level);
  const state = curriculumStateFromUserData(userData, { targetLanguage: tl.external });
  const profile: UserLearningProfile = {
    targetLanguage: tl.external,
    level,
    curriculumPhase: state.curriculumPhase,
    learningDay: state.learningDay,
  };
  return applyWordSentenceStudyDayToProfile(uid, userData, profile);
}

async function ensureGlobalLearningOwnerDoc(nowMs = Date.now()): Promise<void> {
  const ownerRef = db.collection("users").doc(GLOBAL_LEARNING_SET_OWNER);
  await ownerRef.set(
    {
      kind: "global_learning_set_owner",
      updatedAtMs: nowMs,
    },
    { merge: true }
  );
}

function addDaysYyyyMmDd(baseYmd: string, days: number): string {
  const [y, m, d] = baseYmd.split("-").map((v) => Number(v));
  const base = new Date(Date.UTC(y, m - 1, d));
  base.setUTCDate(base.getUTCDate() + days);
  const yy = base.getUTCFullYear().toString().padStart(4, "0");
  const mm = (base.getUTCMonth() + 1).toString().padStart(2, "0");
  const dd = base.getUTCDate().toString().padStart(2, "0");
  return `${yy}-${mm}-${dd}`;
}

function shuffle<T>(arr: T[]): T[] {
  const out = [...arr];
  for (let i = out.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}

async function cleanupExpiredLearningSets(uid: string, todayKst: string): Promise<void> {
  const deleteBefore = addDaysYyyyMmDd(todayKst, -(DEFAULT_RETENTION_DAYS + 1));
  for (const sub of ["daily_word_sets", "daily_sentence_sets"] as const) {
    const col = db.collection("users").doc(uid).collection(sub);
    const snap = await col.where("dateKst", "<=", deleteBefore).limit(20).get();
    if (snap.empty) continue;
    const batch = db.batch();
    for (const doc of snap.docs) {
      batch.delete(doc.ref);
    }
    await batch.commit();
  }
}

function fallbackWord(targetLanguage: string, level: string): GenerateWordResponse {
  const lang = normalizeTargetLanguage(targetLanguage).internal;
  if (lang === "ja" && level === "beginner") {
    return {
      word: "ありがとう",
      meaningKo: "고마워요",
      example: "ありがとう、助かりました。",
      exampleMeaningKo: "고마워요, 덕분에 살았어요.",
    };
  }
  return {
    word: "hola",
    meaningKo: "안녕",
    example: "Hola, ¿cómo estás?",
    exampleMeaningKo: "안녕, 잘 지내?",
  };
}

function fallbackSentence(targetLanguage: string, level: string): GenerateSentenceResponse {
  const lang = normalizeTargetLanguage(targetLanguage).internal;
  if (lang === "ja" && level === "beginner") {
    return {
      sentence: "きょうはいいてんきですね。",
      meaningKo: "오늘은 날씨가 좋네요.",
      vocabularyHints: [
        { word: "きょう", meaningKo: "오늘" },
        { word: "いい", meaningKo: "좋다" },
        { word: "てんき", meaningKo: "날씨" },
      ],
    };
  }
  return {
    sentence: "Hoy hace buen tiempo.",
    meaningKo: "오늘 날씨가 좋아요.",
    vocabularyHints: [
      { word: "Hoy", meaningKo: "오늘" },
      { word: "buen", meaningKo: "좋은" },
      { word: "tiempo", meaningKo: "날씨" },
    ],
  };
}

function safeJsonParse(value: string): unknown | null {
  try {
    return JSON.parse(value);
  } catch {
    // ignore
  }

  // 모델이 앞뒤 설명을 섞어 보내는 경우를 대비해서
  // 첫 '{' ~ 마지막 '}' 범위만 다시 파싱해본다.
  const firstBrace = value.indexOf("{");
  const lastBrace = value.lastIndexOf("}");
  if (firstBrace >= 0 && lastBrace > firstBrace) {
    const candidate = value.slice(firstBrace, lastBrace + 1);
    try {
      return JSON.parse(candidate);
    } catch {
      return null;
    }
  }

  return null;
}

function readOptionalString(obj: unknown, keys: string[]): string | undefined {
  if (typeof obj !== "object" || obj === null) return undefined;
  const o = obj as Record<string, unknown>;
  for (const k of keys) {
    const v = o[k];
    if (typeof v === "string") {
      const t = v.trim();
      if (t.length > 0) return t;
    }
  }
  return undefined;
}


function parseSentenceVocabularyHints(container: unknown): SentenceVocabHint[] | undefined {
  if (typeof container !== "object" || container === null) {
    return undefined;
  }
  const o = container as Record<string, unknown>;
  const raw = o.vocabularyHints ?? o.vocabulary_hints;
  if (!Array.isArray(raw)) {
    return undefined;
  }
  const out: SentenceVocabHint[] = [];
  for (const el of raw) {
    if (typeof el !== "object" || el === null) {
      continue;
    }
    const word = readOptionalString(el, ["word", "expression", "target", "fragment"]) ?? "";
    const meaningKo =
      readOptionalString(el, ["meaningKo", "glossKo", "koMeaning", "koreanMeaning", "meaning"]) ??
      "";
    if (!word || !meaningKo) {
      continue;
    }
    out.push({ word, meaningKo });
    if (out.length >= MAX_SENTENCE_VOCAB_HINTS) {
      break;
    }
  }
  return out.length > 0 ? out : undefined;
}


/**
 * OpenAI Responses API (`POST /v1/responses`) 응답에서 모델 텍스트를 꺼낸다.
 * - 일부 SDK/문서는 top-level `output_text`를 가정하지만, 실제 JSON은 `output[].content[].text`만 주는 경우가 많다.
 */
function extractOutputTextFromOpenAIResponses(data: unknown): string {
  if (typeof data !== "object" || data === null) return "";
  const root = data as Record<string, unknown>;

  const top = root.output_text;
  if (typeof top === "string" && top.trim().length > 0) {
    return top.trim();
  }

  const output = root.output;
  if (!Array.isArray(output)) return "";

  const parts: string[] = [];
  for (const item of output) {
    if (typeof item !== "object" || item === null) continue;
    const o = item as Record<string, unknown>;
    const content = o.content;
    if (!Array.isArray(content)) continue;
    for (const block of content) {
      if (typeof block !== "object" || block === null) continue;
      const b = block as Record<string, unknown>;
      const textVal = b.text;
      if (typeof textVal !== "string" || textVal.trim().length === 0) continue;
      const typ = b.type;
      if (typ === "output_text" || typ === "text") {
        parts.push(textVal.trim());
      }
    }
  }

  return parts.join("\n").trim();
}

async function generateWordWithOpenAI(
  targetLanguage: string,
  level: string
): Promise<GenerateWordResponse> {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is missing");
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 12000);

  try {
    const systemPrompt = buildWordSystemPrompt(targetLanguage, level);
    const userPrompt = buildWordUserPromptJson(
      targetLanguage,
      level,
      `${Date.now()}-${Math.random().toString(36).slice(2)}`
    );

    const response = await fetch(OPENAI_API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: OPENAI_MODEL,
        temperature: 1.1,
        input: [
          { role: "system", content: [{ type: "input_text", text: systemPrompt }] },
          { role: "user", content: [{ type: "input_text", text: userPrompt }] },
        ],
      }),
      signal: controller.signal,
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`OpenAI HTTP ${response.status}: ${text}`);
    }

    const data: unknown = await response.json();
    const outputText = extractOutputTextFromOpenAIResponses(data);
    if (!outputText) {
      throw new Error("OpenAI response had no assistant text (output_text/output)");
    }

    const parsed = safeJsonParse(outputText);
    const word = readOptionalString(parsed, ["word"]);
    const readingHira =
      readOptionalString(parsed, ["readingHira"]) ??
      readOptionalString(parsed, ["wordHira", "wordKana", "readingKana", "reading"]);
    const meaningKo =
      readOptionalString(parsed, ["meaningKo"]) ??
      readOptionalString(parsed, ["meaning", "koMeaning", "koreanMeaning"]);
    const ex = readOptionalString(parsed, ["example", "exampleSentence"]);
    const exMean = readOptionalString(parsed, [
      "exampleMeaningKo",
      "exampleMeaning",
      "exampleKoMeaning",
    ]);

    if (!word || !meaningKo) {
      throw new Error("OpenAI response JSON schema mismatch (word)");
    }
    return {
      word,
      ...(readingHira && readingHira.length > 0 ? { readingHira } : {}),
      meaningKo,
      example: ex && ex.length > 0 ? ex : undefined,
      exampleMeaningKo: exMean && exMean.length > 0 ? exMean : undefined,
    };
  } finally {
    clearTimeout(timeout);
  }
}

async function generateSentenceWithOpenAI(
  targetLanguage: string,
  level: string
): Promise<GenerateSentenceResponse> {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is missing");
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 12000);

  try {
    const systemPrompt = buildSentenceSystemPrompt(targetLanguage, level);
    const userPrompt = buildSentenceUserPromptJson(
      targetLanguage,
      level,
      `${Date.now()}-${Math.random().toString(36).slice(2)}`
    );

    const response = await fetch(OPENAI_API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: OPENAI_MODEL,
        temperature: 1.1,
        input: [
          { role: "system", content: [{ type: "input_text", text: systemPrompt }] },
          { role: "user", content: [{ type: "input_text", text: userPrompt }] },
        ],
      }),
      signal: controller.signal,
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`OpenAI HTTP ${response.status}: ${text}`);
    }

    const data: unknown = await response.json();
    const outputText = extractOutputTextFromOpenAIResponses(data);
    if (!outputText) {
      throw new Error("OpenAI response had no assistant text (output_text/output)");
    }

    const parsed = safeJsonParse(outputText);
    const sentence = readOptionalString(parsed, ["sentence"]);
    const sentenceHira =
      readOptionalString(parsed, ["sentenceHira"]) ??
      readOptionalString(parsed, ["readingHira", "sentenceKana", "readingKana", "reading"]);
    const meaningKo =
      readOptionalString(parsed, ["meaningKo"]) ??
      readOptionalString(parsed, ["meaning", "koMeaning", "koreanMeaning"]);

    if (!sentence || !meaningKo) {
      throw new Error("OpenAI response JSON schema mismatch (sentence)");
    }
    const vocabularyHints = parseSentenceVocabularyHints(parsed);
    return {
      sentence,
      ...(sentenceHira && sentenceHira.length > 0 ? { sentenceHira } : {}),
      meaningKo,
      ...(vocabularyHints ? { vocabularyHints } : {}),
    };
  } finally {
    clearTimeout(timeout);
  }
}

function parseWordItem(value: unknown): StoredWordItem | null {
  if (typeof value !== "object" || value === null) return null;
  const word = readOptionalString(value, ["word"]);
  const readingHira =
    readOptionalString(value, ["readingHira"]) ??
    readOptionalString(value, ["wordHira", "wordKana", "readingKana", "reading"]);
  const meaningKo =
    readOptionalString(value, ["meaningKo"]) ??
    readOptionalString(value, ["meaning", "koMeaning", "koreanMeaning"]);
  if (!word || !meaningKo) return null;
  const example = readOptionalString(value, ["example", "exampleSentence"]);
  const exampleMeaningKo = readOptionalString(value, [
    "exampleMeaningKo",
    "exampleMeaning",
    "exampleKoMeaning",
  ]);
  return {
    word,
    ...(readingHira && readingHira.length > 0 ? { readingHira } : {}),
    meaningKo,
    ...(example ? { example } : {}),
    ...(exampleMeaningKo ? { exampleMeaningKo } : {}),
  };
}

function parseSentenceItem(value: unknown): StoredSentenceItem | null {
  if (typeof value !== "object" || value === null) return null;
  const sentence = readOptionalString(value, ["sentence"]);
  const sentenceHira =
    readOptionalString(value, ["sentenceHira"]) ??
    readOptionalString(value, ["readingHira", "sentenceKana", "readingKana", "reading"]);
  const meaningKo =
    readOptionalString(value, ["meaningKo"]) ??
    readOptionalString(value, ["meaning", "koMeaning", "koreanMeaning"]);
  if (!sentence || !meaningKo) return null;
  const vocabularyHints = parseSentenceVocabularyHints(value);
  return {
    sentence,
    ...(sentenceHira && sentenceHira.length > 0 ? { sentenceHira } : {}),
    meaningKo,
    ...(vocabularyHints ? { vocabularyHints } : {}),
  };
}

function wordDedupKey(word: string): string {
  return wordContentDedupKey(word);
}

function sentenceDedupKey(sentence: string): string {
  return sentenceContentDedupKey(sentence);
}

async function generateDailyWordChunkWithOpenAI(
  targetLanguage: string,
  level: string,
  count: number,
  diversitySeed: string,
  curriculum?: CurriculumPromptContext,
  blockedHeadwords?: string[]
): Promise<StoredWordItem[]> {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is missing");
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 25000);

  try {
    const systemPrompt = buildDailyWordBatchSystemPrompt(
      targetLanguage,
      level,
      count,
      curriculum,
      Boolean(blockedHeadwords && blockedHeadwords.length > 0)
    );
    const userPrompt = buildDailyWordBatchUserPromptJson(
      targetLanguage,
      level,
      count,
      diversitySeed,
      curriculum,
      blockedHeadwords
    );

    const response = await fetch(OPENAI_API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: OPENAI_MODEL,
        temperature: 1.05,
        input: [
          { role: "system", content: [{ type: "input_text", text: systemPrompt }] },
          { role: "user", content: [{ type: "input_text", text: userPrompt }] },
        ],
      }),
      signal: controller.signal,
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`OpenAI HTTP ${response.status}: ${text}`);
    }

    const data: unknown = await response.json();
    const outputText = extractOutputTextFromOpenAIResponses(data);
    if (!outputText) {
      throw new Error("OpenAI response had no assistant text (output_text/output)");
    }

    const parsed = safeJsonParse(outputText);
    if (typeof parsed !== "object" || parsed === null) {
      throw new Error("word batch JSON root invalid");
    }
    const rawWords = (parsed as Record<string, unknown>).words;
    if (!Array.isArray(rawWords)) {
      throw new Error("word batch missing words[]");
    }
    const out: StoredWordItem[] = [];
    for (const item of rawWords) {
      const w = parseWordItem(item);
      if (w) {
        out.push(w);
      }
    }
    if (out.length < count) {
      throw new Error(`word batch too short: ${out.length}/${count}`);
    }
    return out.slice(0, count);
  } finally {
    clearTimeout(timeout);
  }
}

async function generateDailySentenceBatchWithOpenAI(
  targetLanguage: string,
  level: string,
  count: number,
  diversitySeed: string,
  requiredVocabulary?: string[],
  curriculum?: CurriculumPromptContext,
  blockedSentences?: string[]
): Promise<StoredSentenceItem[]> {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is missing");
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 25000);

  try {
    const systemPrompt = buildDailySentenceBatchSystemPrompt(
      targetLanguage,
      level,
      count,
      requiredVocabulary,
      curriculum,
      Boolean(blockedSentences && blockedSentences.length > 0)
    );
    const userPrompt = buildDailySentenceBatchUserPromptJson(
      targetLanguage,
      level,
      count,
      diversitySeed,
      requiredVocabulary,
      curriculum,
      blockedSentences
    );

    const response = await fetch(OPENAI_API_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${apiKey}`,
      },
      body: JSON.stringify({
        model: OPENAI_MODEL,
        temperature: 1.05,
        input: [
          { role: "system", content: [{ type: "input_text", text: systemPrompt }] },
          { role: "user", content: [{ type: "input_text", text: userPrompt }] },
        ],
      }),
      signal: controller.signal,
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`OpenAI HTTP ${response.status}: ${text}`);
    }

    const data: unknown = await response.json();
    const outputText = extractOutputTextFromOpenAIResponses(data);
    if (!outputText) {
      throw new Error("OpenAI response had no assistant text (output_text/output)");
    }

    const parsed = safeJsonParse(outputText);
    if (typeof parsed !== "object" || parsed === null) {
      throw new Error("sentence batch JSON root invalid");
    }
    const raw = (parsed as Record<string, unknown>).sentences;
    if (!Array.isArray(raw)) {
      throw new Error("sentence batch missing sentences[]");
    }
    const out: StoredSentenceItem[] = [];
    for (const item of raw) {
      const s = parseSentenceItem(item);
      if (s) {
        out.push(s);
      }
    }
    if (out.length < count) {
      throw new Error(`sentence batch too short: ${out.length}/${count}`);
    }
    return out.slice(0, count);
  } finally {
    clearTimeout(timeout);
  }
}

function mergeWordBatchInto(
  batch: StoredWordItem[],
  out: StoredWordItem[],
  used: Set<string>
): void {
  for (const item of batch) {
    const key = wordDedupKey(item.word);
    if (!key || used.has(key)) {
      continue;
    }
    used.add(key);
    out.push(item);
  }
}

async function buildDailyWordItems(
  targetLanguage: string,
  level: string,
  curriculum?: CurriculumPromptContext,
  blockedKeys?: Set<string>
): Promise<StoredWordItem[]> {
  const internalLang = normalizeTargetLanguage(targetLanguage).internal;
  const out: StoredWordItem[] = [];
  const used = new Set<string>(blockedKeys ?? []);
  const blockedForPrompt = blockedListForPrompt(used);
  const t0 = Date.now();

  // 15개 목표: 배치 1회(+필요 시 top-up)로 생성.
  const parallelSeeds = [
    `words-p0-${t0}-${Math.random().toString(36).slice(2)}`,
    `words-p1-${t0}-${Math.random().toString(36).slice(2)}`,
  ];
  const parallelResults = await Promise.allSettled([
    generateDailyWordChunkWithOpenAI(
      internalLang,
      level,
      DAILY_WORD_BATCH_SIZE,
      parallelSeeds[0],
      curriculum,
      blockedForPrompt
    ),
    generateDailyWordChunkWithOpenAI(
      internalLang,
      level,
      DAILY_WORD_BATCH_SIZE,
      parallelSeeds[1],
      curriculum,
      blockedForPrompt
    ),
  ]);

  for (let i = 0; i < parallelResults.length; i++) {
    const r = parallelResults[i];
    if (r.status === "fulfilled") {
      mergeWordBatchInto(r.value, out, used);
    } else {
      console.error(`[daily-words] parallel chunk ${i} failed`, r.reason);
    }
  }

  // 중복·실패로 목표 미만이면 한 번 더 (순차)
  if (out.length < DAILY_WORD_COUNT) {
    const need = Math.min(DAILY_WORD_BATCH_SIZE, DAILY_WORD_COUNT - out.length);
    try {
      const batch = await generateDailyWordChunkWithOpenAI(
        internalLang,
        level,
        need,
        `words-topup-${Date.now()}-${Math.random().toString(36).slice(2)}`,
        curriculum,
        blockedForPrompt
      );
      mergeWordBatchInto(batch, out, used);
    } catch (e) {
      console.error("[daily-words] top-up chunk AI failed", e);
    }
  }

  let fillAttempts = 0;
  while (out.length < DAILY_WORD_COUNT && fillAttempts < 75) {
    fillAttempts += 1;
    try {
      const one = await generateWordWithOpenAI(internalLang, level);
      const key = wordDedupKey(one.word);
      if (key && !used.has(key)) {
        used.add(key);
        out.push({
          word: one.word,
          meaningKo: one.meaningKo,
          ...(one.example ? { example: one.example } : {}),
          ...(one.exampleMeaningKo ? { exampleMeaningKo: one.exampleMeaningKo } : {}),
        });
      }
    } catch {
      const fb = fallbackWord(internalLang, level);
      const fk = wordDedupKey(fb.word);
      if (fk && !used.has(fk)) {
        used.add(fk);
        out.push({
          word: fb.word,
          meaningKo: fb.meaningKo,
          ...(fb.example ? { example: fb.example } : {}),
          ...(fb.exampleMeaningKo ? { exampleMeaningKo: fb.exampleMeaningKo } : {}),
        });
      }
    }
  }
  return out.slice(0, DAILY_WORD_COUNT);
}

async function buildDailySentenceItems(
  targetLanguage: string,
  level: string,
  requiredVocabulary?: string[],
  curriculum?: CurriculumPromptContext,
  blockedKeys?: Set<string>
): Promise<StoredSentenceItem[]> {
  const internalLang = normalizeTargetLanguage(targetLanguage).internal;
  const blockedForPrompt = blockedListForPrompt(blockedKeys ?? []);
  try {
    const batch = await generateDailySentenceBatchWithOpenAI(
      internalLang,
      level,
      DAILY_SENTENCE_COUNT,
      `s-${Date.now()}-${Math.random().toString(36).slice(2)}`,
      requiredVocabulary,
      curriculum,
      blockedForPrompt
    );
    const out: StoredSentenceItem[] = [];
    const used = new Set<string>(blockedKeys ?? []);
    for (const item of batch) {
      const key = sentenceDedupKey(item.sentence);
      if (!key || used.has(key)) {
        continue;
      }
      used.add(key);
      out.push(item);
    }
    if (out.length >= DAILY_SENTENCE_COUNT) {
      return out.slice(0, DAILY_SENTENCE_COUNT);
    }
  } catch (e) {
    console.error("[daily-sentences] batch AI failed", e);
  }

  const out: StoredSentenceItem[] = [];
  const used = new Set<string>(blockedKeys ?? []);
  let attempts = 0;
  while (out.length < DAILY_SENTENCE_COUNT && attempts < 40) {
    attempts += 1;
    try {
      const one = await generateSentenceWithOpenAI(internalLang, level);
      const key = sentenceDedupKey(one.sentence);
      if (key && !used.has(key)) {
        used.add(key);
        out.push({
          sentence: one.sentence,
          meaningKo: one.meaningKo,
          ...(one.sentenceHira ? { sentenceHira: one.sentenceHira } : {}),
          ...(one.vocabularyHints ? { vocabularyHints: one.vocabularyHints } : {}),
        });
      }
    } catch {
      const fb = fallbackSentence(internalLang, level);
      const fk = sentenceDedupKey(fb.sentence);
      if (fk && !used.has(fk)) {
        used.add(fk);
        out.push({
          sentence: fb.sentence,
          meaningKo: fb.meaningKo,
          ...(fb.sentenceHira ? { sentenceHira: fb.sentenceHira } : {}),
          ...(fb.vocabularyHints ? { vocabularyHints: fb.vocabularyHints } : {}),
        });
      }
    }
  }
  return out.slice(0, DAILY_SENTENCE_COUNT);
}

// globalTodayWordSetRef/globalTodaySentenceSetRef moved to ./learning_sets/refs.ts

/** 스케줄러에서만 호출: 없거나 비어 있으면 AI로 채움. Callable에서는 사용하지 않음. */
async function materializeGlobalTodayWordSetIfAbsent(
  targetLanguage: string,
  level: string,
  dateKst?: string
): Promise<FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>> {
  level = effectiveLearningLevel(level);
  await ensureGlobalLearningOwnerDoc();
  const tl = normalizeTargetLanguage(targetLanguage);
  const canonicalLang = tl.external;
  const ref = globalTodayWordSetRef(canonicalLang, level, dateKst);
  const snap = await ref.get();
  if (snap.exists) {
    const data = snap.data() as Partial<DailyWordSet>;
    if (
      data.targetLanguage === canonicalLang &&
      data.level === level &&
      Array.isArray(data.words) &&
      data.words.length > 0
    ) {
      if (data.words.some((w) => wordItemNeedsAudio(w))) {
        const words = await enrichWordItemsWithAudio(data.words, canonicalLang);
        await ref.set({ words, updatedAtMs: Date.now() }, { merge: true });
      }
      return ref;
    }
  }

  const ymd = dateKst ?? todayKstYyyyMmDd();
  await cleanupExpiredLearningSets(GLOBAL_LEARNING_SET_OWNER, ymd);
  const words = await enrichWordItemsWithAudio(
    await buildDailyWordItems(canonicalLang, level),
    canonicalLang
  );
  const payload: DailyWordSet = {
    dateKst: ymd,
    targetLanguage: canonicalLang,
    level,
    words,
    cursor: 0,
    updatedAtMs: Date.now(),
  };
  await ref.set(payload);

  // 레거시 alpha-2 문서가 같은 날 생성된 경우 정리(글로벌 세트만)
  // ex) 2026-04-09_ja_beginner → 2026-04-09_JPN_beginner
  const legacy = (targetLanguage ?? "").trim();
  if (legacy.length > 0 && legacy.toUpperCase() !== canonicalLang) {
    const legacyId = learningSetDocId(ymd, legacy, level);
    const legacyRef = db
      .collection("users")
      .doc(GLOBAL_LEARNING_SET_OWNER)
      .collection("daily_word_sets")
      .doc(legacyId);
    const legacySnap = await legacyRef.get();
    if (legacySnap.exists) {
      await legacyRef.delete();
    }
  }
  return ref;
}

/** 스케줄러에서만 호출: 없거나 비어 있으면 AI로 채움. Callable에서는 사용하지 않음. */
async function materializeGlobalTodaySentenceSetIfAbsent(
  targetLanguage: string,
  level: string,
  dateKst?: string
): Promise<FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>> {
  level = effectiveLearningLevel(level);
  await ensureGlobalLearningOwnerDoc();
  const tl = normalizeTargetLanguage(targetLanguage);
  const canonicalLang = tl.external;
  const ref = globalTodaySentenceSetRef(canonicalLang, level, dateKst);
  const snap = await ref.get();
  if (snap.exists) {
    const data = snap.data() as Partial<DailySentenceSet>;
    if (
      data.targetLanguage === canonicalLang &&
      data.level === level &&
      Array.isArray(data.sentences) &&
      data.sentences.length > 0
    ) {
      if (data.sentences.some((s) => sentenceItemNeedsAudio(s))) {
        const sentences = await enrichSentenceItemsWithAudio(
          data.sentences,
          canonicalLang
        );
        await ref.set({ sentences, updatedAtMs: Date.now() }, { merge: true });
      }
      return ref;
    }
  }

  const ymd = dateKst ?? todayKstYyyyMmDd();
  await cleanupExpiredLearningSets(GLOBAL_LEARNING_SET_OWNER, ymd);

  // 오늘의 문장은 "오늘의 단어"를 이용한 문장으로 생성한다.
  // - 단어 세트를 먼저 materialize 하고, 그 중 일부(최대 10개)를 뽑아 문장 생성에 강제 사용.
  await materializeGlobalTodayWordSetIfAbsent(canonicalLang, level, ymd);
  const wordSnap = await globalTodayWordSetRef(canonicalLang, level, ymd).get();
  const wdata = wordSnap.data() as Partial<DailyWordSet> | undefined;
  const words = Array.isArray(wdata?.words) ? wdata!.words : [];
  const vocab = shuffle(words)
    .map((w) => (w?.word ? String(w.word) : ""))
    .filter((w) => w.trim().length > 0)
    .slice(0, Math.min(DAILY_SENTENCE_COUNT, words.length));

  const sentences = await enrichSentenceItemsWithAudio(
    await buildDailySentenceItems(canonicalLang, level, vocab.length > 0 ? vocab : undefined),
    canonicalLang
  );
  const payload: DailySentenceSet = {
    dateKst: ymd,
    targetLanguage: canonicalLang,
    level,
    sentences,
    cursor: 0,
    updatedAtMs: Date.now(),
  };
  await ref.set(payload);

  // 레거시 alpha-2 문서가 같은 날 생성된 경우 정리(글로벌 세트만)
  const legacy = (targetLanguage ?? "").trim();
  if (legacy.length > 0 && legacy.toUpperCase() !== canonicalLang) {
    const legacyId = learningSetDocId(ymd, legacy, level);
    const legacyRef = db
      .collection("users")
      .doc(GLOBAL_LEARNING_SET_OWNER)
      .collection("daily_sentence_sets")
      .doc(legacyId);
    const legacySnap = await legacyRef.get();
    if (legacySnap.exists) {
      await legacyRef.delete();
    }
  }
  return ref;
}

/** 커리큘럼 일차 단어 세트 — 없으면 AI 생성 (초·중만) */
async function materializeGlobalCurriculumWordSetIfAbsent(
  targetLanguage: string,
  level: string,
  phase: number,
  learningDay: number
): Promise<FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>> {
  level = effectiveLearningLevel(level);
  if (!isCurriculumSetLevel(level)) {
    throw new HttpsError(
      "failed-precondition",
      "curriculum word sets are only available for beginner and intermediate"
    );
  }
  await ensureGlobalLearningOwnerDoc();
  const tl = normalizeTargetLanguage(targetLanguage);
  const canonicalLang = tl.external;
  const ref = globalCurriculumWordSetRef(canonicalLang, level, phase, learningDay);
  const snap = await ref.get();
  if (snap.exists) {
    const data = snap.data() as Partial<CurriculumWordSet>;
    if (
      data.targetLanguage === canonicalLang &&
      data.level === level &&
      data.curriculumPhase === phase &&
      data.learningDay === learningDay &&
      Array.isArray(data.words) &&
      data.words.length > 0
    ) {
      const topicLabelsKo = curriculumTopicLabelsKoForDay(learningDay);
      const needsTopicLabels =
        topicLabelsKo.length > 0 &&
        (!Array.isArray(data.topicLabelsKo) || data.topicLabelsKo.length === 0);
      const needsAudio = data.words.some((w) => wordItemNeedsAudio(w));
      if (needsTopicLabels || needsAudio) {
        const patch: Record<string, unknown> = { updatedAtMs: Date.now() };
        if (needsTopicLabels) {
          patch.topicLabelsKo = topicLabelsKo;
        }
        if (needsAudio) {
          patch.words = await enrichWordItemsWithAudio(data.words, canonicalLang);
        }
        await ref.set(patch, { merge: true });
      }
      return ref;
    }
  }

  const curriculum = curriculumPromptContextForDay(learningDay, phase);
  const spec = getCurriculumDaySpec(learningDay);
  const topicLabelsKo = curriculumTopicLabelsKoForDay(learningDay);
  const blockedWords = await loadPriorCurriculumWordDedupKeys(
    canonicalLang,
    level,
    phase,
    learningDay
  );
  const words = await enrichWordItemsWithAudio(
    await buildDailyWordItems(canonicalLang, level, curriculum, blockedWords),
    canonicalLang
  );
  const payload: CurriculumWordSet = {
    curriculumId: CURRICULUM_CORE_V1_ID,
    targetLanguage: canonicalLang,
    level,
    curriculumPhase: phase,
    learningDay,
    topicIds: [...(spec?.topicIds ?? [])],
    topicLabelsKo,
    words,
    updatedAtMs: Date.now(),
  };
  await ref.set(payload);
  return ref;
}

/** 커리큘럼 일차 문장 세트 — 해당 일차 단어를 참고해 AI 생성 */
async function materializeGlobalCurriculumSentenceSetIfAbsent(
  targetLanguage: string,
  level: string,
  phase: number,
  learningDay: number
): Promise<FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>> {
  level = effectiveLearningLevel(level);
  if (!isCurriculumSetLevel(level)) {
    throw new HttpsError(
      "failed-precondition",
      "curriculum sentence sets are only available for beginner and intermediate"
    );
  }
  await ensureGlobalLearningOwnerDoc();
  const tl = normalizeTargetLanguage(targetLanguage);
  const canonicalLang = tl.external;
  const ref = globalCurriculumSentenceSetRef(canonicalLang, level, phase, learningDay);
  const snap = await ref.get();
  if (snap.exists) {
    const data = snap.data() as Partial<CurriculumSentenceSet>;
    if (
      data.targetLanguage === canonicalLang &&
      data.level === level &&
      data.curriculumPhase === phase &&
      data.learningDay === learningDay &&
      Array.isArray(data.sentences) &&
      data.sentences.length > 0
    ) {
      const topicLabelsKo = curriculumTopicLabelsKoForDay(learningDay);
      const needsTopicLabels =
        topicLabelsKo.length > 0 &&
        (!Array.isArray(data.topicLabelsKo) || data.topicLabelsKo.length === 0);
      const needsAudio = data.sentences.some((s) => sentenceItemNeedsAudio(s));
      if (needsTopicLabels || needsAudio) {
        const patch: Record<string, unknown> = { updatedAtMs: Date.now() };
        if (needsTopicLabels) {
          patch.topicLabelsKo = topicLabelsKo;
        }
        if (needsAudio) {
          patch.sentences = await enrichSentenceItemsWithAudio(
            data.sentences,
            canonicalLang
          );
        }
        await ref.set(patch, { merge: true });
      }
      return ref;
    }
  }

  const curriculum = curriculumPromptContextForDay(learningDay, phase);
  const spec = getCurriculumDaySpec(learningDay);
  const topicLabelsKo = curriculumTopicLabelsKoForDay(learningDay);

  await materializeGlobalCurriculumWordSetIfAbsent(
    canonicalLang,
    level,
    phase,
    learningDay
  );
  const wordSnap = await globalCurriculumWordSetRef(
    canonicalLang,
    level,
    phase,
    learningDay
  ).get();
  const wdata = wordSnap.data() as Partial<CurriculumWordSet> | undefined;
  const words = Array.isArray(wdata?.words) ? wdata!.words : [];
  const vocab = shuffle(words)
    .map((w) => (w?.word ? String(w.word) : ""))
    .filter((w) => w.trim().length > 0)
    .slice(0, Math.min(DAILY_SENTENCE_COUNT, words.length));

  const blockedSentences = await loadPriorCurriculumSentenceDedupKeys(
    canonicalLang,
    level,
    phase,
    learningDay
  );
  const sentences = await enrichSentenceItemsWithAudio(
    await buildDailySentenceItems(
      canonicalLang,
      level,
      vocab.length > 0 ? vocab : undefined,
      curriculum,
      blockedSentences
    ),
    canonicalLang
  );
  const payload: CurriculumSentenceSet = {
    curriculumId: CURRICULUM_CORE_V1_ID,
    targetLanguage: canonicalLang,
    level,
    curriculumPhase: phase,
    learningDay,
    topicIds: [...(spec?.topicIds ?? [])],
    topicLabelsKo,
    sentences,
    updatedAtMs: Date.now(),
  };
  await ref.set(payload);
  return ref;
}

/** phase 1 특정 일차 단어·문장 세트 1쌍 생성(이미 있으면 skip) */
async function materializeCurriculumPhase1Day(
  targetLanguage: string,
  level: string,
  learningDay: number
): Promise<void> {
  await materializeGlobalCurriculumWordSetIfAbsent(
    targetLanguage,
    level,
    PREGEN_CURRICULUM_PHASE,
    learningDay
  );
  await materializeGlobalCurriculumSentenceSetIfAbsent(
    targetLanguage,
    level,
    PREGEN_CURRICULUM_PHASE,
    learningDay
  );
}

function assertDevWarmupUidAllowed(uid: string): void {
  const isEmulator = process.env.FUNCTIONS_EMULATOR === "true";
  if (isEmulator) {
    return;
  }
  const allowRaw = (process.env.DEV_WARMUP_UID_ALLOWLIST ?? "").trim();
  const allowed = new Set(
    allowRaw
      .split(",")
      .map((s) => s.trim())
      .filter((s) => s.length > 0)
  );
  if (allowed.size === 0) {
    throw new HttpsError("failed-precondition", "DEV_WARMUP_UID_ALLOWLIST is missing");
  }
  if (!allowed.has(uid)) {
    throw new HttpsError("permission-denied", "not allowed");
  }
}

function resolvePregenPairs(
  targetLanguage?: string,
  level?: string
): CurriculumPregenPair[] {
  if (!targetLanguage && !level) {
    return activePregenCurriculumPairs();
  }
  const tl = targetLanguage?.trim().toUpperCase();
  const lv = effectiveLearningLevel(level);
  return activePregenCurriculumPairs().filter((p) => {
    if (tl && p.targetLanguage !== tl) return false;
    if (lv && p.level !== lv) return false;
    if (!LEARNING_DIFFICULTY_UI_ENABLED && p.level !== "beginner") return false;
    return true;
  });
}

async function popWordFromCurriculumSet(
  uid: string,
  profile: UserLearningProfile
): Promise<GenerateWordResponse> {
  const { targetLanguage, level, curriculumPhase, learningDay } = profile;
  const setRef = globalCurriculumWordSetRef(
    targetLanguage,
    level,
    curriculumPhase,
    learningDay
  );
  const cursorId = curriculumSetDocId(targetLanguage, level, curriculumPhase, learningDay);
  const cursorRef = db
    .collection("users")
    .doc(uid)
    .collection("curriculum_word_cursor")
    .doc(cursorId);

  return db.runTransaction(async (tx) => {
    const setSnap = await tx.get(setRef);
    const data = (setSnap.data() ?? {}) as Partial<CurriculumWordSet>;
    const words = Array.isArray(data.words) ? data.words : [];
    if (words.length === 0) {
      return { ...fallbackWord(targetLanguage, level), debugSource: "fallback" };
    }
    const cursorSnap = await tx.get(cursorRef);
    const cursorData = cursorSnap.data() ?? {};
    const cursor = Number(cursorData.cursor ?? 0);
    const index = ((cursor % words.length) + words.length) % words.length;
    const picked = words[index];
    if (!picked?.word || !picked?.meaningKo) {
      return { ...fallbackWord(targetLanguage, level), debugSource: "fallback" };
    }
    tx.set(
      cursorRef,
      {
        curriculumId: CURRICULUM_CORE_V1_ID,
        targetLanguage,
        level,
        curriculumPhase,
        learningDay,
        cursor: cursor + 1,
        updatedAtMs: Date.now(),
      },
      { merge: true }
    );
    return {
      word: picked.word,
      meaningKo: picked.meaningKo,
      ...(picked.readingHira ? { readingHira: picked.readingHira } : {}),
      ...(picked.example ? { example: picked.example } : {}),
      ...(picked.exampleMeaningKo ? { exampleMeaningKo: picked.exampleMeaningKo } : {}),
      ...(picked.wordAudioPath ? { wordAudioPath: picked.wordAudioPath } : {}),
      ...(picked.exampleAudioPath ? { exampleAudioPath: picked.exampleAudioPath } : {}),
      debugSource: "curriculum_set",
    };
  });
}

async function popSentenceFromCurriculumSet(
  uid: string,
  profile: UserLearningProfile
): Promise<GenerateSentenceResponse> {
  const { targetLanguage, level, curriculumPhase, learningDay } = profile;
  const setRef = globalCurriculumSentenceSetRef(
    targetLanguage,
    level,
    curriculumPhase,
    learningDay
  );
  const cursorId = curriculumSetDocId(targetLanguage, level, curriculumPhase, learningDay);
  const cursorRef = db
    .collection("users")
    .doc(uid)
    .collection("curriculum_sentence_cursor")
    .doc(cursorId);

  return db.runTransaction(async (tx) => {
    const setSnap = await tx.get(setRef);
    const data = (setSnap.data() ?? {}) as Partial<CurriculumSentenceSet>;
    const sentences = Array.isArray(data.sentences) ? data.sentences : [];
    if (sentences.length === 0) {
      return { ...fallbackSentence(targetLanguage, level), debugSource: "fallback" };
    }
    const cursorSnap = await tx.get(cursorRef);
    const cursorData = cursorSnap.data() ?? {};
    const cursor = Number(cursorData.cursor ?? 0);
    const index = ((cursor % sentences.length) + sentences.length) % sentences.length;
    const picked = sentences[index];
    if (!picked?.sentence || !picked?.meaningKo) {
      return { ...fallbackSentence(targetLanguage, level), debugSource: "fallback" };
    }
    tx.set(
      cursorRef,
      {
        curriculumId: CURRICULUM_CORE_V1_ID,
        targetLanguage,
        level,
        curriculumPhase,
        learningDay,
        cursor: cursor + 1,
        updatedAtMs: Date.now(),
      },
      { merge: true }
    );
    return {
      sentence: picked.sentence,
      meaningKo: picked.meaningKo,
      ...(picked.sentenceHira ? { sentenceHira: picked.sentenceHira } : {}),
      ...(picked.vocabularyHints && picked.vocabularyHints.length > 0
          ? { vocabularyHints: picked.vocabularyHints }
          : {}),
      ...(picked.sentenceAudioPath ? { sentenceAudioPath: picked.sentenceAudioPath } : {}),
      debugSource: "curriculum_set",
    };
  });
}

async function popWordFromTodaySet(
  uid: string,
  targetLanguage: string,
  level: string
): Promise<GenerateWordResponse> {
  const todayKst = todayKstYyyyMmDd();
  const setRef = globalTodayWordSetRef(targetLanguage, level);
  const cursorRef = db
    .collection("users")
    .doc(uid)
    .collection("daily_word_cursor")
    .doc(learningSetDocId(todayKst, targetLanguage, level));

  return db.runTransaction(async (tx) => {
    const setSnap = await tx.get(setRef);
    const data = (setSnap.data() ?? {}) as Partial<DailyWordSet>;
    const words = Array.isArray(data.words) ? data.words : [];
    if (words.length === 0) {
      return { ...fallbackWord(targetLanguage, level), debugSource: "fallback" };
    }
    const cursorSnap = await tx.get(cursorRef);
    const cursorData = cursorSnap.data() ?? {};
    const cursor = Number(cursorData.cursor ?? 0);
    const index = ((cursor % words.length) + words.length) % words.length;
    const picked = words[index];
    if (!picked?.word || !picked?.meaningKo) {
      return { ...fallbackWord(targetLanguage, level), debugSource: "fallback" };
    }
    tx.set(
      cursorRef,
      {
        dateKst: todayKst,
        targetLanguage,
        level,
        cursor: cursor + 1,
        updatedAtMs: Date.now(),
      },
      { merge: true }
    );
    return {
      word: picked.word,
      meaningKo: picked.meaningKo,
      ...(picked.readingHira ? { readingHira: picked.readingHira } : {}),
      ...(picked.example ? { example: picked.example } : {}),
      ...(picked.exampleMeaningKo ? { exampleMeaningKo: picked.exampleMeaningKo } : {}),
      ...(picked.wordAudioPath ? { wordAudioPath: picked.wordAudioPath } : {}),
      ...(picked.exampleAudioPath ? { exampleAudioPath: picked.exampleAudioPath } : {}),
      debugSource: "daily_set",
    };
  });
}

async function popSentenceFromTodaySet(
  uid: string,
  targetLanguage: string,
  level: string
): Promise<GenerateSentenceResponse> {
  const todayKst = todayKstYyyyMmDd();
  const setRef = globalTodaySentenceSetRef(targetLanguage, level);
  const cursorRef = db
    .collection("users")
    .doc(uid)
    .collection("daily_sentence_cursor")
    .doc(learningSetDocId(todayKst, targetLanguage, level));

  return db.runTransaction(async (tx) => {
    const setSnap = await tx.get(setRef);
    const data = (setSnap.data() ?? {}) as Partial<DailySentenceSet>;
    const sentences = Array.isArray(data.sentences) ? data.sentences : [];
    if (sentences.length === 0) {
      return { ...fallbackSentence(targetLanguage, level), debugSource: "fallback" };
    }
    const cursorSnap = await tx.get(cursorRef);
    const cursorData = cursorSnap.data() ?? {};
    const cursor = Number(cursorData.cursor ?? 0);
    const index = ((cursor % sentences.length) + sentences.length) % sentences.length;
    const picked = sentences[index];
    if (!picked?.sentence || !picked?.meaningKo) {
      return { ...fallbackSentence(targetLanguage, level), debugSource: "fallback" };
    }
    tx.set(
      cursorRef,
      {
        dateKst: todayKst,
        targetLanguage,
        level,
        cursor: cursor + 1,
        updatedAtMs: Date.now(),
      },
      { merge: true }
    );
    return {
      sentence: picked.sentence,
      meaningKo: picked.meaningKo,
      ...(picked.sentenceHira ? { sentenceHira: picked.sentenceHira } : {}),
      ...(picked.vocabularyHints && picked.vocabularyHints.length > 0
          ? { vocabularyHints: picked.vocabularyHints }
          : {}),
      ...(picked.sentenceAudioPath ? { sentenceAudioPath: picked.sentenceAudioPath } : {}),
      debugSource: "daily_set",
    };
  });
}

/** 앱에서만 호출. 자정 배치로 만든 Firestore 세트에서만 꺼냄(AI 생성 없음). 없으면 정적 폴백. */
export const generateWord = onCall({ region: "asia-northeast3" }, async (request): Promise<GenerateWordResponse> => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
  }

  const uid = request.auth.uid;
  const profile = await resolveUserLearningProfile(uid, request.data as Record<string, unknown>);
  const { targetLanguage, level } = profile;

  console.error(
    `[generateWord] invoked targetLanguage=${targetLanguage}, level=${level}, day=${profile.learningDay}`
  );
  try {
    const res = isCurriculumSetLevel(level)
      ? await popWordFromCurriculumSet(uid, profile)
      : await popWordFromTodaySet(uid, targetLanguage, level);
    console.log(
      `[generateWord] source=${res.debugSource} targetLanguage=${targetLanguage}, level=${level}, day=${profile.learningDay}`
    );
    return res;
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    console.error(`[generateWord] read/pop failed. message=${msg}`);
    return { ...fallbackWord(targetLanguage, level), debugSource: "fallback" };
  }
});

/** 문장도 동일: 세트는 스케줄러만 생성, 앱은 읽기만. */
export const generateSentence = onCall({ region: "asia-northeast3" }, async (request): Promise<GenerateSentenceResponse> => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
  }

  const uid = request.auth.uid;
  const profile = await resolveUserLearningProfile(uid, request.data as Record<string, unknown>);
  const { targetLanguage, level } = profile;

  console.error(
    `[generateSentence] invoked targetLanguage=${targetLanguage}, level=${level}, day=${profile.learningDay}`
  );
  try {
    const res = isCurriculumSetLevel(level)
      ? await popSentenceFromCurriculumSet(uid, profile)
      : await popSentenceFromTodaySet(uid, targetLanguage, level);
    console.log(
      `[generateSentence] source=${res.debugSource} targetLanguage=${targetLanguage}, level=${level}, day=${profile.learningDay}`
    );
    return res;
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    console.error(`[generateSentence] read/pop failed. message=${msg}`);
    return { ...fallbackSentence(targetLanguage, level), debugSource: "fallback" };
  }
});

/**
 * 개발 단계 전용: 앱 실행 시 오늘(KST) 단어/문장 세트가 없으면 서버에서 즉시 생성합니다.
 * - 배포 환경에서 무분별한 비용 발생을 막기 위해, 클라이언트에서 kDebugMode일 때만 호출하세요.
 * - 호출 자체는 인증 필수이며, 실패해도 앱 동작을 막지 않는 용도로 설계합니다.
 */
export const ensureTodayLearningSets = onCall(
  {
    region: "asia-northeast3",
    secrets: ["OPENAI_API_KEY", "DEV_WARMUP_UID_ALLOWLIST"],
    timeoutSeconds: 300,
    memory: "512MiB",
  },
  async (request): Promise<{ ok: true; dateKst: string }> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }
    // 개발 앱에서만 보내도록 클라이언트가 강제 (서버는 추가적으로 플래그를 확인)
    const dev = Boolean(request.data?.dev);
    if (!dev) {
      throw new HttpsError("failed-precondition", "dev flag is required");
    }

    // 운영에서 비용 폭증 방지: allowlist에 포함된 UID만 실행 (에뮬레이터는 예외)
    assertDevWarmupUidAllowed(request.auth.uid);

    const profile = await resolveUserLearningProfile(
      request.auth.uid,
      request.data as Record<string, unknown>
    );
    const { targetLanguage, level, curriculumPhase, learningDay } = profile;
    const todayKst = todayKstYyyyMmDd();

    console.log("[ensureTodayLearningSets] start", {
      uid: request.auth.uid,
      todayKst,
      targetLanguage,
      level,
      curriculumPhase,
      learningDay,
    });
    const t0 = Date.now();
    if (isCurriculumSetLevel(level)) {
      await materializeGlobalCurriculumWordSetIfAbsent(
        targetLanguage,
        level,
        curriculumPhase,
        learningDay
      );
      await materializeGlobalCurriculumSentenceSetIfAbsent(
        targetLanguage,
        level,
        curriculumPhase,
        learningDay
      );
    } else {
      await materializeGlobalTodayWordSetIfAbsent(targetLanguage, level, todayKst);
      await materializeGlobalTodaySentenceSetIfAbsent(targetLanguage, level, todayKst);
    }
    console.log("[ensureTodayLearningSets] done", {
      todayKst,
      targetLanguage,
      level,
      curriculumPhase,
      learningDay,
      elapsedMs: Date.now() - t0,
    });

    return { ok: true, dateKst: todayKst };
  }
);

/**
 * 언어/레벨 선택 시 현재 learningDay 세트 존재 확인 (초·중).
 * - 1단계 50일치는 `seedCurriculumPhase1Sets`로 미리 생성해 둔다. 없을 때만 materialize(폴백).
 * - learningDay +1 은 앱 D-1(일일 15/5/13 완료)에서 처리한다.
 */
export const ensureLearningSetForToday = onCall(
  { region: "asia-northeast3", secrets: ["OPENAI_API_KEY"], timeoutSeconds: 300, memory: "512MiB" },
  async (
    request
  ): Promise<{
    ok: true;
    targetLanguage: string;
    level: string;
    curriculumPhase: number;
    learningDay: number;
  }> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }
    const profile = await resolveUserLearningProfile(
      request.auth.uid,
      request.data as Record<string, unknown>
    );
    const { targetLanguage, level, curriculumPhase, learningDay } = profile;
    if (!isCurriculumSetLevel(level)) {
      throw new HttpsError(
        "failed-precondition",
        "curriculum learning sets are only available for beginner and intermediate levels"
      );
    }
    console.log("[ensureLearningSetForToday] start", {
      uid: request.auth.uid,
      targetLanguage,
      level,
      curriculumPhase,
      learningDay,
    });
    const t0 = Date.now();
    await materializeGlobalCurriculumWordSetIfAbsent(
      targetLanguage,
      level,
      curriculumPhase,
      learningDay
    );
    await materializeGlobalCurriculumSentenceSetIfAbsent(
      targetLanguage,
      level,
      curriculumPhase,
      learningDay
    );
    console.log("[ensureLearningSetForToday] done", {
      targetLanguage,
      level,
      curriculumPhase,
      learningDay,
      elapsedMs: Date.now() - t0,
    });
    return { ok: true, targetLanguage, level, curriculumPhase, learningDay };
  }
);

/**
 * 관리자 전용: 지정 일차(N) 커리큘럼 단어·문장 세트 생성.
 * - 해당 일차 세트가 이미 있으면 skip (재생성 없음)
 */
export const ensureCurriculumDaySet = onCall(
  { region: "asia-northeast3", secrets: ["OPENAI_API_KEY"], timeoutSeconds: 300, memory: "512MiB" },
  async (
    request
  ): Promise<{
    ok: true;
    status: "created" | "skipped";
    targetLanguage: string;
    level: string;
    curriculumPhase: number;
    learningDay: number;
  }> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }
    assertAdminToolsUid(request.auth.uid);

    const rawDay = request.data?.learningDay;
    const learningDay = clampLearningDay(
      typeof rawDay === "number" ? rawDay : Number.parseInt(String(rawDay ?? ""), 10)
    );
    const profile = await resolveUserLearningProfile(
      request.auth.uid,
      request.data as Record<string, unknown>
    );
    const targetLanguage =
      ((request.data?.targetLanguage as string | undefined)?.trim() ||
        profile.targetLanguage) as string;
    const level = effectiveLearningLevel(
      (request.data?.level as string | undefined) ?? profile.level
    );
    const curriculumPhase =
      parseCurriculumPhase(request.data?.curriculumPhase) ?? profile.curriculumPhase;

    if (!isCurriculumSetLevel(level)) {
      throw new HttpsError(
        "failed-precondition",
        "curriculum day sets are only available for beginner and intermediate levels"
      );
    }

    const ready = await isCurriculumPhase1DayMaterialized(
      targetLanguage,
      level,
      learningDay,
      curriculumPhase
    );
    if (ready) {
      console.log("[ensureCurriculumDaySet] skipped (already exists)", {
        targetLanguage,
        level,
        curriculumPhase,
        learningDay,
      });
      return {
        ok: true,
        status: "skipped",
        targetLanguage,
        level,
        curriculumPhase,
        learningDay,
      };
    }

    console.log("[ensureCurriculumDaySet] creating", {
      uid: request.auth.uid,
      targetLanguage,
      level,
      curriculumPhase,
      learningDay,
    });
    const t0 = Date.now();
    await materializeGlobalCurriculumWordSetIfAbsent(
      targetLanguage,
      level,
      curriculumPhase,
      learningDay
    );
    await materializeGlobalCurriculumSentenceSetIfAbsent(
      targetLanguage,
      level,
      curriculumPhase,
      learningDay
    );
    console.log("[ensureCurriculumDaySet] done", {
      targetLanguage,
      level,
      curriculumPhase,
      learningDay,
      elapsedMs: Date.now() - t0,
    });
    return {
      ok: true,
      status: "created",
      targetLanguage,
      level,
      curriculumPhase,
      learningDay,
    };
  }
);

// NOTE: 단어 퀴즈(generateQuiz)는 현재 앱 기능에서 제거되어, Functions에서도 노출하지 않습니다.

/**
 * 1단계(phase 1) 커리큘럼 50일치 일괄 선생성 (초기 시드·갭 보충).
 * - dev 플래그 + DEV_WARMUP_UID_ALLOWLIST 필요
 * - targetLanguage/level 생략 시 6조합 전체 × 1~50일, 있으면 해당 조합만
 */
export const seedCurriculumPhase1Sets = onCall(
  {
    region: "asia-northeast3",
    secrets: ["OPENAI_API_KEY", "DEV_WARMUP_UID_ALLOWLIST"],
    timeoutSeconds: 3600,
    memory: "512MiB",
  },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }
    const dev = Boolean(request.data?.dev);
    if (!dev) {
      throw new HttpsError("failed-precondition", "dev flag is required");
    }
    assertDevWarmupUidAllowed(request.auth.uid);

    const targetLanguage = (request.data?.targetLanguage as string | undefined)?.trim();
    const level = (request.data?.level as string | undefined)?.trim();
    const pairs = resolvePregenPairs(targetLanguage, level);
    if (pairs.length === 0) {
      throw new HttpsError("invalid-argument", "no matching language/level pair");
    }

    console.log("[seedCurriculumPhase1Sets] start", {
      uid: request.auth.uid,
      pairs,
      phase: PREGEN_CURRICULUM_PHASE,
    });
    const t0 = Date.now();
    const summary = await pregenerateCurriculumPhase1Days(
      pairs,
      materializeCurriculumPhase1Day
    );
    console.log("[seedCurriculumPhase1Sets] done", {
      elapsedMs: Date.now() - t0,
      ...summary,
    });
    return { ok: true as const, ...summary };
  }
);

/**
 * 매일 KST 23:55 — 1단계 50일치 중 **아직 없는 일차**를 모두 채움(이미 있으면 skip).
 * 일괄 시드 후 남은 갭 보충용. Blaze + Cloud Scheduler 필요.
 */
export const pregenerateDailyLearningSets = onSchedule(
  {
    schedule: "55 23 * * *",
    timeZone: "Asia/Seoul",
    region: "asia-northeast3",
    secrets: ["OPENAI_API_KEY"],
    timeoutSeconds: 540,
    memory: "512MiB",
  },
  async () => {
    const todayKst = todayKstYyyyMmDd();
    console.log("[pregenerateDailyLearningSets] start", {
      todayKst,
      phase: PREGEN_CURRICULUM_PHASE,
      pairs: activePregenCurriculumPairs().length,
    });
    const summary = await pregenerateCurriculumPhase1Days(
      activePregenCurriculumPairs(),
      materializeCurriculumPhase1Day
    );
    console.log("[pregenerateDailyLearningSets] done", { todayKst, ...summary });
  }
);

/**
 * 레거시/미사용 문서 정리(스케줄).
 * - alpha-2 기반 글로벌 학습 세트 문서(예: 2026-04-09_ja_beginner) 삭제
 *
 * 주의: 앱/Functions에서 더 이상 참조하지 않는 문서만 대상으로 합니다.
 */
// moved to ./maintenance/cleanup.ts
