import * as admin from "firebase-admin";

import { db } from "../shared/firebase";

const GLOBAL_LEARNING_SET_OWNER = "global_learning_set_owner";

function todayKstYyyyMmDd(now = new Date()): string {
  const kst = new Date(now.getTime() + 9 * 60 * 60 * 1000);
  const y = kst.getUTCFullYear().toString().padStart(4, "0");
  const m = (kst.getUTCMonth() + 1).toString().padStart(2, "0");
  const d = kst.getUTCDate().toString().padStart(2, "0");
  return `${y}-${m}-${d}`;
}

function learningSetDocId(todayKst: string, targetLanguage: string, level: string): string {
  return `${todayKst}_${targetLanguage}_${level}`;
}

function normalizeTargetLanguage(code: string): { external: string; internal: string } {
  const raw = (code ?? "").trim();
  const upper = raw.toUpperCase();
  // external (ISO-3166-1 alpha-3)
  if (upper === "JPN") return { external: "JPN", internal: "ja" };
  if (upper === "ESP") return { external: "ESP", internal: "es" };
  if (upper === "USA") return { external: "USA", internal: "en" };
  if (upper === "FRA") return { external: "FRA", internal: "fr" };
  if (upper === "DEU") return { external: "DEU", internal: "de" };
  if (upper === "CHN") return { external: "CHN", internal: "zh" };

  // accept legacy language codes from old clients
  const lower = raw.toLowerCase();
  if (lower === "ja") return { external: "JPN", internal: "ja" };
  if (lower === "es") return { external: "ESP", internal: "es" };
  if (lower === "en") return { external: "USA", internal: "en" };
  if (lower === "fr") return { external: "FRA", internal: "fr" };
  if (lower === "de") return { external: "DEU", internal: "de" };
  if (lower === "zh") return { external: "CHN", internal: "zh" };

  // default passthrough
  return { external: upper.length === 3 ? upper : raw, internal: lower };
}

export function globalTodayWordSetRef(
  targetLanguage: string,
  level: string,
  dateKst?: string
): admin.firestore.DocumentReference {
  const ymd = dateKst ?? todayKstYyyyMmDd();
  const tl = normalizeTargetLanguage(targetLanguage);
  const docId = learningSetDocId(ymd, tl.external, level);
  return db
    .collection("users")
    .doc(GLOBAL_LEARNING_SET_OWNER)
    .collection("daily_word_sets")
    .doc(docId);
}

export function globalTodaySentenceSetRef(
  targetLanguage: string,
  level: string,
  dateKst?: string
): admin.firestore.DocumentReference {
  const ymd = dateKst ?? todayKstYyyyMmDd();
  const tl = normalizeTargetLanguage(targetLanguage);
  const docId = learningSetDocId(ymd, tl.external, level);
  return db
    .collection("users")
    .doc(GLOBAL_LEARNING_SET_OWNER)
    .collection("daily_sentence_sets")
    .doc(docId);
}

