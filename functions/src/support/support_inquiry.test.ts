import test from "node:test";
import assert from "node:assert/strict";

import {
  parseSupportInquiryCategory,
  resolveInquiryStatusAfterReply,
  validateSupportInquiryContent,
  validateSupportInquiryReply,
} from "./support_inquiry";

test("parseSupportInquiryCategory accepts known categories", () => {
  assert.equal(parseSupportInquiryCategory("bug"), "bug");
  assert.equal(parseSupportInquiryCategory(" account "), "account");
});

test("parseSupportInquiryCategory rejects unknown category", () => {
  assert.throws(() => parseSupportInquiryCategory("spam"), /invalid-category/);
});

test("validateSupportInquiryContent trims and validates length", () => {
  const result = validateSupportInquiryContent("  제목 ", "  본문 ");
  assert.deepEqual(result, { subject: "제목", body: "본문" });
});

test("validateSupportInquiryContent rejects empty subject", () => {
  assert.throws(() => validateSupportInquiryContent(" ", "본문"), /subject-required/);
});

test("validateSupportInquiryReply requires non-empty text", () => {
  assert.equal(validateSupportInquiryReply("  답변 "), "답변");
  assert.throws(() => validateSupportInquiryReply("   "), /reply-required/);
});

test("resolveInquiryStatusAfterReply defaults to answered", () => {
  assert.equal(resolveInquiryStatusAfterReply(undefined), "answered");
  assert.equal(resolveInquiryStatusAfterReply("answered"), "answered");
  assert.equal(resolveInquiryStatusAfterReply("closed"), "closed");
});
