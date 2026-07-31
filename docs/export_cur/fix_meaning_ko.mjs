/**
 * TEMP: meaningKo 평어체·높임·질문 자연화·어색 문장 수정.
 * 실행: node fix_meaning_ko.mjs
 */
import * as fs from "node:fs";
import * as path from "node:path";
import { fileURLToPath } from "node:url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));


/** 단어 meaningKo: 평어체 매핑 (완전 일치 우선) */
const WORD_MEANING_EXACT = {
  "축하해요": "축하하다",
  "힘내세요": "힘내다",
  "있습니다 (무생물 대상)": "있다 (무생물 대상)",
  "없습니다 (무생물 대상 부정)": "없다 (무생물 대상 부정)",
  "있습니다 (생물 대상)": "있다 (생물 대상)",
  "없습니다 (생물 대상 부정)": "없다 (생물 대상 부정)",
  "~입니다 (존댓말)": "~이다 (평어)",
  "~이 아닙니다 (부정 표현)": "~이/가 아니다 (부정)",
  "걷습니다 (걷다의 정중형)": "걷다",
  "그래서입니다": "그래서이다",
  "알겠습니다": "알다",
  "모르겠습니다, 이해하지 못하다": "모르다, 이해하지 못하다",
  "할 수 있습니까?": "할 수 있다",
  "괜찮습니까?": "괜찮다",
  "부탁합니다": "부탁하다",
  "실례합니다": "실례하다",
  "미안합니다": "미안하다",
  "먼저 가겠습니다 (작별 인사)": "먼저 가다 (작별 인사)",
  "들고 가 주세요": "들고 가다 (정중 요청: 주세요)",
  "따로 계산해 주세요": "따로 계산하다 (정중 요청: 주세요)",
};


/** 문장/예문 meaningKo: 완전 일치 교체 */
const TEXT_EXACT = {
  "나가요? 잘 다녀오세요.": "외출하세요? 잘 다녀오세요.",
  "안녕하세요, 건강하세요?": "안녕하세요, 잘 지내세요?",
  "저녁은 밤 전에요.": "저녁은 밤이 되기 전이에요.",
  "목이 말라 있어요.": "목이 말라요.",
  "일본에서 일하고 싶은 희망이에요.": "일본에서 일하고 싶어요.",
  "세상을 사는 것은 중요해요.": "세상을 살아가는 것은 중요해요.",
  "플랫홈에서 차를 마신다.": "플랫폼에서 차를 마셔요.",
  "백석 호에 타는 것은 즐겁습니다.": "기차를 타는 것은 즐거워요.",
  "교통 현장에서 공부합니다.": "교통 현장에서 공부해요.",
  "교통 현장에서 만났습니다.": "교통 현장에서 만났어요.",
  "자전거 표를 샀어요.": "자전거 이용권을 샀어요.",
  "기록을 해요.": "거리를 재요.",
  "우회로를 사용해 회수합니다.": "우회로를 이용해 돌아가요.",
  "생일에 공항에 갔습니다.": "생일에 공항에 갔어요.",
  "전통성을 지킵시다.": "전통을 지킵시다.",
  "늦었을 때는 역사를 읽습니다.": "여유 시간이 있을 때는 역사를 읽어요.",
  "학문은 공부하는 것입니다.": "학문이란 공부하는 것입니다.",
  "싫은 바람이 불고 있어요.": "거센 바람이 불고 있어요.",
  "학교에 선생님이 있습니다.": "학교에 선생님이 계십니다.",
  "어머니는 지금 집에 있습니다.": "어머니는 지금 집에 계십니다.",
  "할머니는 언제나 그림을 그리고 있습니다.": "할머니는 언제나 그림을 그리고 계십니다.",
  "할머니는 상냥합니다.": "할머니는 상냥하세요.",
  "할아버지는 공원에 산책하러 갑니다.": "할아버지는 공원에 산책하러 가세요.",
  // 질문 자연화
  "왜 울고 있니?": "왜 울고 있나요?",
  "버스 정류장은 어디입니까?": "버스 정류장은 어디인가요?",
  "버스 타는 곳은 어디입니까?": "버스 타는 곳은 어디인가요?",
  "열쇠를 받았나요?": "열쇠를 받으셨나요?",
  "방송 프로그램을 봅니까?": "방송 프로그램을 보나요?",
  "주차장은 어디에요?": "주차장은 어디예요?",
  "이것은 무엇입니까?": "이것은 무엇인가요?",
  "이것이 필요합니까?": "이것이 필요한가요?",
  "실례하지만, 괜찮습니까?": "실례지만, 괜찮으세요?",
  "점심에 무엇을 먹습니까?": "점심에 무엇을 먹나요?",
  "도착 시간은 몇 시입니까?": "도착 시간은 몇 시인가요?",
  "당신의 아버지는 상냥합니까?": "당신의 아버지는 상냥하신가요?",
  "집에서 역까지 시간은 얼마나 걸립니까?": "집에서 역까지 얼마나 걸리나요?",
  "역 출구는 어디입니까?": "역 출구는 어디인가요?",
  "어느 것이 당신 것입니까?": "어느 것이 당신 것인가요?",
  "화장실은 어디입니까?": "화장실은 어디인가요?",
  "친구는 어디에 있습니까?": "친구는 어디에 있나요?",
  "당신은 선생님입니까?": "당신은 선생님인가요?",
  "너희들은 무엇을 합니까?": "너희들은 무엇을 하나요?",
  "당신의 이름은 무엇입니까?": "당신의 성함은 무엇인가요?",
  "이 문제를 이해합니까?": "이 문제를 이해하나요?",
  "교실은 어디에 있습니까?": "교실은 어디에 있나요?",
  "사과가 몇 개 있습니까?": "사과가 몇 개 있나요?",
  "사과를 몇 개 사용합니까?": "사과를 몇 개 쓰나요?",
  "화장실은 어디에요?": "화장실은 어디예요?",
  "시간표를 확인했나요?": "시간표를 확인하셨나요?",
  "선생님, 주의할 것이 있나요?": "선생님, 주의할 점이 있으세요?",
  "괜찮습니까?": "괜찮으세요?",
  "실례합니다, 도움이 필요합니까?": "실례합니다, 도움이 필요하세요?",
  "이 문제를 할 수 있습니까?": "이 문제를 할 수 있나요?",
  "이것으로 괜찮습니까?": "이것으로 괜찮으세요?",
  "저 빌딩은 뭐예요?": "저 빌딩은 무엇인가요?",
};


function fixWordMeaning(meaningKo) {
  if (WORD_MEANING_EXACT[meaningKo]) return WORD_MEANING_EXACT[meaningKo];
  return meaningKo;
}


function applyHonorifics(text) {
  let t = text;
  // 존경 대상 + 있다 → 계시다 (이미 계시면 유지)
  t = t.replace(
    /(선생님|할머니|할아버지|어머니|아버지|손님)(?![가-힣])([^。.\n]*)(이|가)\s*있습니다/g,
    "$1$2$3 계십니다"
  );
  t = t.replace(
    /(선생님|할머니|할아버지|어머니|아버지|손님)(?![가-힣])([^。.\n]*)(이|가)\s*있어요/g,
    "$1$2$3 계세요"
  );
  t = t.replace(
    /(선생님|할머니|할아버지|어머니|아버지)(?![가-힣])([^。.\n]*)을\s*그리고 있습니다/g,
    "$1$2을 그리고 계십니다"
  );
  t = t.replace(
    /(선생님|할머니|할아버지|어머니|아버지)(?![가-힣])([^。.\n]*)를\s*그리고 있습니다/g,
    "$1$2를 그리고 계십니다"
  );
  return t;
}


function softenQuestions(text) {
  let t = text;
  // 일반적인 딱딱한 질문 어미
  t = t.replace(/무엇입니까\?/g, "무엇인가요?");
  t = t.replace(/어디입니까\?/g, "어디인가요?");
  t = t.replace(/입니까\?/g, "인가요?");
  t = t.replace(/습니까\?/g, "나요?");
  t = t.replace(/합니까\?/g, "하나요?");
  t = t.replace(/봅니까\?/g, "보나요?");
  t = t.replace(/먹습니까\?/g, "먹나요?");
  t = t.replace(/걸립니까\?/g, "걸리나요?");
  t = t.replace(/필요합니까\?/g, "필요하세요?");
  t = t.replace(/괜찮습니까\?/g, "괜찮으세요?");
  t = t.replace(/상냥합니까\?/g, "상냥하신가요?");
  t = t.replace(/이해합니까\?/g, "이해하나요?");
  t = t.replace(/있습니까\?/g, "있나요?");
  t = t.replace(/사용합니까\?/g, "쓰나요?");
  t = t.replace(/어디에요\?/g, "어디예요?");
  return t;
}


function fixTextMeaning(text) {
  if (!text) return text;
  if (TEXT_EXACT[text]) return TEXT_EXACT[text];
  let t = text;
  t = applyHonorifics(t);
  t = softenQuestions(t);
  // 플랫홈 표기
  t = t.replace(/플랫홈/g, "플랫폼");
  return t;
}


function processFile(filePath) {
  const raw = fs.readFileSync(filePath, "utf8");
  const data = JSON.parse(raw);
  let changed = 0;

  const touch = (obj, key, fixer) => {
    if (!obj || typeof obj[key] !== "string") return;
    const next = fixer(obj[key]);
    if (next !== obj[key]) {
      obj[key] = next;
      changed += 1;
    }
  };

  for (const w of data.wordSet?.words ?? []) {
    touch(w, "meaningKo", fixWordMeaning);
    touch(w, "exampleMeaningKo", fixTextMeaning);
  }
  for (const s of data.sentenceSet?.sentences ?? []) {
    touch(s, "meaningKo", fixTextMeaning);
  }

  if (changed > 0) {
    fs.writeFileSync(filePath, `${JSON.stringify(data, null, 2)}\n`, "utf8");
  }
  return changed;
}


const files = fs
  .readdirSync(__dirname)
  .filter((f) => /^JPN_beginner_1_\d+\.json$/.test(f))
  .sort((a, b) => Number(a.match(/_(\d+)/)[1]) - Number(b.match(/_(\d+)/)[1]));

let total = 0;
const perFile = [];
for (const f of files) {
  const n = processFile(path.join(__dirname, f));
  if (n > 0) {
    perFile.push(`${f}: ${n}`);
    total += n;
  }
}

console.log(`updated fields=${total}`);
console.log(perFile.join("\n"));
