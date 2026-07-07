import assert from "node:assert/strict";
import { describe, it } from "node:test";

import {
  curriculumPromptContextForDay,
  curriculumTopicLabelsKoForDay,
} from "./curriculum/prompt_bridge";
import { getCurriculumDaySpec } from "./curriculum/core_v1_rotation";
import { curriculumSetDocId } from "./learning_sets/curriculum_set_keys";
import { isCurriculumSetLevel } from "./learning_sets/user_learning_profile";
import {
  buildDailyWordBatchSystemPrompt,
  buildDailyWordBatchUserPromptJson,
} from "./prompts";

/** Phase C 배포 전·후 로컬 스모크 검증 (네트워크/Firestore 불필요) */
describe("phase_c_verify", () => {
  it("curriculum set doc id for day 1 beginner JPN", () => {
    assert.equal(curriculumSetDocId("JPN", "beginner", 1, 1), "JPN_beginner_1_1");
  });

  it("only beginner and intermediate use curriculum AI sets", () => {
    assert.equal(isCurriculumSetLevel("beginner"), true);
    assert.equal(isCurriculumSetLevel("intermediate"), true);
    assert.equal(isCurriculumSetLevel("advanced"), false);
  });

  it("day 1 prompt context includes topic scope", () => {
    const ctx = curriculumPromptContextForDay(1, 1);
    assert.ok(ctx);
    assert.equal(ctx!.learningDay, 1);
    assert.equal(ctx!.curriculumPhase, 1);
    assert.ok(ctx!.topicIds.length > 0);
    assert.ok(ctx!.scopeLine.includes("Day 1"));

    const spec = getCurriculumDaySpec(1);
    assert.ok(spec);
    assert.deepEqual(ctx!.topicIds, [...spec!.topicIds]);
    assert.deepEqual(ctx!.topicLabelsKo, [...spec!.topicLabelsKo]);
  });

  it("curriculum topic labels for Firestore payload", () => {
    assert.deepEqual(curriculumTopicLabelsKoForDay(49), ["동아리·행사"]);
    assert.deepEqual(curriculumTopicLabelsKoForDay(50), ["진로·상담"]);
  });

  it("word batch prompts embed curriculum scope when provided", () => {
    const ctx = curriculumPromptContextForDay(1, 1)!;
    const system = buildDailyWordBatchSystemPrompt("ja", "beginner", 15, ctx);
    const user = buildDailyWordBatchUserPromptJson("ja", "beginner", 15, "seed-1", ctx);
    assert.ok(system.includes("Curriculum day 1/50"));
    assert.ok(system.includes("Today's topic scope ONLY"));
    assert.ok(user.includes('"curriculum"'));
  });
});
