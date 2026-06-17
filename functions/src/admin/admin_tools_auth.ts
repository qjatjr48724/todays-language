import { HttpsError } from "firebase-functions/v2/https";

/** 앱 `AdminToolsScreen.testAdminUid`와 동기 */
export const ADMIN_TOOLS_UID = "WhyAQoWSP4Ociipn0HQtxCwQboN2";

export function isAdminToolsUid(uid: string): boolean {
  if ((process.env.FUNCTIONS_EMULATOR ?? "") === "true") {
    return true;
  }
  if (uid === ADMIN_TOOLS_UID) {
    return true;
  }
  const allowRaw = (process.env.DEV_WARMUP_UID_ALLOWLIST ?? "").trim();
  const allowed = new Set(
    allowRaw
      .split(",")
      .map((s) => s.trim())
      .filter((s) => s.length > 0)
  );
  return allowed.has(uid);
}

export function assertAdminToolsUid(uid: string | undefined): void {
  if (!uid) {
    throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
  }
  if (!isAdminToolsUid(uid)) {
    throw new HttpsError("permission-denied", "관리자 권한이 없습니다.");
  }
}
