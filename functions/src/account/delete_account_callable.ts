import { onCall, HttpsError } from "firebase-functions/v2/https";

import { deleteUserAccount } from "./delete_user_data";

/** 회원 탈퇴 — 본인 Firestore·채팅·Auth 계정 일괄 삭제 (클라이언트 재인증 후 호출). */
export const deleteAccount = onCall(
  { region: "asia-northeast3" },
  async (request): Promise<{ ok: true }> => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    const uid = request.auth.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    }

    try {
      await deleteUserAccount(uid);
      return { ok: true };
    } catch (err) {
      const message = err instanceof Error ? err.message : String(err);
      console.error("[deleteAccount] failed", { uid, message });
      throw new HttpsError("internal", "계정 삭제에 실패했습니다. 잠시 후 다시 시도해 주세요.");
    }
  },
);
