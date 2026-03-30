import { onCall, HttpsError } from "firebase-functions/v2/https";

type GenerateWordResponse = {
  word: string;
  meaningKo: string;
  example?: string;
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
