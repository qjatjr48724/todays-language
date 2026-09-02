import * as admin from "firebase-admin";

import { db } from "../shared/firebase";
import {
  parseSupportInquiryCategory,
  SUPPORT_INQUIRIES_COLLECTION,
  type SupportInquiryCategory,
  type SupportInquiryRecord,
  type SupportInquiryStatus,
  validateSupportInquiryContent,
  validateSupportInquiryReply,
  resolveInquiryStatusAfterReply,
} from "./support_inquiry";


export type CreateSupportInquiryParams = {
  uid: string;
  email: string;
  displayName?: string;
  category: SupportInquiryCategory;
  subject: string;
  body: string;
  nowMs?: number;
};


/** 로그인 사용자 문의를 생성합니다. */
export async function createSupportInquiry(
  params: CreateSupportInquiryParams,
): Promise<{ inquiryId: string }> {
  const nowMs = params.nowMs ?? Date.now();
  const inquiryRef = db.collection(SUPPORT_INQUIRIES_COLLECTION).doc();
  const messageRef = inquiryRef.collection("messages").doc();

  const record: SupportInquiryRecord = {
    uid: params.uid,
    email: params.email.trim(),
    displayName: (params.displayName ?? "").trim(),
    category: params.category,
    subject: params.subject,
    body: params.body,
    status: "open",
    createdAtMs: nowMs,
    updatedAtMs: nowMs,
  };

  await db.runTransaction(async (tx) => {
    tx.set(inquiryRef, record);
    tx.set(messageRef, {
      authorType: "user",
      authorUid: params.uid,
      text: params.body,
      createdAtMs: nowMs,
    });
  });

  return { inquiryId: inquiryRef.id };
}


/** 관리자 답변을 등록합니다. */
export async function replySupportInquiry(params: {
  inquiryId: string;
  adminUid: string;
  text: string;
  status?: SupportInquiryStatus;
  nowMs?: number;
}): Promise<{ ok: true }> {
  const nowMs = params.nowMs ?? Date.now();
  const replyText = validateSupportInquiryReply(params.text);
  const nextStatus = resolveInquiryStatusAfterReply(params.status);

  const inquiryRef = db.collection(SUPPORT_INQUIRIES_COLLECTION).doc(params.inquiryId);
  const messageRef = inquiryRef.collection("messages").doc();

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(inquiryRef);
    if (!snap.exists) {
      throw new Error("inquiry-not-found");
    }
    const data = snap.data() as Partial<SupportInquiryRecord>;
    const patch: Partial<SupportInquiryRecord> = {
      status: nextStatus,
      updatedAtMs: nowMs,
    };
    if (nextStatus === "answered" && data.answeredAtMs == null) {
      patch.answeredAtMs = nowMs;
    }
    tx.set(inquiryRef, patch, { merge: true });
    tx.set(messageRef, {
      authorType: "admin",
      authorUid: params.adminUid,
      text: replyText,
      createdAtMs: nowMs,
    });
  });

  return { ok: true };
}


/** 탈퇴 시 사용자 문의·메시지를 삭제합니다. */
export async function deleteUserSupportInquiries(uid: string): Promise<number> {
  let deleted = 0;

  while (true) {
    const snap = await db
      .collection(SUPPORT_INQUIRIES_COLLECTION)
      .where("uid", "==", uid)
      .limit(20)
      .get();
    if (snap.empty) break;

    for (const doc of snap.docs) {
      const messages = await doc.ref.collection("messages").listDocuments();
      const batch = db.batch();
      for (const messageRef of messages) {
        batch.delete(messageRef);
      }
      batch.delete(doc.ref);
      await batch.commit();
      deleted += 1;
    }
  }

  return deleted;
}


/** Callable 입력을 파싱합니다. */
export function parseSubmitSupportInquiryInput(data: unknown): {
  category: SupportInquiryCategory;
  subject: string;
  body: string;
} {
  if (typeof data !== "object" || data == null) {
    throw new Error("invalid-payload");
  }
  const raw = data as Record<string, unknown>;
  const category = parseSupportInquiryCategory(String(raw.category ?? ""));
  const content = validateSupportInquiryContent(
    String(raw.subject ?? ""),
    String(raw.body ?? ""),
  );
  return { category, ...content };
}


/** 관리자 답변 Callable 입력을 파싱합니다. */
export function parseReplySupportInquiryInput(data: unknown): {
  inquiryId: string;
  text: string;
  status?: SupportInquiryStatus;
} {
  if (typeof data !== "object" || data == null) {
    throw new Error("invalid-payload");
  }
  const raw = data as Record<string, unknown>;
  const inquiryId = String(raw.inquiryId ?? "").trim();
  if (inquiryId.length === 0) {
    throw new Error("inquiry-id-required");
  }
  const text = validateSupportInquiryReply(String(raw.text ?? ""));
  const statusRaw = String(raw.status ?? "").trim();
  const status =
    statusRaw === "closed" || statusRaw === "answered" || statusRaw === "open"
      ? (statusRaw as SupportInquiryStatus)
      : undefined;
  return { inquiryId, text, status };
}


/** Auth 이메일을 안전하게 읽습니다. */
export async function loadAuthEmail(uid: string): Promise<string> {
  const user = await admin.auth().getUser(uid);
  const email = user.email?.trim() ?? "";
  if (email.length === 0) {
    throw new Error("email-required");
  }
  return email;
}
