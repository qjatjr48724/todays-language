import assert from "node:assert/strict";
import { describe, it } from "node:test";

import {
  clampLearningDay,
  curriculumStateBackfillPatch,
  curriculumStateFromUserData,
  DEFAULT_CURRICULUM_STATE,
  effectiveLearningLevel,
  learningDayForLanguage,
  normalizeLearningLevel,
} from "./curriculum_state";
import { CURRICULUM_CORE_V1_TOTAL_DAYS } from "./core_v1_rotation";

describe("curriculum_state", () => {
  it("clampLearningDay bounds", () => {
    assert.equal(clampLearningDay(0), 1);
    assert.equal(clampLearningDay(1), 1);
    assert.equal(clampLearningDay(CURRICULUM_CORE_V1_TOTAL_DAYS), CURRICULUM_CORE_V1_TOTAL_DAYS);
    assert.equal(clampLearningDay(999), CURRICULUM_CORE_V1_TOTAL_DAYS);
    assert.equal(clampLearningDay(Number.NaN), 1);
  });

  it("curriculumStateFromUserData fills defaults", () => {
    const state = curriculumStateFromUserData({});
    assert.deepEqual(state, DEFAULT_CURRICULUM_STATE);
  });

  it("curriculumStateBackfillPatch does not overwrite existing progress", () => {
    const patch = curriculumStateBackfillPatch({
      curriculumId: "core_v1",
      curriculumPhase: 2,
      learningDay: 25,
      learningMode: "review",
      cycleReviewStatus: "in_progress",
      level: "intermediate",
    });
    assert.deepEqual(patch, {});
  });

  it("curriculumStateBackfillPatch fills missing fields only", () => {
    const patch = curriculumStateBackfillPatch({ learningDay: 3 });
    assert.equal(patch.curriculumId, "core_v1");
    assert.equal(patch.curriculumPhase, 1);
    assert.equal(patch.learningMode, "curriculum");
    assert.equal(patch.cycleReviewStatus, "none");
    assert.equal(patch.level, "beginner");
    assert.equal("learningDay" in patch, false);
  });

  it("normalizeLearningLevel", () => {
    assert.equal(normalizeLearningLevel("Intermediate"), "intermediate");
    assert.equal(normalizeLearningLevel("invalid"), "beginner");
  });

  it("learningDayForLanguage uses per-language map", () => {
    const day = learningDayForLanguage(
      { learningDayByLanguage: { KOR: 3, JPN: 1 } },
      "JPN"
    );
    assert.equal(day, 1);
  });

  it("learningDayForLanguage migrates legacy learningDay", () => {
    const day = learningDayForLanguage({ learningDay: 5, targetLanguage: "KOR" }, "KOR");
    assert.equal(day, 5);
  });

  it("curriculumStateFromUserData uses targetLanguage learningDay", () => {
    const state = curriculumStateFromUserData(
      { learningDayByLanguage: { KOR: 3, JPN: 1 } },
      { targetLanguage: "JPN" }
    );
    assert.equal(state.learningDay, 1);
  });

  it("effectiveLearningLevel forces beginner when difficulty UI is off", () => {
    assert.equal(effectiveLearningLevel("intermediate"), "beginner");
    assert.equal(effectiveLearningLevel("advanced"), "beginner");
    assert.equal(effectiveLearningLevel("beginner"), "beginner");
    assert.equal(effectiveLearningLevel(undefined), "beginner");
  });
});
