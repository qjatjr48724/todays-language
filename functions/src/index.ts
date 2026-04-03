import { onCall, HttpsError } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as admin from "firebase-admin";

import {
  buildDailySentenceBatchSystemPrompt,
  buildDailySentenceBatchUserPromptJson,
  buildDailyWordBatchSystemPrompt,
  buildDailyWordBatchUserPromptJson,
  buildQuizSystemPrompt,
  buildQuizUserPromptJson,
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

type GenerateQuizResponse = {
  promptKo: string;
  choices: string[];
  answerIndex: number;
};

type StoredQuizItem = GenerateQuizResponse & {
  source: "new" | "review";
  createdAtMs: number;
};

type DailyQuizSet = {
  dateKst: string;
  targetLanguage: string;
  level: string;
  items: StoredQuizItem[];
  cursor: number;
  retentionDays: number;
  reviewRatio: number;
  updatedAtMs: number;
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

type OpenAiQuizResponse = {
  quizType: QuizMode;
  promptKo: string;
  choices: string[];
  answerIndex: number;
};

const OPENAI_API_URL = "https://api.openai.com/v1/responses";
const OPENAI_MODEL = process.env.OPENAI_MODEL ?? "gpt-4.1-mini";
const DAILY_QUIZ_COUNT = 10;
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
  { targetLanguage: "ja", level: "beginner" },
  { targetLanguage: "es", level: "beginner" },
];
const QUIZ_MODES = [
  "ko_to_target_word",
  "target_to_ko_meaning",
  "simple_context_choice",
  "fill_in_blank_word",
] as const;

type QuizMode = (typeof QUIZ_MODES)[number];

admin.initializeApp();
const db = admin.firestore();

function pickQuizMode(): QuizMode {
  const i = Math.floor(Math.random() * QUIZ_MODES.length);
  return QUIZ_MODES[i];
}

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

function normalizeChoiceKey(text: string): string {
  return text
    .toLowerCase()
    .replace(/\s+/g, "")
    .replace(/[^\p{L}\p{N}]/gu, "");
}

function quizUniqueKey(quiz: GenerateQuizResponse): string {
  const prompt = normalizePromptKey(quiz.promptKo);
  const choices = quiz.choices.map((c) => normalizeChoiceKey(c)).join("|");
  return `${prompt}::${choices}`;
}

function pickReviewRatioByYesterday(quizDone: number, quizGoal: number): number {
  if (quizGoal <= 0) return 0.3;
  const completionRate = (quizDone / quizGoal) * 100;
  if (completionRate < 30) return 0.5;
  if (completionRate < 70) return 0.3;
  return 0.2;
}

async function cleanupExpiredDailySets(uid: string, todayKst: string): Promise<void> {
  const deleteBefore = addDaysYyyyMmDd(todayKst, -(DEFAULT_RETENTION_DAYS + 1));
  const col = db.collection("users").doc(uid).collection("daily_quiz_sets");
  const snap = await col.where("dateKst", "<=", deleteBefore).limit(20).get();
  if (snap.empty) return;
  const batch = db.batch();
  for (const doc of snap.docs) {
    batch.delete(doc.ref);
  }
  await batch.commit();
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

async function getYesterdayReviewRatio(uid: string, todayKst: string): Promise<number> {
  if (uid === GLOBAL_QUIZ_SET_OWNER) {
    return 0.3;
  }
  const yesterday = addDaysYyyyMmDd(todayKst, -1);
  const ref = db.collection("users").doc(uid).collection("daily_progress").doc(yesterday);
  const snap = await ref.get();
  const data = snap.data() ?? {};
  const quizDone = Number(data.quizDone ?? 0);
  const quizGoal = Number(data.quizGoal ?? 20);
  return pickReviewRatioByYesterday(quizDone, quizGoal);
}

async function getRecentReviewPool(
  uid: string,
  todayKst: string,
  targetLanguage: string,
  level: string
): Promise<StoredQuizItem[]> {
  const fromDate = addDaysYyyyMmDd(todayKst, -DEFAULT_RETENTION_DAYS);
  const col = db.collection("users").doc(uid).collection("daily_quiz_sets");
  const snap = await col
    .where("dateKst", ">=", fromDate)
    .where("dateKst", "<", todayKst)
    .limit(50)
    .get();

  const pooled: StoredQuizItem[] = [];
  for (const doc of snap.docs) {
    const data = doc.data() as Partial<DailyQuizSet>;
    if (data.targetLanguage !== targetLanguage || data.level !== level) {
      continue;
    }
    const items = Array.isArray(data.items) ? data.items : [];
    for (const raw of items) {
      if (!raw) continue;
      pooled.push({
        promptKo: String((raw as Partial<StoredQuizItem>).promptKo ?? ""),
        choices: Array.isArray((raw as Partial<StoredQuizItem>).choices)
          ? (raw as Partial<StoredQuizItem>).choices!.map((v) => String(v))
          : [],
        answerIndex: Number((raw as Partial<StoredQuizItem>).answerIndex ?? 0),
        source: "review",
        createdAtMs: Number((raw as Partial<StoredQuizItem>).createdAtMs ?? Date.now()),
      });
    }
  }

  return pooled.filter((q) => q.promptKo && q.choices.length === 4 && q.answerIndex >= 0 && q.answerIndex <= 3);
}

async function buildDailyQuizItems(
  uid: string,
  todayKst: string,
  targetLanguage: string,
  level: string
): Promise<{ items: StoredQuizItem[]; reviewRatio: number }> {
  const reviewRatio = await getYesterdayReviewRatio(uid, todayKst);
  const reviewTargetCount = Math.min(
    DAILY_QUIZ_COUNT - 1,
    Math.floor(DAILY_QUIZ_COUNT * reviewRatio)
  );

  const reviewPool = await getRecentReviewPool(uid, todayKst, targetLanguage, level);
  const reviewItems: StoredQuizItem[] = [];
  const usedKeys = new Set<string>();
  for (const q of shuffle(reviewPool)) {
    const key = quizUniqueKey(q);
    if (!key || usedKeys.has(key)) continue;
    usedKeys.add(key);
    reviewItems.push({
      ...q,
      source: "review" as const,
    });
    if (reviewItems.length >= reviewTargetCount) break;
  }

  const needNew = DAILY_QUIZ_COUNT - reviewItems.length;
  const newItems: StoredQuizItem[] = [];
  let attempts = 0;
  while (newItems.length < needNew && attempts < needNew * 5) {
    attempts += 1;
    try {
      const generated = await generateQuizWithOpenAI(targetLanguage, level);
      const key = quizUniqueKey(generated);
      if (!key || usedKeys.has(key)) {
        continue;
      }
      usedKeys.add(key);
      newItems.push({
        ...generated,
        source: "new",
        createdAtMs: Date.now(),
      });
    } catch (e) {
      console.error("[daily-quiz] AI generation failed, using fallback item.", e);
      const fallback = fallbackQuiz(targetLanguage, level);
      const key = quizUniqueKey(fallback);
      if (!key || usedKeys.has(key)) {
        continue;
      }
      usedKeys.add(key);
      newItems.push({
        ...fallback,
        source: "new",
        createdAtMs: Date.now(),
      });
    }
  }

  while (newItems.length < needNew) {
    const f = fallbackQuiz(targetLanguage, level);
    const key = quizUniqueKey(f);
    if (!key || usedKeys.has(key)) break;
    usedKeys.add(key);
    newItems.push({
      ...f,
      source: "new",
      createdAtMs: Date.now(),
    });
  }

  return {
    items: shuffle([...reviewItems, ...newItems]),
    reviewRatio,
  };
}

async function getOrCreateTodaySet(
  uid: string,
  targetLanguage: string,
  level: string
): Promise<FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>> {
  const todayKst = todayKstYyyyMmDd();
  const ownerRef = db.collection("users").doc(uid);
  await ownerRef.set(
    {
      kind: "global_quiz_owner",
      updatedAtMs: Date.now(),
    },
    { merge: true }
  );
  const ref = db.collection("users").doc(uid).collection("daily_quiz_sets").doc(todayKst);
  const snap = await ref.get();
  if (snap.exists) return ref;

  await cleanupExpiredDailySets(uid, todayKst);
  const { items, reviewRatio } = await buildDailyQuizItems(uid, todayKst, targetLanguage, level);

  const payload: DailyQuizSet = {
    dateKst: todayKst,
    targetLanguage,
    level,
    items,
    cursor: 0,
    retentionDays: DEFAULT_RETENTION_DAYS,
    reviewRatio,
    updatedAtMs: Date.now(),
  };
  await ref.set(payload, { merge: true });
  return ref;
}

async function popQuizFromTodaySet(
  uid: string,
  targetLanguage: string,
  level: string
): Promise<GenerateQuizResponse> {
  const todayKst = todayKstYyyyMmDd();
  const setRef = await getOrCreateTodaySet(
    GLOBAL_QUIZ_SET_OWNER,
    targetLanguage,
    level
  );
  const cursorRef = db
    .collection("users")
    .doc(uid)
    .collection("daily_quiz_cursor")
    .doc(`${todayKst}_${targetLanguage}_${level}`);

  return db.runTransaction(async (tx) => {
    const setSnap = await tx.get(setRef);
    const cursorSnap = await tx.get(cursorRef);
    const data = (setSnap.data() ?? {}) as Partial<DailyQuizSet>;
    const cursorData = cursorSnap.data() ?? {};
    const items = (Array.isArray(data.items) ? data.items : []) as StoredQuizItem[];
    if (items.length === 0) {
      return fallbackQuiz(targetLanguage, level);
    }
    const cursor = Number(cursorData.cursor ?? 0);
    const index = ((cursor % items.length) + items.length) % items.length;
    const picked = items[index];
    console.log("[generateQuiz] cursor resolved", {
      uid,
      dateKst: todayKst,
      targetLanguage,
      level,
      cursorBefore: cursor,
      index,
      cursorDocId: `${todayKst}_${targetLanguage}_${level}`,
    });
    tx.set(cursorRef, {
      dateKst: todayKst,
      targetLanguage,
      level,
      cursor: cursor + 1,
      updatedAtMs: Date.now(),
    }, { merge: true });
    return {
      promptKo: picked.promptKo,
      choices: picked.choices,
      answerIndex: picked.answerIndex,
    };
  });
}

function fallbackTemplates(targetLanguage: string, level: string): GenerateQuizResponse[] {
  if (targetLanguage === "ja" && level === "beginner") {
    return [
      { promptKo: "다음 중 '고마워요'에 해당하는 일본어는?", choices: ["こんにちは", "ありがとう", "さようなら", "すみません"], answerIndex: 1 },
      { promptKo: "다음 중 일본어 'おはよう'의 뜻은?", choices: ["안녕하세요(낮)", "안녕히 가세요", "좋은 아침", "고마워요"], answerIndex: 2 },
      { promptKo: "빈칸에 들어갈 가장 자연스러운 표현은? '_____、たすかりました。'", choices: ["ありがとう", "こんばんは", "いただきます", "おやすみ"], answerIndex: 0 },
      { promptKo: "상황: 실수로 부딪힌 뒤 먼저 할 말로 가장 적절한 일본어는?", choices: ["すみません", "じゃあね", "おめでとう", "ただいま"], answerIndex: 0 },
      { promptKo: "다음 중 '안녕하세요(낮 인사)'에 해당하는 일본어는?", choices: ["こんにちは", "おやすみ", "ありがとう", "ごめん"], answerIndex: 0 },
      { promptKo: "다음 중 일본어 'さようなら'의 뜻은?", choices: ["잘 자요", "안녕히 가세요", "축하해요", "미안합니다"], answerIndex: 1 },
      { promptKo: "빈칸에 들어갈 표현은? 'あさは _____ を いいます。'", choices: ["おはよう", "こんにちは", "ありがとう", "すみません"], answerIndex: 0 },
      { promptKo: "다음 중 '미안합니다/실례합니다' 의미로 가장 적절한 일본어는?", choices: ["すみません", "ただいま", "おめでとう", "いただきます"], answerIndex: 0 },
      { promptKo: "일본어 'こんばんは'의 뜻으로 맞는 것은?", choices: ["좋은 아침", "안녕하세요(밤)", "안녕히 주무세요", "다녀왔습니다"], answerIndex: 1 },
      { promptKo: "빈칸에 알맞은 말은? 'ねるまえに _____ と いいます。'", choices: ["おはよう", "こんばんは", "おやすみ", "ありがとう"], answerIndex: 2 },
      { promptKo: "다음 중 축하할 때 쓰는 일본어는?", choices: ["おめでとう", "すみません", "さようなら", "こんにちは"], answerIndex: 0 },
      { promptKo: "일본어 'ただいま'의 의미로 가장 알맞은 것은?", choices: ["다녀왔습니다", "잘 부탁합니다", "잘 자요", "괜찮아요"], answerIndex: 0 },
    ];
  }

  if (targetLanguage === "es" && level === "beginner") {
    return [
      { promptKo: "다음 중 '안녕'에 해당하는 스페인어는?", choices: ["adiós", "gracias", "hola", "por favor"], answerIndex: 2 },
      { promptKo: "스페인어 'gracias'의 뜻은?", choices: ["고마워요", "미안해요", "안녕", "좋은 밤"], answerIndex: 0 },
      { promptKo: "다음 중 '부탁합니다'에 해당하는 스페인어는?", choices: ["hola", "por favor", "adiós", "gracias"], answerIndex: 1 },
      { promptKo: "스페인어 'adiós'의 뜻은?", choices: ["안녕(만날 때)", "고마워", "안녕히 가세요", "천만에요"], answerIndex: 2 },
      { promptKo: "빈칸 채우기: '_____ , ¿cómo estás?'", choices: ["hola", "adiós", "gracias", "perdón"], answerIndex: 0 },
      { promptKo: "다음 중 '미안합니다'에 가까운 스페인어는?", choices: ["perdón", "hola", "gracias", "mañana"], answerIndex: 0 },
    ];
  }

  return [
    { promptKo: "다음 중 '안녕'에 해당하는 표현은?", choices: ["goodbye", "hello", "thanks", "sorry"], answerIndex: 1 },
    { promptKo: "다음 중 '고마워요'에 해당하는 표현은?", choices: ["thanks", "bye", "please", "hello"], answerIndex: 0 },
    { promptKo: "다음 중 '미안해요'에 해당하는 표현은?", choices: ["sorry", "hello", "thanks", "bye"], answerIndex: 0 },
  ];
}

function fallbackQuiz(targetLanguage: string, level: string): GenerateQuizResponse {
  const templates = fallbackTemplates(targetLanguage, level);
  return templates[Math.floor(Math.random() * templates.length)];
}

function fallbackWord(targetLanguage: string, level: string): GenerateWordResponse {
  if (targetLanguage === "ja" && level === "beginner") {
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
  if (targetLanguage === "ja" && level === "beginner") {
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

function isValidQuizPayload(value: unknown): value is OpenAiQuizResponse {
  if (typeof value !== "object" || value === null) return false;
  const v = value as Partial<OpenAiQuizResponse>;
  if (!v.quizType || !QUIZ_MODES.includes(v.quizType)) return false;
  if (typeof v.promptKo !== "string" || v.promptKo.trim().length === 0) return false;
  if (!Array.isArray(v.choices) || v.choices.length !== 4) return false;
  if (v.choices.some((c) => typeof c !== "string" || c.trim().length === 0)) return false;
  if (typeof v.answerIndex !== "number") return false;
  if (!Number.isInteger(v.answerIndex) || v.answerIndex < 0 || v.answerIndex > 3) return false;
  return true;
}

async function generateQuizWithOpenAI(
  targetLanguage: string,
  level: string
): Promise<GenerateQuizResponse> {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is missing");
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 12000);

  try {
    const quizMode = pickQuizMode();
    const systemPrompt = buildQuizSystemPrompt(quizMode);
    const userPrompt = buildQuizUserPromptJson(targetLanguage, level, quizMode);

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

    const parsed = JSON.parse(outputText) as unknown;
    if (!isValidQuizPayload(parsed)) {
      throw new Error("OpenAI response JSON schema mismatch");
    }
    if (parsed.quizType !== quizMode) {
      throw new Error(`OpenAI response quizType mismatch. expected=${quizMode}, got=${parsed.quizType}`);
    }

    return {
      promptKo: parsed.promptKo.trim(),
      choices: parsed.choices.map((c) => c.trim()),
      answerIndex: parsed.answerIndex,
    };
  } finally {
    clearTimeout(timeout);
  }
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
  diversitySeed: string
): Promise<StoredSentenceItem[]> {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is missing");
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 25000);

  try {
    const systemPrompt = buildDailySentenceBatchSystemPrompt(targetLanguage, level, count);
    const userPrompt = buildDailySentenceBatchUserPromptJson(
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
  const out: StoredWordItem[] = [];
  const used = new Set<string>();
  const t0 = Date.now();

  // 15 + 15 를 동시에 호출해 순차 3회(10개) 대비 대기 시간을 크게 줄임.
  const parallelSeeds = [
    `words-p0-${t0}-${Math.random().toString(36).slice(2)}`,
    `words-p1-${t0}-${Math.random().toString(36).slice(2)}`,
  ];
  const parallelResults = await Promise.allSettled([
    generateDailyWordChunkWithOpenAI(targetLanguage, level, DAILY_WORD_BATCH_SIZE, parallelSeeds[0]),
    generateDailyWordChunkWithOpenAI(targetLanguage, level, DAILY_WORD_BATCH_SIZE, parallelSeeds[1]),
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
        targetLanguage,
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
      const one = await generateWordWithOpenAI(targetLanguage, level);
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
      const fb = fallbackWord(targetLanguage, level);
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
  level: string
): Promise<StoredSentenceItem[]> {
  try {
    const batch = await generateDailySentenceBatchWithOpenAI(
      targetLanguage,
      level,
      DAILY_SENTENCE_COUNT,
      `s-${Date.now()}-${Math.random().toString(36).slice(2)}`
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
      const one = await generateSentenceWithOpenAI(targetLanguage, level);
      const key = sentenceDedupKey(one.sentence);
      if (key && !used.has(key)) {
        used.add(key);
        out.push({ sentence: one.sentence, meaningKo: one.meaningKo });
      }
    } catch {
      const fb = fallbackSentence(targetLanguage, level);
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
  level: string
): FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  const todayKst = todayKstYyyyMmDd();
  const docId = learningSetDocId(todayKst, targetLanguage, level);
  return db
    .collection("users")
    .doc(GLOBAL_LEARNING_SET_OWNER)
    .collection("daily_word_sets")
    .doc(docId);
}

function globalTodaySentenceSetRef(
  targetLanguage: string,
  level: string
): FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData> {
  const todayKst = todayKstYyyyMmDd();
  const docId = learningSetDocId(todayKst, targetLanguage, level);
  return db
    .collection("users")
    .doc(GLOBAL_LEARNING_SET_OWNER)
    .collection("daily_sentence_sets")
    .doc(docId);
}

/** 스케줄러에서만 호출: 없거나 비어 있으면 AI로 채움. Callable에서는 사용하지 않음. */
async function materializeGlobalTodayWordSetIfAbsent(
  targetLanguage: string,
  level: string
): Promise<FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>> {
  const ref = globalTodayWordSetRef(targetLanguage, level);
  const snap = await ref.get();
  if (snap.exists) {
    const data = snap.data() as Partial<DailyWordSet>;
    if (
      data.targetLanguage === targetLanguage &&
      data.level === level &&
      Array.isArray(data.words) &&
      data.words.length > 0
    ) {
      return ref;
    }
  }

  const todayKst = todayKstYyyyMmDd();
  await cleanupExpiredLearningSets(GLOBAL_LEARNING_SET_OWNER, todayKst);
  const words = await buildDailyWordItems(targetLanguage, level);
  const payload: DailyWordSet = {
    dateKst: todayKst,
    targetLanguage,
    level,
    words,
    cursor: 0,
    updatedAtMs: Date.now(),
  };
  await ref.set(payload);
  return ref;
}

/** 스케줄러에서만 호출: 없거나 비어 있으면 AI로 채움. Callable에서는 사용하지 않음. */
async function materializeGlobalTodaySentenceSetIfAbsent(
  targetLanguage: string,
  level: string
): Promise<FirebaseFirestore.DocumentReference<FirebaseFirestore.DocumentData>> {
  const ref = globalTodaySentenceSetRef(targetLanguage, level);
  const snap = await ref.get();
  if (snap.exists) {
    const data = snap.data() as Partial<DailySentenceSet>;
    if (
      data.targetLanguage === targetLanguage &&
      data.level === level &&
      Array.isArray(data.sentences) &&
      data.sentences.length > 0
    ) {
      return ref;
    }
  }

  const todayKst = todayKstYyyyMmDd();
  await cleanupExpiredLearningSets(GLOBAL_LEARNING_SET_OWNER, todayKst);
  const sentences = await buildDailySentenceItems(targetLanguage, level);
  const payload: DailySentenceSet = {
    dateKst: todayKst,
    targetLanguage,
    level,
    sentences,
    cursor: 0,
    updatedAtMs: Date.now(),
  };
  await ref.set(payload);
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
  const targetLanguage = (request.data?.targetLanguage ?? "ja") as string;
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
  const targetLanguage = (request.data?.targetLanguage ?? "ja") as string;
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

export const generateQuiz = onCall(
  { region: "asia-northeast3", secrets: ["OPENAI_API_KEY"] },
  async (request): Promise<GenerateQuizResponse> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const uid = request.auth.uid;
    const targetLanguage = (request.data?.targetLanguage ?? "ja") as string;
    const level = (request.data?.level ?? "beginner") as string;
    try {
      return await popQuizFromTodaySet(uid, targetLanguage, level);
    } catch (e) {
      console.error("[generateQuiz] Daily set flow failed. Fallback is used.", e);
      return fallbackQuiz(targetLanguage, level);
    }
  }
);

/** 마무리용 카드만 Firestore에서 읽음(AI·세트 생성 없음). */
export const getWrapUpDeck = onCall({ region: "asia-northeast3" }, async (request): Promise<{ items: WrapUpDeckItem[] }> => {
  if (!request.auth) {
    throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
  }

  const targetLanguage = (request.data?.targetLanguage ?? "ja") as string;
  const level = (request.data?.level ?? "beginner") as string;

  const wordSnap = await globalTodayWordSetRef(targetLanguage, level).get();
  const sentenceSnap = await globalTodaySentenceSetRef(targetLanguage, level).get();

  const wdata = wordSnap.data() as Partial<DailyWordSet> | undefined;
  const sdata = sentenceSnap.data() as Partial<DailySentenceSet> | undefined;
  const words = Array.isArray(wdata?.words) ? wdata!.words : [];
  const sentences = Array.isArray(sdata?.sentences) ? sdata!.sentences : [];

  const pickW = shuffle([...words]).slice(0, Math.min(20, words.length));
  const pickS = shuffle([...sentences]).slice(0, Math.min(5, sentences.length));

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
    schedule: "0 0 * * *",
    timeZone: "Asia/Seoul",
    region: "asia-northeast3",
    secrets: ["OPENAI_API_KEY"],
    timeoutSeconds: 540,
    memory: "512MiB",
  },
  async () => {
    const todayKst = todayKstYyyyMmDd();
    console.log("[pregenerateDailyLearningSets] start", { todayKst });
    for (const { targetLanguage, level } of PREGEN_LANGUAGE_LEVEL_PAIRS) {
      try {
        await materializeGlobalTodayWordSetIfAbsent(targetLanguage, level);
        await materializeGlobalTodaySentenceSetIfAbsent(targetLanguage, level);
        console.log("[pregenerateDailyLearningSets] ok", { targetLanguage, level });
      } catch (e) {
        console.error("[pregenerateDailyLearningSets] failed", { targetLanguage, level, e });
      }
    }
    console.log("[pregenerateDailyLearningSets] done", { todayKst });
  }
);
