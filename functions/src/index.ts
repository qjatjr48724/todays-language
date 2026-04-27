import { onCall, HttpsError } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

import {
  buildDailySentenceBatchSystemPrompt,
  buildDailySentenceBatchUserPromptJson,
  buildDailyWordBatchSystemPrompt,
  buildDailyWordBatchUserPromptJson,
  buildSentenceSystemPrompt,
  buildSentenceUserPromptJson,
  buildWordSystemPrompt,
  buildWordUserPromptJson,
} from "./prompts";

type GenerateWordResponse = {
  word: string;
  meaningKo: string;
  example?: string;
  debugSource?: "openai" | "fallback" | "daily_set";
};

type GenerateSentenceResponse = {
  sentence: string;
  meaningKo: string;
  debugSource?: "openai" | "fallback" | "daily_set";
};

type StoredWordItem = {
  word: string;
  meaningKo: string;
  example?: string;
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
  meaningKo: string;
};

type DailySentenceSet = {
  dateKst: string;
  targetLanguage: string;
  level: string;
  sentences: StoredSentenceItem[];
  cursor: number;
  updatedAtMs: number;
};

type WrapUpDeckItem = {
  kind: "word" | "sentence";
  meaningKo: string;
  answer: string;
};

const OPENAI_API_URL = "https://api.openai.com/v1/responses";
const OPENAI_MODEL = process.env.OPENAI_MODEL ?? "gpt-4.1-mini";
/** 오늘의 단어 화면 일일 목표와 동일하게 유지 */
const DAILY_WORD_COUNT = 30;
/** 오늘의 문장 화면 일일 목표와 동일하게 유지 */
const DAILY_SENTENCE_COUNT = 10;
/** 단어 배치 한 번에 요청할 개수 (두 배치 병렬 호출 → 문장 1회와 비슷한 체감에 가깝게) */
const DAILY_WORD_BATCH_SIZE = 15;
const DEFAULT_RETENTION_DAYS = 7;
const GLOBAL_QUIZ_SET_OWNER = "global_quiz_owner";
/** 일일 단어·문장 세트 공유 소유자 (모든 유저가 동일 30/10 풀 사용, 커서만 사용자별). */
const GLOBAL_LEARNING_SET_OWNER = "global_learning_set_owner";

/** 스케줄러가 자정 전후에 미리 생성할 (targetLanguage, level) 목록 */
const PREGEN_LANGUAGE_LEVEL_PAIRS: { targetLanguage: string; level: string }[] = [
  // ISO-3166-1 alpha-3 표기(외부/Firestore/API 입력 기준)
  { targetLanguage: "JPN", level: "beginner" },
];
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
  // accept legacy language codes from old clients
  const lower = raw.toLowerCase();
  if (lower === "ja") return { external: "JPN", internal: "ja" };
  if (lower === "es") return { external: "ESP", internal: "es" };
  if (lower === "en") return { external: "USA", internal: "en" };
  // default passthrough
  return { external: upper.length === 3 ? upper : raw, internal: lower };
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

function normalizePromptKey(text: string): string {
  return text
    .toLowerCase()
    .replace(/\s+/g, "")
    .replace(/[^\p{L}\p{N}]/gu, "");
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
    };
  }
  return {
    word: "hola",
    meaningKo: "안녕",
    example: "Hola, ¿cómo estás?",
  };
}

function fallbackSentence(targetLanguage: string, level: string): GenerateSentenceResponse {
  const lang = normalizeTargetLanguage(targetLanguage).internal;
  if (lang === "ja" && level === "beginner") {
    return {
      sentence: "きょうはいいてんきですね。",
      meaningKo: "오늘은 날씨가 좋네요.",
    };
  }
  return {
    sentence: "Hoy hace buen tiempo.",
    meaningKo: "오늘 날씨가 좋아요.",
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
    const meaningKo =
      readOptionalString(parsed, ["meaningKo"]) ??
      readOptionalString(parsed, ["meaning", "koMeaning", "koreanMeaning"]);
    const ex = readOptionalString(parsed, ["example", "exampleSentence"]);

    if (!word || !meaningKo) {
      throw new Error("OpenAI response JSON schema mismatch (word)");
    }
    return {
      word,
      meaningKo,
      example: ex && ex.length > 0 ? ex : undefined,
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
    const meaningKo =
      readOptionalString(parsed, ["meaningKo"]) ??
      readOptionalString(parsed, ["meaning", "koMeaning", "koreanMeaning"]);

    if (!sentence || !meaningKo) {
      throw new Error("OpenAI response JSON schema mismatch (sentence)");
    }
    return {
      sentence,
      meaningKo,
    };
  } finally {
    clearTimeout(timeout);
  }
}

function parseWordItem(value: unknown): StoredWordItem | null {
  if (typeof value !== "object" || value === null) return null;
  const word = readOptionalString(value, ["word"]);
  const meaningKo =
    readOptionalString(value, ["meaningKo"]) ??
    readOptionalString(value, ["meaning", "koMeaning", "koreanMeaning"]);
  if (!word || !meaningKo) return null;
  const example = readOptionalString(value, ["example", "exampleSentence"]);
  return example ? { word, meaningKo, example } : { word, meaningKo };
}

function parseSentenceItem(value: unknown): StoredSentenceItem | null {
  if (typeof value !== "object" || value === null) return null;
  const sentence = readOptionalString(value, ["sentence"]);
  const meaningKo =
    readOptionalString(value, ["meaningKo"]) ??
    readOptionalString(value, ["meaning", "koMeaning", "koreanMeaning"]);
  if (!sentence || !meaningKo) return null;
  return { sentence, meaningKo };
}

function wordDedupKey(word: string): string {
  return normalizePromptKey(word);
}

function sentenceDedupKey(sentence: string): string {
  return normalizePromptKey(sentence);
}

async function generateDailyWordChunkWithOpenAI(
  targetLanguage: string,
  level: string,
  count: number,
  diversitySeed: string
): Promise<StoredWordItem[]> {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is missing");
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 25000);

  try {
    const systemPrompt = buildDailyWordBatchSystemPrompt(targetLanguage, level, count);
    const userPrompt = buildDailyWordBatchUserPromptJson(
      targetLanguage,
      level,
      count,
      diversitySeed
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
  requiredVocabulary?: string[]
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
      requiredVocabulary
    );
    const userPrompt = buildDailySentenceBatchUserPromptJson(
      targetLanguage,
      level,
      count,
      diversitySeed
      ,
      requiredVocabulary
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

async function buildDailyWordItems(targetLanguage: string, level: string): Promise<StoredWordItem[]> {
  const internalLang = normalizeTargetLanguage(targetLanguage).internal;
  const out: StoredWordItem[] = [];
  const used = new Set<string>();
  const t0 = Date.now();

  // 15 + 15 를 동시에 호출해 순차 3회(10개) 대비 대기 시간을 크게 줄임.
  const parallelSeeds = [
    `words-p0-${t0}-${Math.random().toString(36).slice(2)}`,
    `words-p1-${t0}-${Math.random().toString(36).slice(2)}`,
  ];
  const parallelResults = await Promise.allSettled([
    generateDailyWordChunkWithOpenAI(internalLang, level, DAILY_WORD_BATCH_SIZE, parallelSeeds[0]),
    generateDailyWordChunkWithOpenAI(internalLang, level, DAILY_WORD_BATCH_SIZE, parallelSeeds[1]),
  ]);

  for (let i = 0; i < parallelResults.length; i++) {
    const r = parallelResults[i];
    if (r.status === "fulfilled") {
      mergeWordBatchInto(r.value, out, used);
    } else {
      console.error(`[daily-words] parallel chunk ${i} failed`, r.reason);
    }
  }

  // 중복·실패로 30개 미만이면 한 번 더 (순차)
  if (out.length < DAILY_WORD_COUNT) {
    const need = Math.min(DAILY_WORD_BATCH_SIZE, DAILY_WORD_COUNT - out.length);
    try {
      const batch = await generateDailyWordChunkWithOpenAI(
        internalLang,
        level,
        need,
        `words-topup-${Date.now()}-${Math.random().toString(36).slice(2)}`
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
        });
      }
    } catch {
      const fb = fallbackWord(internalLang, level);
      const fk = `${wordDedupKey(fb.word)}#${out.length}`;
      if (!used.has(fk)) {
        used.add(fk);
        out.push({
          word: fb.word,
          meaningKo: fb.meaningKo,
          ...(fb.example ? { example: fb.example } : {}),
        });
      }
    }
  }
  return out.slice(0, DAILY_WORD_COUNT);
}

async function buildDailySentenceItems(
  targetLanguage: string,
  level: string,
  requiredVocabulary?: string[]
): Promise<StoredSentenceItem[]> {
  const internalLang = normalizeTargetLanguage(targetLanguage).internal;
  try {
    const batch = await generateDailySentenceBatchWithOpenAI(
      internalLang,
      level,
      DAILY_SENTENCE_COUNT,
      `s-${Date.now()}-${Math.random().toString(36).slice(2)}`,
      requiredVocabulary
    );
    const out: StoredSentenceItem[] = [];
    const used = new Set<string>();
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
  const used = new Set<string>();
  let attempts = 0;
  while (out.length < DAILY_SENTENCE_COUNT && attempts < 40) {
    attempts += 1;
    try {
      const one = await generateSentenceWithOpenAI(internalLang, level);
      const key = sentenceDedupKey(one.sentence);
      if (key && !used.has(key)) {
        used.add(key);
        out.push({ sentence: one.sentence, meaningKo: one.meaningKo });
      }
    } catch {
      const fb = fallbackSentence(internalLang, level);
      const fk = `${sentenceDedupKey(fb.sentence)}#${out.length}`;
      if (!used.has(fk)) {
        used.add(fk);
        out.push({ sentence: fb.sentence, meaningKo: fb.meaningKo });
      }
    }
  }
  return out.slice(0, DAILY_SENTENCE_COUNT);
}

function globalTodayWordSetRef(
  targetLanguage: string,
  level: string,
  dateKst?: string
): FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  const ymd = dateKst ?? todayKstYyyyMmDd();
  const tl = normalizeTargetLanguage(targetLanguage);
  const docId = learningSetDocId(ymd, tl.external, level);
  return db
    .collection("users")
    .doc(GLOBAL_LEARNING_SET_OWNER)
    .collection("daily_word_sets")
    .doc(docId);
}

function globalTodaySentenceSetRef(
  targetLanguage: string,
  level: string,
  dateKst?: string
): FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  const ymd = dateKst ?? todayKstYyyyMmDd();
  const tl = normalizeTargetLanguage(targetLanguage);
  const docId = learningSetDocId(ymd, tl.external, level);
  return db
    .collection("users")
    .doc(GLOBAL_LEARNING_SET_OWNER)
    .collection("daily_sentence_sets")
    .doc(docId);
}

/** 스케줄러에서만 호출: 없거나 비어 있으면 AI로 채움. Callable에서는 사용하지 않음. */
async function materializeGlobalTodayWordSetIfAbsent(
  targetLanguage: string,
  level: string,
  dateKst?: string
): Promise<FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>> {
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
      return ref;
    }
  }

  const ymd = dateKst ?? todayKstYyyyMmDd();
  await cleanupExpiredLearningSets(GLOBAL_LEARNING_SET_OWNER, ymd);
  const words = await buildDailyWordItems(canonicalLang, level);
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

  const sentences = await buildDailySentenceItems(canonicalLang, level, vocab.length > 0 ? vocab : undefined);
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
      ...(picked.example ? { example: picked.example } : {}),
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
  const tl = normalizeTargetLanguage((request.data?.targetLanguage ?? "JPN") as string);
  const targetLanguage = tl.external;
  const level = (request.data?.level ?? "beginner") as string;

  console.error(`[generateWord] invoked targetLanguage=${targetLanguage}, level=${level}`);
  try {
    const res = await popWordFromTodaySet(uid, targetLanguage, level);
    console.log(
      `[generateWord] source=${res.debugSource} targetLanguage=${targetLanguage}, level=${level}`
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
  const tl = normalizeTargetLanguage((request.data?.targetLanguage ?? "JPN") as string);
  const targetLanguage = tl.external;
  const level = (request.data?.level ?? "beginner") as string;

  console.error(`[generateSentence] invoked targetLanguage=${targetLanguage}, level=${level}`);
  try {
    const res = await popSentenceFromTodaySet(uid, targetLanguage, level);
    console.log(
      `[generateSentence] source=${res.debugSource} targetLanguage=${targetLanguage}, level=${level}`
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
    const isEmulator = process.env.FUNCTIONS_EMULATOR === "true";
    if (!isEmulator) {
      const allowRaw = (process.env.DEV_WARMUP_UID_ALLOWLIST ?? "").trim();
      const allowed = new Set(
        allowRaw
          .split(",")
          .map((s) => s.trim())
          .filter((s) => s.length > 0)
      );
      if (allowed.size === 0) {
        throw new HttpsError(
          "failed-precondition",
          "DEV_WARMUP_UID_ALLOWLIST is missing"
        );
      }
      if (!allowed.has(request.auth.uid)) {
        throw new HttpsError("permission-denied", "not allowed");
      }
    }

    const targetLanguage = (request.data?.targetLanguage ?? "JPN") as string;
    const level = (request.data?.level ?? "beginner") as string;
    const todayKst = todayKstYyyyMmDd();

    console.log("[ensureTodayLearningSets] start", {
      uid: request.auth.uid,
      todayKst,
      targetLanguage,
      level,
    });
    const t0 = Date.now();
    await materializeGlobalTodayWordSetIfAbsent(targetLanguage, level, todayKst);
    await materializeGlobalTodaySentenceSetIfAbsent(targetLanguage, level, todayKst);
    console.log("[ensureTodayLearningSets] done", {
      todayKst,
      targetLanguage,
      level,
      elapsedMs: Date.now() - t0,
    });

    return { ok: true, dateKst: todayKst };
  }
);

/**
 * 언어/레벨 선택 시 즉시 세트 생성(당일 KST).
 * - 스케줄은 ja/beginner만 미리 생성하므로, 기타 조합은 사용자가 선택하는 순간 생성한다.
 */
export const ensureLearningSetForToday = onCall(
  { region: "asia-northeast3", secrets: ["OPENAI_API_KEY"], timeoutSeconds: 300, memory: "512MiB" },
  async (request): Promise<{ ok: true; dateKst: string; targetLanguage: string; level: string }> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }
    const targetLanguage = (request.data?.targetLanguage ?? "JPN") as string;
    const level = (request.data?.level ?? "beginner") as string;
    const todayKst = todayKstYyyyMmDd();
    console.log("[ensureLearningSetForToday] start", { uid: request.auth.uid, todayKst, targetLanguage, level });
    const t0 = Date.now();
    await materializeGlobalTodayWordSetIfAbsent(targetLanguage, level, todayKst);
    await materializeGlobalTodaySentenceSetIfAbsent(targetLanguage, level, todayKst);
    console.log("[ensureLearningSetForToday] done", { todayKst, targetLanguage, level, elapsedMs: Date.now() - t0 });
    return { ok: true, dateKst: todayKst, targetLanguage, level };
  }
);

// NOTE: 단어 퀴즈(generateQuiz)는 현재 앱 기능에서 제거되어, Functions에서도 노출하지 않습니다.

/** 마무리용 카드만 Firestore에서 읽음(AI·세트 생성 없음). */
export const getWrapUpDeck = onCall({ region: "asia-northeast3" }, async (request): Promise<{ items: WrapUpDeckItem[] }> => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
  }

  const targetLanguage = (request.data?.targetLanguage ?? "JPN") as string;
  const level = (request.data?.level ?? "beginner") as string;

  const wordSnap = await globalTodayWordSetRef(targetLanguage, level).get();
  const sentenceSnap = await globalTodaySentenceSetRef(targetLanguage, level).get();

  const wdata = wordSnap.data() as Partial<DailyWordSet> | undefined;
  const sdata = sentenceSnap.data() as Partial<DailySentenceSet> | undefined;
  const words = Array.isArray(wdata?.words) ? wdata!.words : [];
  const sentences = Array.isArray(sdata?.sentences) ? sdata!.sentences : [];

  // 마무리 출제 정책:
  // - 총 25문제
  // - 단어 70% / 문장 30% (18 / 7)
  const wrapUpWordCount = 18;
  const wrapUpSentenceCount = 7;
  const pickW = shuffle([...words]).slice(0, Math.min(wrapUpWordCount, words.length));
  const pickS = shuffle([...sentences]).slice(0, Math.min(wrapUpSentenceCount, sentences.length));

  const items: WrapUpDeckItem[] = [
    ...pickW.map((w) => ({
      kind: "word" as const,
      meaningKo: w.meaningKo,
      answer: w.word,
    })),
    ...pickS.map((s) => ({
      kind: "sentence" as const,
      meaningKo: s.meaningKo,
      answer: s.sentence,
    })),
  ];
  return { items: shuffle(items) };
});

/**
 * 매일 KST 자정 — (언어, 레벨)별 글로벌 단어 30·문장 10 세트를 AI로 생성·저장.
 * Blaze + Cloud Scheduler 필요. 앱 callable은 이 문서만 읽음.
 */
export const pregenerateDailyLearningSets = onSchedule(
  {
    // KST 23:55에 "내일 자정부터 사용할" 세트를 미리 생성
    schedule: "55 23 * * *",
    timeZone: "Asia/Seoul",
    region: "asia-northeast3",
    secrets: ["OPENAI_API_KEY"],
    timeoutSeconds: 540,
    memory: "512MiB",
  },
  async () => {
    const todayKst = todayKstYyyyMmDd();
    const tomorrowKst = addDaysYyyyMmDd(todayKst, 1);
    console.log("[pregenerateDailyLearningSets] start", { todayKst, tomorrowKst });
    for (const { targetLanguage, level } of PREGEN_LANGUAGE_LEVEL_PAIRS) {
      try {
        await materializeGlobalTodayWordSetIfAbsent(targetLanguage, level, tomorrowKst);
        await materializeGlobalTodaySentenceSetIfAbsent(targetLanguage, level, tomorrowKst);
        console.log("[pregenerateDailyLearningSets] ok", { targetLanguage, level, tomorrowKst });
      } catch (e) {
        console.error("[pregenerateDailyLearningSets] failed", { targetLanguage, level, e });
      }
    }
    console.log("[pregenerateDailyLearningSets] done", { todayKst, tomorrowKst });
  }
);

/**
 * 레거시/미사용 문서 정리(스케줄).
 * - alpha-2 기반 글로벌 학습 세트 문서(예: 2026-04-09_ja_beginner) 삭제
 * - 퀴즈 기능 제거로 더 이상 쓰지 않는 global_quiz_owner 및 글로벌 퀴즈 세트 삭제
 *
 * 주의: 앱/Functions에서 더 이상 참조하지 않는 문서만 대상으로 합니다.
 */
export const cleanupLegacyFirestoreDocs = onSchedule(
  {
    // 매일 KST 03:10에 정리 (트래픽 적은 시간대)
    schedule: "10 3 * * *",
    timeZone: "Asia/Seoul",
    region: "asia-northeast3",
    timeoutSeconds: 540,
    memory: "512MiB",
  },
  async () => {
    const todayKst = todayKstYyyyMmDd();
    console.log("[cleanupLegacyFirestoreDocs] start", { todayKst });

    // 1) 글로벌 퀴즈 오너 + 세트 정리 (현재 앱에서 퀴즈 제거)
    try {
      const ownerRef = db.collection("users").doc(GLOBAL_QUIZ_SET_OWNER);
      const ownerSnap = await ownerRef.get();
      if (ownerSnap.exists) {
        const col = ownerRef.collection("daily_quiz_sets");
        for (;;) {
          const snap = await col.limit(200).get();
          if (snap.empty) break;
          const batch = db.batch();
          for (const d of snap.docs) batch.delete(d.ref);
          await batch.commit();
        }
        await ownerRef.delete();
        console.log("[cleanupLegacyFirestoreDocs] deleted global_quiz_owner");
      }
    } catch (e) {
      console.error("[cleanupLegacyFirestoreDocs] global_quiz_owner cleanup failed", e);
    }

    // 2) alpha-2 기반 글로벌 학습 세트 문서 정리
    // - Functions는 canonical alpha-3 docId만 사용하므로 alpha-2 문서는 미사용.
    const alpha2 = ["ja", "es", "en", "ko"];
    for (const sub of ["daily_word_sets", "daily_sentence_sets"] as const) {
      try {
        const col = db
          .collection("users")
          .doc(GLOBAL_LEARNING_SET_OWNER)
          .collection(sub);

        for (;;) {
          const snap = await col.limit(400).get();
          if (snap.empty) break;

          const batch = db.batch();
          let delCount = 0;

          for (const d of snap.docs) {
            const id = d.id;
            // id 형식: YYYY-MM-DD_LANG_LEVEL
            const lower = id.toLowerCase();
            if (alpha2.some((a2) => lower.includes(`_${a2}_`))) {
              batch.delete(d.ref);
              delCount++;
            }
          }

          if (delCount === 0) break;
          await batch.commit();
          console.log("[cleanupLegacyFirestoreDocs] deleted alpha-2 docs", { sub, delCount });
        }
      } catch (e) {
        console.error("[cleanupLegacyFirestoreDocs] alpha-2 cleanup failed", { sub, e });
      }
    }

    console.log("[cleanupLegacyFirestoreDocs] done", { todayKst });
  }
);
