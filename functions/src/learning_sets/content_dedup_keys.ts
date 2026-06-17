/** 단어·문장·퀴즈 문구 중복 비교용 정규화 키 */

export function normalizeContentDedupKey(text: string): string {
  return text
    .toLowerCase()
    .replace(/\s+/g, "")
    .replace(/[^\p{L}\p{N}]/gu, "");
}

export function wordContentDedupKey(word: string): string {
  return normalizeContentDedupKey(word);
}

export function sentenceContentDedupKey(sentence: string): string {
  return normalizeContentDedupKey(sentence);
}

/** 프롬프트에 넣을 blocked 목록 상한(토큰·응답 크기) */
export const MAX_BLOCKED_PROMPT_ITEMS = 120;

export function blockedListForPrompt(keys: Iterable<string>): string[] {
  const out: string[] = [];
  for (const key of keys) {
    if (!key || out.length >= MAX_BLOCKED_PROMPT_ITEMS) {
      break;
    }
    out.push(key);
  }
  return out;
}
