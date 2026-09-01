import test from "node:test";
import assert from "node:assert/strict";

import {
  ACCOUNT_RECREATION_BLOCK_MS,
  ACCOUNT_RECREATION_BLOCKED_MESSAGE,
  computeAccountRecreationBlockedUntilMs,
  hashAccountEmail,
  isWithinAccountRecreationBlock,
  normalizeAccountEmail,
} from "./account_recreation_block";

test("normalizeAccountEmail trims and lowercases", () => {
  assert.equal(normalizeAccountEmail("  User@Example.COM  "), "user@example.com");
});

test("hashAccountEmail is deterministic for normalized email", () => {
  const a = hashAccountEmail("beomseok.kim@gmail.com");
  const b = hashAccountEmail("beomseok.kim@gmail.com");
  assert.equal(a, b);
  assert.match(a, /^[a-f0-9]{64}$/);
});

test("same email with different casing yields same hash after normalize", () => {
  const left = hashAccountEmail(normalizeAccountEmail("BeomSeok.Kim@gmail.com"));
  const right = hashAccountEmail(normalizeAccountEmail("beomseok.kim@gmail.com"));
  assert.equal(left, right);
});

test("computeAccountRecreationBlockedUntilMs adds 7 days in ms", () => {
  const deletedAtMs = 1_700_000_000_000;
  assert.equal(
    computeAccountRecreationBlockedUntilMs(deletedAtMs),
    deletedAtMs + ACCOUNT_RECREATION_BLOCK_MS,
  );
});

test("isWithinAccountRecreationBlock blocks before expiry", () => {
  const nowMs = 1_700_000_000_000;
  const blockedUntilMs = nowMs + 60_000;
  assert.equal(isWithinAccountRecreationBlock(blockedUntilMs, nowMs), true);
  assert.equal(isWithinAccountRecreationBlock(blockedUntilMs, blockedUntilMs), false);
  assert.equal(isWithinAccountRecreationBlock(blockedUntilMs, blockedUntilMs + 1), false);
});

test("ACCOUNT_RECREATION_BLOCKED_MESSAGE is stable token", () => {
  assert.equal(ACCOUNT_RECREATION_BLOCKED_MESSAGE, "account_recreation_blocked");
});
