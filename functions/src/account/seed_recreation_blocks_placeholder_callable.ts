import { onCall } from "firebase-functions/v2/https";

import { assertAdminToolsUid } from "../admin/admin_tools_auth";
import {
  ACCOUNT_RECREATION_BLOCK_MS,
  ACCOUNT_RECREATION_BLOCKS_PLACEHOLDER_DOC_ID,
  recordAccountRecreationBlockDoc,
} from "./account_recreation_block";

/** TTL 정책 연결용 account_recreation_blocks 플레이스홀더 문서를 생성합니다(관리자 전용). */
export const seedAccountRecreationBlocksPlaceholder = onCall(
  { region: "asia-northeast3" },
  async (request): Promise<{ ok: true; docPath: string; expireAtIso: string }> => {
    assertAdminToolsUid(request.auth?.uid);

    const nowMs = Date.now();
    const blockedUntilMs = nowMs + ACCOUNT_RECREATION_BLOCK_MS;
    const ref = await recordAccountRecreationBlockDoc(
      ACCOUNT_RECREATION_BLOCKS_PLACEHOLDER_DOC_ID,
      nowMs,
      blockedUntilMs,
      { _placeholder: true },
    );

    return {
      ok: true,
      docPath: ref.path,
      expireAtIso: new Date(blockedUntilMs).toISOString(),
    };
  },
);
