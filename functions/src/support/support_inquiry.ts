/** 문의 카테고리 — 웹·앱·관리자 공통 */
export const SUPPORT_INQUIRY_CATEGORIES = [
  "bug",
  "account",
  "suggestion",
  "other",
] as const;

export type SupportInquiryCategory = (typeof SUPPORT_INQUIRY_CATEGORIES)[number];

export type SupportInquiryStatus = "open" | "answered" | "closed";

export type SupportMessageAuthorType = "user" | "admin";

export const SUPPORT_INQUIRIES_COLLECTION = "support_inquiries";

export const SUPPORT_INQUIRY_SUBJECT_MAX = 100;

export const SUPPORT_INQUIRY_BODY_MAX = 2000;

export const SUPPORT_INQUIRY_REPLY_MAX = 2000;


export type SupportInquiryRecord = {
  uid: string;
  email: string;
  displayName: string;
  category: SupportInquiryCategory;
  subject: string;
  body: string;
  status: SupportInquiryStatus;
  createdAtMs: number;
  updatedAtMs: number;
  answeredAtMs?: number;
};

export type SupportInquiryListItem = SupportInquiryRecord & {
  inquiryId: string;
};


export type SubmitSupportInquiryInput = {
  category: string;
  subject: string;
  body: string;
};


export type ReplySupportInquiryInput = {
  inquiryId: string;
  text: string;
  status?: SupportInquiryStatus;
};


/** 카테고리 문자열을 검증합니다. */
export function parseSupportInquiryCategory(raw: string): SupportInquiryCategory {
  const value = raw.trim();
  if ((SUPPORT_INQUIRY_CATEGORIES as readonly string[]).includes(value)) {
    return value as SupportInquiryCategory;
  }
  throw new Error("invalid-category");
}


/** 문의 제목·본문을 검증합니다. */
export function validateSupportInquiryContent(subject: string, body: string): {
  subject: string;
  body: string;
} {
  const trimmedSubject = subject.trim();
  const trimmedBody = body.trim();
  if (trimmedSubject.length === 0) {
    throw new Error("subject-required");
  }
  if (trimmedSubject.length > SUPPORT_INQUIRY_SUBJECT_MAX) {
    throw new Error("subject-too-long");
  }
  if (trimmedBody.length === 0) {
    throw new Error("body-required");
  }
  if (trimmedBody.length > SUPPORT_INQUIRY_BODY_MAX) {
    throw new Error("body-too-long");
  }
  return { subject: trimmedSubject, body: trimmedBody };
}


/** 관리자 답변 본문을 검증합니다. */
export function validateSupportInquiryReply(text: string): string {
  const trimmed = text.trim();
  if (trimmed.length === 0) {
    throw new Error("reply-required");
  }
  if (trimmed.length > SUPPORT_INQUIRY_REPLY_MAX) {
    throw new Error("reply-too-long");
  }
  return trimmed;
}


/** 관리자 답변 후 상태를 결정합니다. */
export function resolveInquiryStatusAfterReply(
  requested: SupportInquiryStatus | undefined,
): SupportInquiryStatus {
  if (requested === "closed") {
    return "closed";
  }
  return "answered";
}
