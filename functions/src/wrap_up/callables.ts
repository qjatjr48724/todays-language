import { onCall, HttpsError } from "firebase-functions/v2/https";

import { globalTodaySentenceSetRef, globalTodayWordSetRef } from "../learning_sets/refs";

type WrapUpDeckItem = {
  kind: "word" | "sentence";
  meaningKo: string;
  answer: string;
};

type DailyWordSet = {
  words: { word: string; meaningKo: string }[];
};

type DailySentenceSet = {
  sentences: { sentence: string; meaningKo: string }[];
};

function shuffle<T>(arr: T[]): T[] {
  const out = [...arr];
  for (let i = out.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [out[i], out[j]] = [out[j], out[i]];
  }
  return out;
}

/** 마무리용 카드만 Firestore에서 읽음(AI·세트 생성 없음). */
export const getWrapUpDeck = onCall(
  { region: "asia-northeast3" },
  async (request): Promise<{ items: WrapUpDeckItem[] }> => {
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
    const pickS = shuffle([...sentences]).slice(
      0,
      Math.min(wrapUpSentenceCount, sentences.length)
    );

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
  }
);

