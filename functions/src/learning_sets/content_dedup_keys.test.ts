import assert from "node:assert/strict";
import { describe, it } from "node:test";

import {
  blockedListForPrompt,
  MAX_BLOCKED_PROMPT_ITEMS,
  normalizeContentDedupKey,
  wordContentDedupKey,
} from "./content_dedup_keys";

describe("content_dedup_keys", () => {
  it("normalizeContentDedupKey는 공백·기호를 제거한다", () => {
    assert.equal(
      normalizeContentDedupKey("  ありがとう！  "),
      wordContentDedupKey("ありがとう")
    );
  });

  it("blockedListForPrompt는 상한을 적용한다", () => {
    const keys = new Set(
      Array.from({ length: MAX_BLOCKED_PROMPT_ITEMS + 5 }, (_, i) => `k${i}`)
    );
    assert.equal(blockedListForPrompt(keys).length, MAX_BLOCKED_PROMPT_ITEMS);
  });
});
