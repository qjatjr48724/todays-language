import {
  ACCOUNT_RECREATION_BLOCK_MS,
  ACCOUNT_RECREATION_BLOCKS_PLACEHOLDER_DOC_ID,
  recordAccountRecreationBlockDoc,
} from "../account/account_recreation_block";

/** TTL 드롭다운용 account_recreation_blocks 플레이스홀더 문서를 생성합니다. */
async function main(): Promise<void> {
  const nowMs = Date.now();
  const blockedUntilMs = nowMs + ACCOUNT_RECREATION_BLOCK_MS;

  const ref = await recordAccountRecreationBlockDoc(
    ACCOUNT_RECREATION_BLOCKS_PLACEHOLDER_DOC_ID,
    nowMs,
    blockedUntilMs,
    { _placeholder: true },
  );

  console.log(`[seed] created ${ref.path}`);
  console.log(`[seed] expireAt=${new Date(blockedUntilMs).toISOString()}`);
}

main().catch((err) => {
  console.error("[seed] failed", err);
  process.exit(1);
});
