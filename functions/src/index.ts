import { onCall, HttpsError } from "firebase-functions/v2/https";

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
  { region: "asia-northeast3" },
  async (request): Promise<GenerateQuizResponse> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const targetLanguage = (request.data?.targetLanguage ?? "ja") as string;
    const level = (request.data?.level ?? "beginner") as string;

    if (targetLanguage === "ja" && level === "beginner") {
      return {
        promptKo: "다음 중 '고마워요'에 해당하는 일본어는?",
        choices: ["こんにちは", "ありがとう", "さようなら", "すみません"],
        answerIndex: 1,
      };
    }

    return {
      promptKo: "다음 중 '안녕'에 해당하는 스페인어는?",
      choices: ["adiós", "gracias", "hola", "por favor"],
      answerIndex: 2,
    };
  }
);
