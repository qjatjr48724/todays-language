import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { buildRandomWordImageStoragePath } from "./image_path";


describe("buildRandomWordImageStoragePath", () => {
  it("itemId로 Storage 상대 경로를 만든다", () => {
    assert.equal(
      buildRandomWordImageStoragePath("dl01_001"),
      "random_words/images/dl01_001.png"
    );
  });

  it("앞뒤 공백을 제거한다", () => {
    assert.equal(
      buildRandomWordImageStoragePath("  dl01_002  "),
      "random_words/images/dl01_002.png"
    );
  });
});
