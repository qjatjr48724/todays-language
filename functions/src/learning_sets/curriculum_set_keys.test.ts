import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { curriculumSetDocId } from "./curriculum_set_keys";

describe("curriculum_set_keys", () => {
  it("curriculumSetDocId format", () => {
    assert.equal(curriculumSetDocId("jpn", "Beginner", 1, 7), "JPN_beginner_1_7");
    assert.equal(curriculumSetDocId("USA", "intermediate", 2, 50), "USA_intermediate_2_50");
    assert.equal(curriculumSetDocId("JPN", "beginner", 9, 1), "JPN_beginner_1_1");
  });
});
