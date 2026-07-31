/**
 * example / sentence 의 한자 → 히라가나 변환.
 * 외래어 카타카나(コーヒー 등)는 유지.
 *
 * 실행: node convert_example_to_hiragana.mjs
 */
import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";
import KuroshiroImport from "kuroshiro";
import KuromojiAnalyzer from "kuroshiro-analyzer-kuromoji";

const Kuroshiro = KuroshiroImport.default ?? KuroshiroImport;

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const KANJI_RE = /[\u4E00-\u9FFF]/;
/** 카타카나·장음(ー) 연속 — 외래어 표기 보존 */
const KATAKANA_RE = /[\u30A1-\u30F6\u30FC]+/g;


function protectKatakana(text) {
  const saved = [];
  const protectedText = text.replace(KATAKANA_RE, (m) => {
    const i = saved.length;
    saved.push(m);
    return `⟦K${i}⟧`;
  });
  return { protectedText, saved };
}


function restoreKatakana(text, saved) {
  return text.replace(/⟦K(\d+)⟧/g, (_, i) => saved[Number(i)] ?? "");
}


async function toHiraganaKeepKatakana(kuroshiro, text) {
  if (!text || !KANJI_RE.test(text)) return text;
  const { protectedText, saved } = protectKatakana(text);
  const converted = await kuroshiro.convert(protectedText, {
    to: "hiragana",
    mode: "normal",
  });
  return restoreKatakana(converted, saved);
}


async function main() {
  const kuroshiro = new Kuroshiro();
  await kuroshiro.init(new KuromojiAnalyzer());

  const files = fs
    .readdirSync(__dirname)
    .filter((f) => /^JPN_beginner_1_\d+\.json$/.test(f))
    .sort((a, b) => Number(a.match(/_(\d+)/)[1]) - Number(b.match(/_(\d+)/)[1]));

  let changedFields = 0;
  const samples = [];

  for (const f of files) {
    const filePath = path.join(__dirname, f);
    const data = JSON.parse(fs.readFileSync(filePath, "utf8"));
    let fileChanged = 0;

    for (const w of data.wordSet?.words ?? []) {
      if (!w.example) continue;
      const next = await toHiraganaKeepKatakana(kuroshiro, w.example);
      if (next !== w.example) {
        if (samples.length < 12) {
          samples.push(`${f}: ${w.example} → ${next}`);
        }
        w.example = next;
        fileChanged += 1;
        changedFields += 1;
      }
    }

    for (const s of data.sentenceSet?.sentences ?? []) {
      if (!s.sentence) continue;
      const next = await toHiraganaKeepKatakana(kuroshiro, s.sentence);
      if (next !== s.sentence) {
        if (samples.length < 20) {
          samples.push(`${f} [S]: ${s.sentence} → ${next}`);
        }
        s.sentence = next;
        // 본문이 이미 히라가나 위주면 sentenceHira 중복 제거 가능
        if (
          typeof s.sentenceHira === "string" &&
          s.sentenceHira.replace(/\s/g, "") === next.replace(/\s/g, "")
        ) {
          delete s.sentenceHira;
        }
        fileChanged += 1;
        changedFields += 1;
      }
    }

    if (fileChanged > 0) {
      fs.writeFileSync(filePath, `${JSON.stringify(data, null, 2)}\n`, "utf8");
    }
  }

  // 잔여 한자 점검
  let remainEx = 0;
  let remainS = 0;
  for (const f of files) {
    const data = JSON.parse(fs.readFileSync(path.join(__dirname, f), "utf8"));
    for (const w of data.wordSet?.words ?? []) {
      if (w.example && KANJI_RE.test(w.example)) remainEx += 1;
    }
    for (const s of data.sentenceSet?.sentences ?? []) {
      if (s.sentence && KANJI_RE.test(s.sentence)) remainS += 1;
    }
  }

  console.log(`changedFields=${changedFields}`);
  console.log(`remaining kanji: example=${remainEx} sentence=${remainS}`);
  console.log("samples:\n" + samples.join("\n"));
}


main().catch((e) => {
  console.error(e);
  process.exitCode = 1;
});
