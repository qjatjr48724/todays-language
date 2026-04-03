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
