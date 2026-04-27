import { onCall, HttpsError } from "firebase-functions/v2/https";

import { COUNTRY_CATALOG_V1, normalizeAlpha3 } from "./country_catalog";
import type { CountryMeta } from "./firestore";
import { publicCountriesRef } from "./firestore";
import { fetchFlagUrlFromDataGoKr } from "./data_go_kr";

/**
 * A) alpha-3 ↔ alpha-2 매핑 기반 국가 목록(Phase 1 seed)
 * - 앱은 Firestore에서 국가 목록을 읽음
 * - 국기 URL은 Phase 3에서 동기화(별도 스케줄/호출)로 채움
 */
export const seedCountryCatalog = onCall(
  { region: "asia-northeast3" },
  async (request): Promise<{ ok: true; count: number }> => {
    if (!request.auth) throw new HttpsError("unauthenticated", "로그인이 필요합니다.");
    const t0 = Date.now();
    const col = publicCountriesRef();
    const batch = col.firestore.batch();
    let count = 0;
    for (const item of COUNTRY_CATALOG_V1) {
      const alpha3 = normalizeAlpha3(item.alpha3);
      const doc = col.doc(alpha3);
      const data: CountryMeta = {
        alpha3,
        alpha2: item.alpha2.toUpperCase(),
        endonym: item.endonym,
        enabled: Boolean(item.enabled),
        updatedAtMs: t0,
      };
      batch.set(doc, data, { merge: true });
      count++;
    }
    await batch.commit();
    return { ok: true, count };
  }
);

/**
 * B) 국기 URL 동기화 (data.go.kr → Firestore 캐시)
 * - 외부 API 쿼터/비용/안정성 고려: 앱은 절대 직접 호출하지 않고, 서버에서 캐시를 채웁니다.
 */
export const syncCountryFlags = onCall(
  {
    region: "asia-northeast3",
    secrets: ["DATA_GO_KR_SERVICE_KEY"],
    timeoutSeconds: 60,
    memory: "256MiB",
  },
  async (request): Promise<{ ok: true; updated: number; attempted: number }> => {
    if (!request.auth) throw new HttpsError("unauthenticated", "로그인이 필요합니다.");

    const force = Boolean(request.data?.force);
    const nowMs = Date.now();
    const col = publicCountriesRef();

    let attempted = 0;
    let updated = 0;
    for (const item of COUNTRY_CATALOG_V1) {
      const alpha3 = normalizeAlpha3(item.alpha3);
      const docRef = col.doc(alpha3);
      const snap = await docRef.get();
      const cur = (snap.data() ?? {}) as Partial<CountryMeta>;
      const hasUrl = typeof cur.flagUrl === "string" && cur.flagUrl.length > 0;
      if (hasUrl && !force) continue;

      attempted++;
      try {
        const dl = await fetchFlagUrlFromDataGoKr(item.alpha2);
        await docRef.set(
          {
            flagUrl: dl,
            flagSource: "data_go_kr",
            updatedAtMs: nowMs,
          },
          { merge: true }
        );
        updated++;
      } catch (e) {
        console.error("[syncCountryFlags] failed", { alpha3, alpha2: item.alpha2, e });
      }
    }

    return { ok: true, updated, attempted };
  }
);

