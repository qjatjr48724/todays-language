import assert from "node:assert/strict";
import { describe, it } from "node:test";

import { CURRICULUM_CORE_V1_TOTAL_DAYS } from "../curriculum/core_v1_rotation";
import {
  pregenerateCurriculumPhase1Days,
  pregenerateNextMissingCurriculumDayPerPair,
} from "./curriculum_pregen";

describe("curriculum_pregen", () => {
  it("creates missing days in day-major order until maxDaysToCreate", async () => {
    const created: string[] = [];

    const summary = await pregenerateCurriculumPhase1Days(
      [
        { targetLanguage: "JPN", level: "beginner" },
        { targetLanguage: "USA", level: "beginner" },
      ],
      async (targetLanguage, level, learningDay) => {
        created.push(`${targetLanguage}_${level}_${learningDay}`);
      },
      {
        startDay: 1,
        endDay: 3,
        maxDaysToCreate: 2,
        isReady: async () => false,
      }
    );

    assert.equal(summary.created, 2);
    assert.equal(summary.skipped, 0);
    assert.equal(summary.failed, 0);
    assert.deepEqual(created, ["JPN_beginner_1", "USA_beginner_1"]);
  });

  it("per-pair scheduler creates only the first missing day for each pair", async () => {
    const ready = new Set(["JPN_beginner_1", "USA_beginner_1"]);
    const created: string[] = [];

    const summary = await pregenerateNextMissingCurriculumDayPerPair(
      [
        { targetLanguage: "JPN", level: "beginner" },
        { targetLanguage: "USA", level: "beginner" },
      ],
      async (targetLanguage, level, learningDay) => {
        created.push(`${targetLanguage}_${level}_${learningDay}`);
      },
      {
        isReady: async (targetLanguage, level, learningDay) =>
          ready.has(`${targetLanguage}_${level}_${learningDay}`),
      }
    );

    assert.equal(summary.created, 2);
    assert.deepEqual(created, ["JPN_beginner_2", "USA_beginner_2"]);
    assert.equal(CURRICULUM_CORE_V1_TOTAL_DAYS, 50);
  });

  it("per-pair scheduler skips when all days are ready", async () => {
    const ready = new Set<string>();
    for (let d = 1; d <= CURRICULUM_CORE_V1_TOTAL_DAYS; d += 1) {
      ready.add(`JPN_beginner_${d}`);
    }

    const summary = await pregenerateNextMissingCurriculumDayPerPair(
      [{ targetLanguage: "JPN", level: "beginner" }],
      async () => {
        assert.fail("should not materialize");
      },
      {
        isReady: async (targetLanguage, level, learningDay) =>
          ready.has(`${targetLanguage}_${level}_${learningDay}`),
      }
    );

    assert.equal(summary.created, 0);
    assert.equal(summary.skipped, CURRICULUM_CORE_V1_TOTAL_DAYS);
  });
});
