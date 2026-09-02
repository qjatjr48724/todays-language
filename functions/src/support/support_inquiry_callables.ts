import { onCall, HttpsError } from "firebase-functions/v2/https";

import { assertAdminToolsUid } from "../admin/admin_tools_auth";
import {
  createSupportInquiry,
  loadAuthEmail,
  parseReplySupportInquiryInput,
  parseSubmitSupportInquiryInput,
  replySupportInquiry,
} from "./support_inquiry_service";
import {
  SUPPORT_INQUIRIES_COLLECTION,
  type SupportInquiryListItem,
  type SupportInquiryRecord,
} from "./support_inquiry";
import { db } from "../shared/firebase";


function mapSubmitError(err: unknown): never {
  const message = err instanceof Error ? err.message : String(err);
  switch (message) {
    case "invalid-category":
      throw new HttpsError("invalid-argument", "유효하지 않은 문의 유형입니다.");
    case "subject-required":
      throw new HttpsError("invalid-argument", "제목을 입력해 주세요.");
    case "subject-too-long":
      throw new HttpsError("invalid-argument", "제목이 너무 깁니다.");
    case "body-required":
      throw new HttpsError("invalid-argument", "문의 내용을 입력해 주세요.");
    case "body-too-long":
      throw new HttpsError("invalid-argument", "문의 내용이 너무 깁니다.");
    case "email-required":
      throw new HttpsError("failed-precondition", "이메일 계정으로만 문의할 수 있습니다.");
    default:
      throw new HttpsError("invalid-argument", "요청 형식이 올바르지 않습니다.");
  }
}


function mapReplyError(err: unknown): never {
  const message = err instanceof Error ? err.message : String(err);
  switch (message) {
    case "inquiry-not-found":
      throw new HttpsError("not-found", "문의를 찾을 수 없습니다.");
    case "reply-required":
      throw new HttpsError("invalid-argument", "답변 내용을 입력해 주세요.");
    case "reply-too-long":
      throw new HttpsError("invalid-argument", "답변 내용이 너무 깁니다.");
    default:
      throw new HttpsError("invalid-argument", "요청 형식이 올바르지 않습니다.");
  }
}


/** 로그인 사용자 — 문의 등록 */
export const submitSupportInquiry = onCall(
  { region: "asia-northeast3" },
  async (request): Promise<{ inquiryId: string }> => {
    if (!request.auth?.uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    try {
      const parsed = parseSubmitSupportInquiryInput(request.data);
      const email = await loadAuthEmail(request.auth.uid);
      const displayName = request.auth.token.name ?? "";
      return await createSupportInquiry({
        uid: request.auth.uid,
        email,
        displayName,
        category: parsed.category,
        subject: parsed.subject,
        body: parsed.body,
      });
    } catch (err) {
      if (err instanceof HttpsError) throw err;
      mapSubmitError(err);
    }
  },
);


/** 관리자 — 문의 목록 */
export const listSupportInquiriesAdmin = onCall(
  { region: "asia-northeast3" },
  async (request): Promise<{ items: SupportInquiryListItem[] }> => {
    assertAdminToolsUid(request.auth?.uid);
    const limitRaw = Number((request.data as { limit?: number })?.limit ?? 50);
    const limit = Number.isFinite(limitRaw)
      ? Math.min(Math.max(Math.floor(limitRaw), 1), 100)
      : 50;

    const snap = await db
      .collection(SUPPORT_INQUIRIES_COLLECTION)
      .orderBy("createdAtMs", "desc")
      .limit(limit)
      .get();

    const items: SupportInquiryListItem[] = snap.docs.map((doc) => ({
      inquiryId: doc.id,
      ...(doc.data() as SupportInquiryRecord),
    }));

    return { items };
  },
);


/** 관리자 — 문의 상세(메시지 포함) */
export const getSupportInquiryAdmin = onCall(
  { region: "asia-northeast3" },
  async (request): Promise<{
    inquiry: SupportInquiryRecord & { inquiryId: string };
    messages: Array<{ messageId: string; authorType: string; authorUid: string; text: string; createdAtMs: number }>;
  }> => {
    assertAdminToolsUid(request.auth?.uid);

    const inquiryId = String((request.data as { inquiryId?: string })?.inquiryId ?? "").trim();
    if (inquiryId.length === 0) {
      throw new HttpsError("invalid-argument", "문의 ID가 필요합니다.");
    }

    const inquiryRef = db.collection(SUPPORT_INQUIRIES_COLLECTION).doc(inquiryId);
    const inquirySnap = await inquiryRef.get();
    if (!inquirySnap.exists) {
      throw new HttpsError("not-found", "문의를 찾을 수 없습니다.");
    }

    const messagesSnap = await inquiryRef
      .collection("messages")
      .orderBy("createdAtMs", "asc")
      .get();

    return {
      inquiry: {
        inquiryId,
        ...(inquirySnap.data() as SupportInquiryRecord),
      },
      messages: messagesSnap.docs.map((doc) => ({
        messageId: doc.id,
        ...(doc.data() as {
          authorType: string;
          authorUid: string;
          text: string;
          createdAtMs: number;
        }),
      })),
    };
  },
);


/** 관리자 — 답변 등록 */
export const replySupportInquiryAdmin = onCall(
  { region: "asia-northeast3" },
  async (request): Promise<{ ok: true }> => {
    assertAdminToolsUid(request.auth?.uid);

    try {
      const parsed = parseReplySupportInquiryInput(request.data);
      return await replySupportInquiry({
        inquiryId: parsed.inquiryId,
        adminUid: request.auth!.uid,
        text: parsed.text,
        status: parsed.status,
      });
    } catch (err) {
      if (err instanceof HttpsError) throw err;
      mapReplyError(err);
    }
  },
);
