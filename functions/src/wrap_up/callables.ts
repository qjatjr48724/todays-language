import { onCall, HttpsError } from "firebase-functions/v2/https";

import {
  globalCurriculumSentenceSetRef,
  globalCurriculumWordSetRef,
  globalTodaySentenceSetRef,
  globalTodayWordSetRef,
} from "../learning_sets/refs";
import {
  isCurriculumSetLevel,
  loadUserLearningProfile,
} from "../learning_sets/user_learning_profile";
import { applyAdminPreviewToProfile } from "../admin/curriculum_preview";
import { db } from "../shared/firebase";

type WrapUpDeckItem = {
  kind: "word" | "sentence";
  meaningKo: string;
  answer: string;
};

type WordSetLike = {
  words: { word: string; meaningKo: string }[];
};

type SentenceSetLike = {
  sentences: { sentence: string; meaningKo: string }[];
};

function normalizeTargetLanguage(code: string): { external: string; internal: string } {
  const raw = (code ?? "").trim();
  const upper = raw.toUpperCase();
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

    const userSnap = await db.collection("users").doc(request.auth.uid).get();
    const userData = (userSnap.data() ?? {}) as Record<string, unknown>;
    const baseProfile = await loadUserLearningProfile(
      db,
      request.auth.uid,
      normalizeTargetLanguage
    );
    const profile = applyAdminPreviewToProfile(
      request.auth.uid,
      userData,
      baseProfile
    );
    const targetLanguage =
      (request.data?.targetLanguage as string | undefined) ?? profile.targetLanguage;
    const level = (request.data?.level as string | undefined) ?? profile.level;

    let wordSnap;
    let sentenceSnap;
    if (isCurriculumSetLevel(level)) {
      wordSnap = await globalCurriculumWordSetRef(
        targetLanguage,
        level,
        profile.curriculumPhase,
        profile.learningDay
      ).get();
      sentenceSnap = await globalCurriculumSentenceSetRef(
        targetLanguage,
        level,
        profile.curriculumPhase,
        profile.learningDay
      ).get();
    } else {
      wordSnap = await globalTodayWordSetRef(targetLanguage, level).get();
      sentenceSnap = await globalTodaySentenceSetRef(targetLanguage, level).get();
    }

    const wdata = wordSnap.data() as Partial<WordSetLike> | undefined;
    const sdata = sentenceSnap.data() as Partial<SentenceSetLike> | undefined;
    const words = Array.isArray(wdata?.words) ? wdata!.words : [];
    const sentences = Array.isArray(sdata?.sentences) ? sdata!.sentences : [];

    /** 일일 풀(15/5) 대비 약 60%/80% 샘플 — 합계 13문제(단어 70% / 문장 30%) */
    const wrapUpWordCount = 9;
    const wrapUpSentenceCount = 4;
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
