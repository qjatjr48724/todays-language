import { onSchedule } from "firebase-functions/v2/scheduler";

import { COUNTRY_CATALOG_V1, normalizeAlpha3 } from "./country_catalog";
import type { CountryMeta } from "./firestore";
import { publicCountriesRef } from "./firestore";
import { fetchFlagUrlFromDataGoKr } from "./data_go_kr";

/**
 * Phase 3 운영용: 매일 1회 캐시 갱신
 * - enabled/disabled 포함 V1 카탈로그에 대해서만 동기화(확장 시 카탈로그를 늘리면 됨)
 */
export const scheduledSyncCountryFlags = onSchedule(
  {
    schedule: "0 4 * * *",
    timeZone: "Asia/Seoul",
    region: "asia-northeast3",
    secrets: ["DATA_GO_KR_SERVICE_KEY"],
    timeoutSeconds: 180,
    memory: "256MiB",
  },
  async () => {
    const nowMs = Date.now();
    const col = publicCountriesRef();
    for (const item of COUNTRY_CATALOG_V1) {
      const alpha3 = normalizeAlpha3(item.alpha3);
      const docRef = col.doc(alpha3);
      try {
        const dl = await fetchFlagUrlFromDataGoKr(item.alpha2);
        await docRef.set(
          {
            alpha3,
            alpha2: item.alpha2.toUpperCase(),
            endonym: item.endonym,
            enabled: Boolean(item.enabled),
            flagUrl: dl,
            flagSource: "data_go_kr",
            updatedAtMs: nowMs,
          } satisfies CountryMeta,
          { merge: true }
        );
      } catch (e) {
        console.error("[scheduledSyncCountryFlags] failed", { alpha3, alpha2: item.alpha2, e });
      }
    }
  }
);

