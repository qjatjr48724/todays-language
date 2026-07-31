/**
 * JPN beginner phase1 세트 import + 예문/문장 음성 재생성.
 *
 * - 예문·문장 audio path는 항상 재검증(동일 텍스트면 Storage 재사용)
 * - 단어(word) 음성은 텍스트 동일하면 유지
 *
 * 실행: node refresh_curriculum_audio.mjs [--days 1-50] [--project todays-language-dev]
 */
import * as crypto from "node:crypto";
import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

import admin from "firebase-admin";
import textToSpeech from "@google-cloud/text-to-speech";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const GLOBAL_OWNER = "global_learning_set_owner";
const WORD_SUB = "curriculum_word_sets";
const SENTENCE_SUB = "curriculum_sentence_sets";
const DEFAULT_PROJECT = "todays-language-dev";
const VOICE = { languageCode: "ja-JP", name: "ja-JP-Wavenet-A" };


function getArg(argv, name) {
  const i = argv.indexOf(name);
  if (i < 0 || i + 1 >= argv.length) return undefined;
  return argv[i + 1];
}


function parseDays(raw) {
  if (!raw) return Array.from({ length: 50 }, (_, i) => i + 1);
  if (raw.includes("-")) {
    const [a, b] = raw.split("-").map((x) => Number(x));
    const out = [];
    for (let d = a; d <= b; d += 1) out.push(d);
    return out;
  }
  return raw
    .split(",")
    .map((x) => Number(x.trim()))
    .filter((n) => n >= 1 && n <= 50);
}


function omitUndefined(obj) {
  const out = {};
  for (const [k, v] of Object.entries(obj)) {
    if (v !== undefined) out[k] = v;
  }
  return out;
}


function buildAudioPath(targetLanguage, text) {
  const lang = targetLanguage.trim().toUpperCase();
  const digest = crypto
    .createHash("sha256")
    .update(`${lang}\n${text.trim()}`)
    .digest("hex")
    .slice(0, 32);
  return `learning_audio/${lang}/${digest}.mp3`;
}


function prepareWord(incoming, existing) {
  const next = { ...incoming };
  const prevWord = existing?.word?.trim() ?? "";
  const nextWord = incoming.word?.trim() ?? "";
  if (!existing || prevWord !== nextWord) {
    delete next.wordAudioPath;
  }
  delete next.exampleAudioPath;
  return omitUndefined(next);
}


function prepareSentence(incoming) {
  const next = { ...incoming };
  delete next.sentenceAudioPath;
  return omitUndefined(next);
}


async function ensureAudio(tts, bucket, text, targetLanguage, cache, stats) {
  const trimmed = text.trim();
  if (!trimmed) return undefined;
  const storagePath = buildAudioPath(targetLanguage, trimmed);
  if (cache.has(storagePath)) {
    stats.reused += 1;
    return storagePath;
  }

  const file = bucket.file(storagePath);
  const [exists] = await file.exists();
  if (exists) {
    cache.add(storagePath);
    stats.reused += 1;
    return storagePath;
  }

  const [response] = await tts.synthesizeSpeech({
    input: { text: trimmed },
    voice: { languageCode: VOICE.languageCode, name: VOICE.name },
    audioConfig: { audioEncoding: "MP3", speakingRate: 0.95 },
  });
  const audio = response.audioContent;
  if (!audio || (typeof audio === "string" && audio.length === 0)) {
    throw new Error(`empty TTS audio for ${storagePath}`);
  }
  const buffer =
    typeof audio === "string" ? Buffer.from(audio, "base64") : Buffer.from(audio);
  await file.save(buffer, {
    contentType: "audio/mpeg",
    resumable: false,
    metadata: { cacheControl: "public, max-age=31536000" },
  });
  cache.add(storagePath);
  stats.created += 1;
  return storagePath;
}


async function refreshDay(db, tts, bucket, day, cache, stats) {
  const docId = `JPN_beginner_1_${day}`;
  const filePath = path.join(__dirname, `${docId}.json`);
  if (!fs.existsSync(filePath)) {
    throw new Error(`missing file ${filePath}`);
  }
  const parsed = JSON.parse(fs.readFileSync(filePath, "utf8"));
  const base = db.collection("users").doc(GLOBAL_OWNER);
  const wordRef = base.collection(WORD_SUB).doc(docId);
  const sentenceRef = base.collection(SENTENCE_SUB).doc(docId);
  const now = Date.now();
  const beforeCreated = stats.created;
  const beforeReused = stats.reused;

  if (parsed.wordSet) {
    const existingSnap = await wordRef.get();
    const existingWords = Array.isArray(existingSnap.data()?.words)
      ? existingSnap.data().words
      : [];
    const incomingWords = Array.isArray(parsed.wordSet.words)
      ? parsed.wordSet.words
      : [];
    const words = [];
    for (let i = 0; i < incomingWords.length; i += 1) {
      const item = prepareWord(incomingWords[i], existingWords[i]);
      const lang = parsed.wordSet.targetLanguage || "JPN";
      if (item.word?.trim() && !item.wordAudioPath) {
        item.wordAudioPath = await ensureAudio(
          tts,
          bucket,
          item.word,
          lang,
          cache,
          stats
        );
      }
      if (item.example?.trim() && !item.exampleAudioPath) {
        item.exampleAudioPath = await ensureAudio(
          tts,
          bucket,
          item.example,
          lang,
          cache,
          stats
        );
      }
      words.push(omitUndefined(item));
    }
    await wordRef.set({ ...parsed.wordSet, words, updatedAtMs: now }, { merge: true });
  }

  if (parsed.sentenceSet) {
    const incoming = Array.isArray(parsed.sentenceSet.sentences)
      ? parsed.sentenceSet.sentences
      : [];
    const sentences = [];
    for (let i = 0; i < incoming.length; i += 1) {
      const item = prepareSentence(incoming[i]);
      const lang = parsed.sentenceSet.targetLanguage || "JPN";
      if (item.sentence?.trim() && !item.sentenceAudioPath) {
        item.sentenceAudioPath = await ensureAudio(
          tts,
          bucket,
          item.sentence,
          lang,
          cache,
          stats
        );
      }
      sentences.push(omitUndefined(item));
    }
    await sentenceRef.set(
      { ...parsed.sentenceSet, sentences, updatedAtMs: now },
      { merge: true }
    );
  }

  console.log(
    `[${docId}] created=+${stats.created - beforeCreated} reused=+${
      stats.reused - beforeReused
    }`
  );
}


async function main() {
  const argv = process.argv.slice(2);
  const projectId =
    getArg(argv, "--project") ?? process.env.GCLOUD_PROJECT ?? DEFAULT_PROJECT;
  const days = parseDays(getArg(argv, "--days"));

  if (admin.apps.length === 0) {
    admin.initializeApp({
      projectId,
      storageBucket: `${projectId}.firebasestorage.app`,
    });
  }
  const db = admin.firestore();
  const bucket = admin.storage().bucket();
  const tts = new textToSpeech.TextToSpeechClient();
  const cache = new Set();
  const stats = { created: 0, reused: 0 };

  console.log(
    `refresh start project=${projectId} days=${days[0]}..${days[days.length - 1]}`
  );
  for (const day of days) {
    await refreshDay(db, tts, bucket, day, cache, stats);
  }
  console.log(
    `done. tts_created=${stats.created} storage_reused=${stats.reused} unique_paths=${cache.size}`
  );
}


main().catch((e) => {
  console.error(
    `refresh_curriculum_audio failed: ${e instanceof Error ? e.message : String(e)}`
  );
  process.exitCode = 1;
});
