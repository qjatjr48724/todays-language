import { createHash } from "node:crypto";
import * as admin from "firebase-admin";

import { db } from "../shared/firebase";

/** 탈퇴 후 동일 이메일 재가입 금지 기간(일). */
export const ACCOUNT_RECREATION_BLOCK_DAYS = 7;

/** 탈퇴 후 동일 이메일 재가입 금지 기간(ms) — 탈퇴 시각 + 168시간. */
export const ACCOUNT_RECREATION_BLOCK_MS =
  ACCOUNT_RECREATION_BLOCK_DAYS * 24 * 60 * 60 * 1000;

/** Firestore 컬렉션 — 클라이언트 접근 금지(Functions 전용). */
export const ACCOUNT_RECREATION_BLOCKS_COLLECTION = "account_recreation_blocks";

/** TTL 정책 연결용 플레이스홀더 문서 ID. */
export const ACCOUNT_RECREATION_BLOCKS_PLACEHOLDER_DOC_ID = "ttl_placeholder";

/** 클라이언트·blocking function에서 식별용 메시지 토큰. */
export const ACCOUNT_RECREATION_BLOCKED_MESSAGE = "account_recreation_blocked";

export type AccountRecreationBlockDoc = {
  deletedAtMs: number;
  blockedUntilMs: number;
  /** Firestore TTL 필드 — Timestamp 타입만 TTL 정책이 인식합니다. */
  expireAt: admin.firestore.Timestamp;
  /** 앱 로직·디버깅용 ms (TTL은 expireAt 사용). */
  expireAtMs: number;
};


/** 이메일 trim + 소문자 정규화. */
export function normalizeAccountEmail(email: string): string {
  return email.trim().toLowerCase();
}


/** 정규화된 이메일의 SHA-256 hex (Firestore 문서 ID). */
export function hashAccountEmail(normalizedEmail: string): string {
  return createHash("sha256").update(normalizedEmail, "utf8").digest("hex");
}


/** 탈퇴 시각 기준 재가입 허용 시각(ms). */
export function computeAccountRecreationBlockedUntilMs(deletedAtMs: number): number {
  return deletedAtMs + ACCOUNT_RECREATION_BLOCK_MS;
}


/** blockedUntilMs가 아직 유효한지(7일 이내 재가입 금지). */
export function isWithinAccountRecreationBlock(
  blockedUntilMs: number,
  nowMs: number,
): boolean {
  return nowMs < blockedUntilMs;
}


function recreationBlockRef(docId: string) {
  return db.collection(ACCOUNT_RECREATION_BLOCKS_COLLECTION).doc(docId);
}


function buildAccountRecreationBlockDoc(
  nowMs: number,
  blockedUntilMs: number,
  extra?: Record<string, unknown>,
): AccountRecreationBlockDoc & Record<string, unknown> {
  return {
    deletedAtMs: nowMs,
    blockedUntilMs,
    expireAt: admin.firestore.Timestamp.fromMillis(blockedUntilMs),
    expireAtMs: blockedUntilMs,
    ...extra,
  };
}


/** 지정 docId에 재가입 block 문서를 저장합니다. */
export async function recordAccountRecreationBlockDoc(
  docId: string,
  nowMs: number,
  blockedUntilMs: number,
  extra?: Record<string, unknown>,
): Promise<admin.firestore.DocumentReference> {
  const ref = recreationBlockRef(docId);
  await ref.set(buildAccountRecreationBlockDoc(nowMs, blockedUntilMs, extra));
  return ref;
}


/** 탈퇴 시 이메일 해시·만료 시각을 기록합니다. 재탈퇴 시 더 늦은 시각으로 연장. */
export async function recordAccountRecreationBlock(
  email: string,
  nowMs = Date.now(),
): Promise<void> {
  const normalized = normalizeAccountEmail(email);
  if (!normalized) return;

  const emailHash = hashAccountEmail(normalized);
  const blockedUntilMs = computeAccountRecreationBlockedUntilMs(nowMs);
  const ref = recreationBlockRef(emailHash);
  const existing = await ref.get();
  const existingUntil = existing.data()?.blockedUntilMs;

  const finalBlockedUntilMs =
    typeof existingUntil === "number" && existingUntil > blockedUntilMs
      ? existingUntil
      : blockedUntilMs;

  await ref.set(buildAccountRecreationBlockDoc(nowMs, finalBlockedUntilMs));
}


export type AccountRecreationBlockEvaluation = {
  blocked: boolean;
  emailHash?: string;
};


/**
 * 재가입 시 이메일 해시 문서를 조회합니다.
 * 만료된 문서는 lazy delete 후 허용합니다.
 */
export async function evaluateAccountRecreationBlock(
  email: string,
  nowMs = Date.now(),
): Promise<AccountRecreationBlockEvaluation> {
  const normalized = normalizeAccountEmail(email);
  if (!normalized) {
    return { blocked: false };
  }

  const emailHash = hashAccountEmail(normalized);
  const ref = recreationBlockRef(emailHash);
  const snap = await ref.get();

  if (!snap.exists) {
    return { blocked: false, emailHash };
  }

  const blockedUntilMs = snap.data()?.blockedUntilMs;
  if (typeof blockedUntilMs !== "number") {
    await ref.delete();
    return { blocked: false, emailHash };
  }

  if (isWithinAccountRecreationBlock(blockedUntilMs, nowMs)) {
    return { blocked: true, emailHash };
  }

  await ref.delete();
  return { blocked: false, emailHash };
}
