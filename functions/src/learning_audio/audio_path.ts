import { createHash } from "node:crypto";

const STORAGE_PREFIX = "learning_audio";


/** 동일 텍스트·언어는 같은 Storage 경로(중복 TTS 방지) */
export function buildLearningAudioStoragePath(
  targetLanguage: string,
  text: string
): string {
  const lang = targetLanguage.trim().toUpperCase();
  const normalized = text.trim();
  const digest = createHash("sha256")
    .update(`${lang}\n${normalized}`)
    .digest("hex")
    .slice(0, 32);
  return `${STORAGE_PREFIX}/${lang}/${digest}.mp3`;
}
