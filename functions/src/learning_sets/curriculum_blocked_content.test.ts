import assert from "node:assert/strict";
import { describe, it } from "node:test";

import {
  collectSentenceDedupKeysFromItems,
  collectWordDedupKeysFromItems,
} from "./curriculum_blocked_content";
import { wordContentDedupKey } from "./content_dedup_keys";

describe("curriculum_blocked_content", () => {
  it("collectWordDedupKeysFromItems는 여러 일차 단어를 합친다", () => {
    const keys = collectWordDedupKeysFromItems([
      { word: "こんにちは" },
      { word: "  こんにちは  " },
      { word: "ありがとう" },
    ]);
    assert.equal(keys.size, 2);
    assert.ok(keys.has(wordContentDedupKey("こんにちは")));
    assert.ok(keys.has(wordContentDedupKey("ありがとう")));
  });

  it("collectSentenceDedupKeysFromItems는 문장 키를 수집한다", () => {
    const keys = collectSentenceDedupKeysFromItems([
      { sentence: "きょうは いいてんきですね。" },
      { sentence: "きょうはいいてんきですね" },
    ]);
    assert.equal(keys.size, 1);
  });
});
