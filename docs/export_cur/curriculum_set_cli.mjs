/**
 * [TEMP] 커리큘럼 세트 JSON export/import.
 * 이 폴더(docs/export_cur) 전체를 나중에 삭제하면 된다.
 *
 * 사용:
 *   cd docs/export_cur && npm install
 *   npm run export -- --doc JPN_beginner_1_1
 *   npm run import -- --file JPN_beginner_1_1.json
 */

import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

import admin from "firebase-admin";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const OUT_DIR = __dirname;
const GLOBAL_OWNER = "global_learning_set_owner";
const WORD_SUB = "curriculum_word_sets";
const SENTENCE_SUB = "curriculum_sentence_sets";
const DEFAULT_PROJECT = "todays-language-dev";


function omitUndefined(obj) {
  const out = {};
  for (const [k, v] of Object.entries(obj)) {
    if (v !== undefined) out[k] = v;
  }
  return out;
}


function prepareWordItemForImport(incoming, existing, options = {}) {
  const next = { ...incoming };
  const clearAll = options.clearAllAudio === true;
  if (clearAll || !existing || existing.word.trim() !== incoming.word.trim()) {
    delete next.wordAudioPath;
  }
  const prevExample = existing?.example?.trim() ?? "";
  const nextExample = incoming.example?.trim() ?? "";
  if (clearAll || !existing || prevExample !== nextExample) {
    delete next.exampleAudioPath;
  }
  return omitUndefined(next);
}


function prepareSentenceItemForImport(incoming, existing, options = {}) {
  const next = { ...incoming };
  const clearAll = options.clearAllAudio === true;
  if (
    clearAll ||
    !existing ||
    existing.sentence.trim() !== incoming.sentence.trim()
  ) {
    delete next.sentenceAudioPath;
  }
  return omitUndefined(next);
}


function prepareWordItemsForImport(incoming, existing, options = {}) {
  return incoming.map((item, i) =>
    prepareWordItemForImport(item, existing?.[i], options)
  );
}


function prepareSentenceItemsForImport(incoming, existing, options = {}) {
  return incoming.map((item, i) =>
    prepareSentenceItemForImport(item, existing?.[i], options)
  );
}


function parseCurriculumSetExportFile(raw) {
  if (!raw || typeof raw !== "object") {
    throw new Error("export file must be a JSON object");
  }
  const docId = typeof raw.docId === "string" ? raw.docId.trim() : "";
  if (!docId) throw new Error("export file requires non-empty docId");
  return {
    docId,
    exportedAt: typeof raw.exportedAt === "string" ? raw.exportedAt : undefined,
    wordSet:
      raw.wordSet === null
        ? null
        : raw.wordSet && typeof raw.wordSet === "object"
          ? raw.wordSet
          : null,
    sentenceSet:
      raw.sentenceSet === null
        ? null
        : raw.sentenceSet && typeof raw.sentenceSet === "object"
          ? raw.sentenceSet
          : null,
  };
}


function printUsage() {
  console.log(`Usage (TEMP tool under docs/export_cur):
  npm run export -- --doc JPN_beginner_1_1 [--project id] [--credentials sa.json]
  npm run import -- --file JPN_beginner_1_1.json [--clear-all-audio]

Auth:
  gcloud auth application-default login
  # or --credentials /path/to/serviceAccount.json
`);
}


function getArg(argv, name) {
  const i = argv.indexOf(name);
  if (i < 0 || i + 1 >= argv.length) return undefined;
  return argv[i + 1];
}


function hasFlag(argv, name) {
  return argv.includes(name);
}


function ensureAdmin(projectId, credentialsPath) {
  if (admin.apps.length === 0) {
    if (credentialsPath) {
      process.env.GOOGLE_APPLICATION_CREDENTIALS = path.resolve(credentialsPath);
    }
    admin.initializeApp({ projectId });
  }
  return admin.firestore();
}


function ownerBase(db) {
  return db.collection("users").doc(GLOBAL_OWNER);
}


async function cmdExport(argv) {
  const docId = (getArg(argv, "--doc") ?? "").trim();
  if (!docId) throw new Error("--doc is required (e.g. JPN_beginner_1_1)");
  const outDir = path.resolve(getArg(argv, "--out") ?? OUT_DIR);
  const projectId =
    getArg(argv, "--project") ?? process.env.GCLOUD_PROJECT ?? DEFAULT_PROJECT;
  const credentialsPath = getArg(argv, "--credentials");

  const db = ensureAdmin(projectId, credentialsPath);
  const base = ownerBase(db);
  const wordSnap = await base.collection(WORD_SUB).doc(docId).get();
  const sentenceSnap = await base.collection(SENTENCE_SUB).doc(docId).get();

  if (!wordSnap.exists && !sentenceSnap.exists) {
    throw new Error(
      `neither word nor sentence set found for docId=${docId} project=${projectId}`
    );
  }

  const payload = {
    docId,
    exportedAt: new Date().toISOString(),
    projectId,
    wordSet: wordSnap.exists ? wordSnap.data() ?? null : null,
    sentenceSet: sentenceSnap.exists ? sentenceSnap.data() ?? null : null,
  };

  fs.mkdirSync(outDir, { recursive: true });
  const outPath = path.join(outDir, `${docId}.json`);
  fs.writeFileSync(outPath, `${JSON.stringify(payload, null, 2)}\n`, "utf8");
  console.log(`exported ${outPath}`);
  console.log(
    `  wordSet=${wordSnap.exists ? "ok" : "missing"} sentenceSet=${
      sentenceSnap.exists ? "ok" : "missing"
    }`
  );
}


async function cmdImport(argv) {
  const fileArg = getArg(argv, "--file") ?? "";
  const filePath = path.resolve(
    fileArg.includes(path.sep) || fileArg.startsWith(".")
      ? fileArg
      : path.join(OUT_DIR, fileArg)
  );
  if (!fileArg || !fs.existsSync(filePath)) {
    throw new Error(`--file is required and must exist (got: ${filePath || "(empty)"})`);
  }
  const projectId =
    getArg(argv, "--project") ?? process.env.GCLOUD_PROJECT ?? DEFAULT_PROJECT;
  const credentialsPath = getArg(argv, "--credentials");
  const clearAllAudio = hasFlag(argv, "--clear-all-audio");

  const parsed = parseCurriculumSetExportFile(
    JSON.parse(fs.readFileSync(filePath, "utf8"))
  );
  const db = ensureAdmin(projectId, credentialsPath);
  const base = ownerBase(db);
  const wordRef = base.collection(WORD_SUB).doc(parsed.docId);
  const sentenceRef = base.collection(SENTENCE_SUB).doc(parsed.docId);
  const now = Date.now();

  if (parsed.wordSet) {
    const existingSnap = await wordRef.get();
    const existingWords = Array.isArray(existingSnap.data()?.words)
      ? existingSnap.data().words
      : undefined;
    const incomingWords = Array.isArray(parsed.wordSet.words)
      ? parsed.wordSet.words
      : [];
    const words = prepareWordItemsForImport(incomingWords, existingWords, {
      clearAllAudio,
    });
    await wordRef.set({ ...parsed.wordSet, words, updatedAtMs: now }, { merge: true });
    console.log(`imported wordSet docId=${parsed.docId} items=${words.length}`);
  } else {
    console.log("skipped wordSet (null in file)");
  }

  if (parsed.sentenceSet) {
    const existingSnap = await sentenceRef.get();
    const existingSentences = Array.isArray(existingSnap.data()?.sentences)
      ? existingSnap.data().sentences
      : undefined;
    const incomingSentences = Array.isArray(parsed.sentenceSet.sentences)
      ? parsed.sentenceSet.sentences
      : [];
    const sentences = prepareSentenceItemsForImport(
      incomingSentences,
      existingSentences,
      { clearAllAudio }
    );
    await sentenceRef.set(
      { ...parsed.sentenceSet, sentences, updatedAtMs: now },
      { merge: true }
    );
    console.log(
      `imported sentenceSet docId=${parsed.docId} items=${sentences.length}`
    );
  } else {
    console.log("skipped sentenceSet (null in file)");
  }

  console.log(
    `done. Text-changed items had audio paths cleared` +
      (clearAllAudio ? " (--clear-all-audio)" : "") +
      "."
  );
}


async function main() {
  const argv = process.argv.slice(2);
  const cmd = argv[0];
  if (cmd === "export") {
    await cmdExport(argv);
    return;
  }
  if (cmd === "import") {
    await cmdImport(argv);
    return;
  }
  printUsage();
  process.exitCode = 1;
}


main().catch((e) => {
  console.error(`curriculum_set_cli failed: ${e instanceof Error ? e.message : String(e)}`);
  process.exitCode = 1;
});
