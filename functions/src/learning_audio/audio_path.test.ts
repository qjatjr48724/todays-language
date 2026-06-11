import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { buildLearningAudioStoragePath } from "./audio_path";

describe("buildLearningAudioStoragePath", () => {
  it("같은 언어·텍스트는 같은 경로", () => {
    const a = buildLearningAudioStoragePath("JPN", "  ありがとう  ");
    const b = buildLearningAudioStoragePath("jpn", "ありがとう");
    assert.equal(a, b);
    assert.match(a, /^learning_audio\/JPN\/[a-f0-9]{32}\.mp3$/);
  });

  it("언어가 다르면 경로가 다름", () => {
    const jpn = buildLearningAudioStoragePath("JPN", "hello");
    const usa = buildLearningAudioStoragePath("USA", "hello");
    assert.notEqual(jpn, usa);
  });
});
