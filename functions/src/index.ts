import { onCall, HttpsError } from "firebase-functions/v2/https";
import * as admin from "firebase-admin";

type GenerateWordResponse = {
  word: string;
  meaningKo: string;
  example?: string;
};

type GenerateSentenceResponse = {
  sentence: string;
  meaningKo: string;
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

type OpenAiQuizResponse = {
  quizType: QuizMode;
  promptKo: string;
  choices: string[];
  answerIndex: number;
};

const OPENAI_API_URL = "https://api.openai.com/v1/responses";
const OPENAI_MODEL = process.env.OPENAI_MODEL ?? "gpt-4.1-mini";
const DAILY_QUIZ_COUNT = 10;
const DEFAULT_RETENTION_DAYS = 7;
const GLOBAL_QUIZ_SET_OWNER = "__global__";
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
  const reviewItems = shuffle(reviewPool).slice(0, reviewTargetCount).map((q) => ({
    ...q,
    source: "review" as const,
  }));

  const blockedPromptKeys = new Set(
    reviewPool.map((q) => normalizePromptKey(q.promptKo))
  );
  for (const r of reviewItems) {
    blockedPromptKeys.add(normalizePromptKey(r.promptKo));
  }

  const needNew = DAILY_QUIZ_COUNT - reviewItems.length;
  const newItems: StoredQuizItem[] = [];
  let attempts = 0;
  while (newItems.length < needNew && attempts < needNew * 5) {
    attempts += 1;
    try {
      const generated = await generateQuizWithOpenAI(targetLanguage, level);
      const key = normalizePromptKey(generated.promptKo);
      if (!key || blockedPromptKeys.has(key)) {
        continue;
      }
      blockedPromptKeys.add(key);
      newItems.push({
        ...generated,
        source: "new",
        createdAtMs: Date.now(),
      });
    } catch (e) {
      console.error("[daily-quiz] AI generation failed, using fallback item.", e);
      newItems.push({
        ...fallbackQuiz(targetLanguage, level),
        source: "new",
        createdAtMs: Date.now(),
      });
    }
  }

  while (newItems.length < needNew) {
    const f = fallbackQuiz(targetLanguage, level);
    const key = normalizePromptKey(f.promptKo);
    if (!key || blockedPromptKeys.has(key)) break;
    blockedPromptKeys.add(key);
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
  const ref = await getOrCreateTodaySet(uid, targetLanguage, level);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const data = (snap.data() ?? {}) as Partial<DailyQuizSet>;
    const items = (Array.isArray(data.items) ? data.items : []) as StoredQuizItem[];
    if (items.length === 0) {
      return fallbackQuiz(targetLanguage, level);
    }
    const cursor = Number(data.cursor ?? 0);
    const index = ((cursor % items.length) + items.length) % items.length;
    const picked = items[index];
    tx.set(
      ref,
      { cursor: cursor + 1, updatedAtMs: Date.now() },
      { merge: true }
    );
    return {
      promptKo: picked.promptKo,
      choices: picked.choices,
      answerIndex: picked.answerIndex,
    };
  });
}

function fallbackQuiz(targetLanguage: string, level: string): GenerateQuizResponse {
  if (targetLanguage === "ja" && level === "beginner") {
    const templates: GenerateQuizResponse[] = [
      {
        promptKo: "다음 중 '고마워요'에 해당하는 일본어는?",
        choices: ["こんにちは", "ありがとう", "さようなら", "すみません"],
        answerIndex: 1,
      },
      {
        promptKo: "다음 중 일본어 'おはよう'의 뜻은?",
        choices: ["안녕하세요(낮)", "안녕히 가세요", "좋은 아침", "고마워요"],
        answerIndex: 2,
      },
      {
        promptKo: "빈칸에 들어갈 가장 자연스러운 표현은? '_____、たすかりました。'",
        choices: ["ありがとう", "こんばんは", "いただきます", "おやすみ"],
        answerIndex: 0,
      },
      {
        promptKo: "상황: 실수로 부딪힌 뒤 먼저 할 말로 가장 적절한 일본어는?",
        choices: ["すみません", "じゃあね", "おめでとう", "ただいま"],
        answerIndex: 0,
      },
    ];
    return templates[Math.floor(Math.random() * templates.length)];
  }

  if (targetLanguage === "es" && level === "beginner") {
    const templates: GenerateQuizResponse[] = [
      {
        promptKo: "다음 중 '안녕'에 해당하는 스페인어는?",
        choices: ["adiós", "gracias", "hola", "por favor"],
        answerIndex: 2,
      },
      {
        promptKo: "스페인어 'gracias'의 뜻은?",
        choices: ["고마워요", "미안해요", "안녕", "좋은 밤"],
        answerIndex: 0,
      },
    ];
    return templates[Math.floor(Math.random() * templates.length)];
  }

  const genericTemplates: GenerateQuizResponse[] = [
    {
      promptKo: "다음 중 '안녕'에 해당하는 표현은?",
      choices: ["goodbye", "hello", "thanks", "sorry"],
      answerIndex: 1,
    },
    {
      promptKo: "다음 중 '고마워요'에 해당하는 표현은?",
      choices: ["thanks", "bye", "please", "hello"],
      answerIndex: 0,
    },
  ];
  return genericTemplates[Math.floor(Math.random() * genericTemplates.length)];
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
    const systemPrompt = [
      "You generate beginner language quiz questions for a Korean learner.",
      `Use quiz mode: ${quizMode}.`,
      "Mode meaning:",
      "- ko_to_target_word: Korean meaning is given, choose target-language word.",
      "- target_to_ko_meaning: target-language word/sentence is given, choose Korean meaning.",
      "- simple_context_choice: simple short context and choose fitting expression.",
      "- fill_in_blank_word: very short sentence with one blank, choose best word.",
      "Return ONLY a compact JSON object with fields:",
      "quizType (must exactly equal requested mode), promptKo (string), choices (array of exactly 4 strings), answerIndex (0..3 integer).",
      "No markdown. No extra keys.",
      "For Japanese beginner content, prefer easy expressions.",
    ].join(" ");

    const userPrompt = JSON.stringify({
      targetLanguage,
      level,
      quizType: quizMode,
      learnerNativeLanguage: "ko",
      constraints: {
        choicesCount: 4,
        singleCorrectAnswer: true,
      },
    });

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

    const data = (await response.json()) as { output_text?: string };
    const outputText = (data.output_text ?? "").trim();
    if (!outputText) {
      throw new Error("OpenAI response had no output_text");
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

/**
 * 앱에서만 호출 (인증 필수). 초기에는 고정 응답으로 플로우 검증.
 * 실제 AI 연동 시 이 함수 내부에서만 외부 API 호출.
 */
export const generateWord = onCall(
  { region: "asia-northeast3" },
  async (request): Promise<GenerateWordResponse> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const targetLanguage = (request.data?.targetLanguage ?? "ja") as string;
    const level = (request.data?.level ?? "beginner") as string;

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
);

export const generateSentence = onCall(
  { region: "asia-northeast3" },
  async (request): Promise<GenerateSentenceResponse> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const targetLanguage = (request.data?.targetLanguage ?? "ja") as string;
    const level = (request.data?.level ?? "beginner") as string;

    if (targetLanguage === "ja" && level === "beginner") {
      return {
        // 초기 버전: 일본어는 히라가나만 노출(한자/가타카나 지양)
        sentence: "きょうはいいてんきですね。",
        meaningKo: "오늘은 날씨가 좋네요.",
      };
    }

    return {
      sentence: "Hoy hace buen tiempo.",
      meaningKo: "오늘 날씨가 좋아요.",
    };
  }
);

export const generateQuiz = onCall(
  { region: "asia-northeast3", secrets: ["OPENAI_API_KEY"] },
  async (request): Promise<GenerateQuizResponse> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const targetLanguage = (request.data?.targetLanguage ?? "ja") as string;
    const level = (request.data?.level ?? "beginner") as string;
    try {
      return await popQuizFromTodaySet(GLOBAL_QUIZ_SET_OWNER, targetLanguage, level);
    } catch (e) {
      console.error("[generateQuiz] Daily set flow failed. Fallback is used.", e);
      return fallbackQuiz(targetLanguage, level);
    }
  }
);
