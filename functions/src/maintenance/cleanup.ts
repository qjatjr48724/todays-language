import { onSchedule } from "firebase-functions/v2/scheduler";

import { db } from "../shared/firebase";

const GLOBAL_LEARNING_SET_OWNER = "global_learning_set_owner";

function todayKstYyyyMmDd(now = new Date()): string {
  const kst = new Date(now.getTime() + 9 * 60 * 60 * 1000);
  const y = kst.getUTCFullYear().toString().padStart(4, "0");
  const m = (kst.getUTCMonth() + 1).toString().padStart(2, "0");
  const d = kst.getUTCDate().toString().padStart(2, "0");
  return `${y}-${m}-${d}`;
}

/**
 * 레거시/미사용 문서 정리(스케줄).
 * - alpha-2 기반 글로벌 학습 세트 문서(예: 2026-04-09_ja_beginner) 삭제
 *
 * 주의: 앱/Functions에서 더 이상 참조하지 않는 문서만 대상으로 합니다.
 */
export const cleanupLegacyFirestoreDocs = onSchedule(
  {
    // 매일 KST 03:10에 정리 (트래픽 적은 시간대)
    schedule: "10 3 * * *",
    timeZone: "Asia/Seoul",
    region: "asia-northeast3",
    timeoutSeconds: 540,
    memory: "512MiB",
  },
  async () => {
    const todayKst = todayKstYyyyMmDd();
    console.log("[cleanupLegacyFirestoreDocs] start", { todayKst });

    // alpha-2 기반 글로벌 학습 세트 문서 정리
    // - Functions는 canonical alpha-3 docId만 사용하므로 alpha-2 문서는 미사용.
    const alpha2 = ["ja", "es", "en", "ko", "fr", "de", "zh"];
    for (const sub of ["daily_word_sets", "daily_sentence_sets"] as const) {
      try {
        const col = db
          .collection("users")
          .doc(GLOBAL_LEARNING_SET_OWNER)
          .collection(sub);

        for (;;) {
          const snap = await col.limit(400).get();
          if (snap.empty) break;

          const batch = db.batch();
          let delCount = 0;

          for (const d of snap.docs) {
            const id = d.id;
            // id 형식: YYYY-MM-DD_LANG_LEVEL
            const lower = id.toLowerCase();
            if (alpha2.some((a2) => lower.includes(`_${a2}_`))) {
              batch.delete(d.ref);
              delCount++;
            }
          }

          if (delCount === 0) break;
          await batch.commit();
          console.log("[cleanupLegacyFirestoreDocs] deleted alpha-2 docs", { sub, delCount });
        }
      } catch (e) {
        console.error("[cleanupLegacyFirestoreDocs] alpha-2 cleanup failed", { sub, e });
      }
    }

    console.log("[cleanupLegacyFirestoreDocs] done", { todayKst });
  }
);

