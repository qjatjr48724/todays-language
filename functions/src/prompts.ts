/**
 * OpenAI 시스템/유저 프롬프트 정의.
 * 운영 변경 시 Functions 배포로 반영 (Remote Config 미사용).
 */

function languageLabel(code: string): string {
  switch (code) {
    case "ja":
      return "Japanese";
    case "es":
      return "Spanish";
    case "en":
      return "English";
    default:
      return code;
  }
}

/** 퀴즈: 시스템 메시지 (quizMode는 QUIZ_MODES 중 하나) */
export function buildQuizSystemPrompt(quizMode: string): string {
  return [
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
}

export function buildQuizUserPromptJson(
  targetLanguage: string,
  level: string,
  quizMode: string
): string {
  return JSON.stringify({
    targetLanguage,
    level,
    quizType: quizMode,
    learnerNativeLanguage: "ko",
    constraints: {
      choicesCount: 4,
      singleCorrectAnswer: true,
    },
  });
}

export function buildWordSystemPrompt(targetLanguage: string, level: string): string {
  const lang = languageLabel(targetLanguage);
  return [
    `You pick one practical vocabulary item in ${lang} for a Korean native speaker learning that language.`,
    `Learner level: ${level}.`,
    "Return ONLY a raw JSON object (no markdown, no extra text).",
    "Required keys: word, meaningKo.",
    "If targetLanguage is ja and the word includes kanji, also include readingHira (the same word written in hiragana only, for confirmation).",
    "Optional key: example (string).",
    "If targetLanguage is ja and level is beginner, prefer hiragana for word and example; avoid kanji unless necessary.",
  ].join(" ");
}

export function buildWordUserPromptJson(
  targetLanguage: string,
  level: string,
  diversitySeed: string
): string {
  return JSON.stringify({
    targetLanguage,
    level,
    learnerNativeLanguage: "ko",
    diversitySeed,
  });
}

export function buildSentenceSystemPrompt(targetLanguage: string, level: string): string {
  const lang = languageLabel(targetLanguage);
  return [
    `You write one short, useful sentence in ${lang} for a Korean native speaker at level ${level}.`,
    "Keep it natural and suitable for daily conversation or study.",
    "Return ONLY a raw JSON object (no markdown, no extra text).",
    "Required keys: sentence, meaningKo.",
    "If targetLanguage is ja and the sentence includes kanji, also include sentenceHira (the same sentence written in hiragana only, for confirmation).",
    "If targetLanguage is ja and level is beginner, use hiragana only where possible; avoid kanji and katakana except proper nouns if unavoidable.",
  ].join(" ");
}

export function buildSentenceUserPromptJson(
  targetLanguage: string,
  level: string,
  diversitySeed: string
): string {
  return JSON.stringify({
    targetLanguage,
    level,
    learnerNativeLanguage: "ko",
    diversitySeed,
  });
}

/** 일일 단어 세트: 한 번에 N개 (보통 10개씩 끊어 30개 구성) */
export function buildDailyWordBatchSystemPrompt(
  targetLanguage: string,
  level: string,
  count: number
): string {
  const lang = languageLabel(targetLanguage);
  return [
    `You create exactly ${count} distinct practical vocabulary items in ${lang} for a Korean native speaker learning that language.`,
    `Learner level: ${level}.`,
    "Every item must use a different headword (no duplicates, no near-duplicates).",
    "Return ONLY a raw JSON object (no markdown, no extra text).",
    "Shape: {\"words\":[{\"word\":string,\"meaningKo\":string,\"example\":string?,\"readingHira\":string?}, ...]}",
    `The \"words\" array MUST have length exactly ${count}.`,
    "If targetLanguage is ja and level is beginner, prefer hiragana for word and example; avoid kanji unless necessary.",
    "If targetLanguage is ja and a word includes kanji, include readingHira for that item (hiragana only).",
  ].join(" ");
}

export function buildDailyWordBatchUserPromptJson(
  targetLanguage: string,
  level: string,
  count: number,
  diversitySeed: string
): string {
  return JSON.stringify({
    targetLanguage,
    level,
    learnerNativeLanguage: "ko",
    batchSize: count,
    diversitySeed,
  });
}

/** 일일 문장 세트: 하루 목표 개수(예: 10) 한 번에 생성 */
export function buildDailySentenceBatchSystemPrompt(
  targetLanguage: string,
  level: string,
  count: number,
  requiredVocabulary?: string[]
): string {
  const lang = languageLabel(targetLanguage);
  const vocabLine =
    requiredVocabulary && requiredVocabulary.length > 0
        ? `You MUST use the provided vocabulary list. Each sentence must include exactly one of the provided words/expressions, and do not reuse the same vocabulary across sentences.`
        : "";
  return [
    `You create exactly ${count} distinct short sentences in ${lang} for a Korean native speaker at level ${level}.`,
    "Each sentence must be unique and useful for daily study.",
    vocabLine,
    "Return ONLY a raw JSON object (no markdown, no extra text).",
    "Shape: {\"sentences\":[{\"sentence\":string,\"meaningKo\":string,\"sentenceHira\":string?}, ...]}",
    `The \"sentences\" array MUST have length exactly ${count}.`,
    "If targetLanguage is ja and level is beginner, use hiragana only where possible; avoid kanji and katakana except proper nouns if unavoidable.",
    "If targetLanguage is ja and a sentence includes kanji, include sentenceHira for that item (hiragana only).",
  ].join(" ");
}

export function buildDailySentenceBatchUserPromptJson(
  targetLanguage: string,
  level: string,
  count: number,
  diversitySeed: string,
  requiredVocabulary?: string[]
): string {
  return JSON.stringify({
    targetLanguage,
    level,
    learnerNativeLanguage: "ko",
    batchSize: count,
    diversitySeed,
    ...(requiredVocabulary && requiredVocabulary.length > 0
        ? { requiredVocabulary }
        : {}),
  });
}
