import test from "node:test";
import assert from "node:assert/strict";

import {
  CURRICULUM_REVIEW_DAY_BY_LANGUAGE_FIELD,
  curriculumReviewDayForLanguage,
  isValidCurriculumReviewDay,
  parseCurriculumReviewDayByLanguage,
} from "./curriculum_review";
import { resolveWordSentenceStudyDay } from "./curriculum_study_day";

test("isValidCurriculumReviewDay bounds", () => {
  assert.equal(isValidCurriculumReviewDay(3, 4), true);
  assert.equal(isValidCurriculumReviewDay(4, 4), false);
});

test("resolveWordSentenceStudyDay uses review day for normal user", () => {
  const userData = {
    [CURRICULUM_REVIEW_DAY_BY_LANGUAGE_FIELD]: { JPN: 2 },
    learningDayByLanguage: { JPN: 4 },
  };
  assert.equal(
    resolveWordSentenceStudyDay("user1", userData, "JPN", 4),
    2
  );
});

test("curriculumReviewDayForLanguage returns null when unset", () => {
  assert.equal(curriculumReviewDayForLanguage({}, "JPN"), null);
});

test("parseCurriculumReviewDayByLanguage normalizes keys", () => {
  const parsed = parseCurriculumReviewDayByLanguage({ ja: 1 });
  assert.equal(parsed.JPN, 1);
});
