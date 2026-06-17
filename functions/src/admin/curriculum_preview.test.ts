import test from "node:test";
import assert from "node:assert/strict";

import {
  ADMIN_CURRICULUM_PREVIEW_DAY_BY_LANGUAGE_FIELD,
  adminPreviewLearningDayForLanguage,
  parseAdminPreviewDayByLanguage,
  resolveEffectiveLearningDay,
} from "./curriculum_preview";

test("parseAdminPreviewDayByLanguage normalizes language keys", () => {
  const parsed = parseAdminPreviewDayByLanguage({ ja: 3, ESP: "7" });
  assert.equal(parsed.JPN, 3);
  assert.equal(parsed.ESP, 7);
});

test("adminPreviewLearningDayForLanguage returns null when unset", () => {
  assert.equal(adminPreviewLearningDayForLanguage({}, "JPN"), null);
});

test("resolveEffectiveLearningDay prefers preview", () => {
  const userData = {
    [ADMIN_CURRICULUM_PREVIEW_DAY_BY_LANGUAGE_FIELD]: { JPN: 5 },
    learningDayByLanguage: { JPN: 2 },
  };
  assert.equal(resolveEffectiveLearningDay(userData, "JPN", 2), 5);
  assert.equal(resolveEffectiveLearningDay(userData, "JPN", 9), 5);
});

test("resolveEffectiveLearningDay falls back to actual", () => {
  assert.equal(resolveEffectiveLearningDay({}, "JPN", 4), 4);
});
