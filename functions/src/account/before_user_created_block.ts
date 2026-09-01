import { beforeUserCreated, HttpsError } from "firebase-functions/v2/identity";

import {
  ACCOUNT_RECREATION_BLOCKED_MESSAGE,
  evaluateAccountRecreationBlock,
} from "./account_recreation_block";

/** 탈퇴 후 7일 이내 동일 이메일 재가입을 Auth 생성 전에 차단합니다. */
export const blockRecentAccountRecreation = beforeUserCreated(
  { region: "asia-northeast3" },
  async (event) => {
    const email = event.data?.email;
    if (!email) return;

    const evaluation = await evaluateAccountRecreationBlock(email);
    if (evaluation.blocked) {
      throw new HttpsError(
        "permission-denied",
        ACCOUNT_RECREATION_BLOCKED_MESSAGE,
      );
    }
  },
);
