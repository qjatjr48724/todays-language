import { synthesizeLearningAudioToStorage } from "./synthesize";

export type WordItemForAudio = {
  word: string;
  readingHira?: string;
  meaningKo: string;
  example?: string;
  exampleMeaningKo?: string;
  wordAudioPath?: string;
  exampleAudioPath?: string;
};

export type SentenceItemForAudio = {
  sentence: string;
  sentenceHira?: string;
  meaningKo: string;
  vocabularyHints?: { word: string; meaningKo: string }[];
  sentenceAudioPath?: string;
};

export type SynthesizeToStorageFn = (
  text: string,
  targetLanguage: string
) => Promise<string | null>;


export function wordItemNeedsAudio(item: WordItemForAudio): boolean {
  const needsWord = item.word.trim().length > 0 && !item.wordAudioPath;
  const needsExample =
    (item.example?.trim().length ?? 0) > 0 && !item.exampleAudioPath;
  return needsWord || needsExample;
}


export function sentenceItemNeedsAudio(item: SentenceItemForAudio): boolean {
  return item.sentence.trim().length > 0 && !item.sentenceAudioPath;
}


/** 단어 세트 항목에 word/example 음성 경로를 붙인다. */
export async function enrichWordItemsWithAudio<T extends WordItemForAudio>(
  words: T[],
  targetLanguage: string,
  synthesize: SynthesizeToStorageFn = synthesizeLearningAudioToStorage
): Promise<T[]> {
  const out: T[] = [];
  for (const item of words) {
    const next = { ...item };
    if (item.word.trim() && !item.wordAudioPath) {
      const path = await synthesize(item.word.trim(), targetLanguage);
      if (path) next.wordAudioPath = path;
    }
    if (item.example?.trim() && !item.exampleAudioPath) {
      const path = await synthesize(item.example.trim(), targetLanguage);
      if (path) next.exampleAudioPath = path;
    }
    out.push(next);
  }
  return out;
}


/** 문장 세트 항목에 sentence 음성 경로를 붙인다. */
export async function enrichSentenceItemsWithAudio<T extends SentenceItemForAudio>(
  sentences: T[],
  targetLanguage: string,
  synthesize: SynthesizeToStorageFn = synthesizeLearningAudioToStorage
): Promise<T[]> {
  const out: T[] = [];
  for (const item of sentences) {
    const next = { ...item };
    if (item.sentence.trim() && !item.sentenceAudioPath) {
      const path = await synthesize(item.sentence.trim(), targetLanguage);
      if (path) next.sentenceAudioPath = path;
    }
    out.push(next);
  }
  return out;
}
