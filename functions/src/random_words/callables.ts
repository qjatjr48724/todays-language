import { onCall, HttpsError } from "firebase-functions/v2/https";

import { assertAdminToolsUid } from "../admin/admin_tools_auth";
import { generateRandomWordImagesForTopic } from "./generate_topic_images";


/**
 * 랜덤 단어 주제 이미지 일괄 생성 (OpenAI → Storage).
 * - 관리자 UID / allowlist만
 * - 현재 topicId=DL-01 지원
 * - 클라이언트 타임아웃 대비 limit/offset 배치 권장
 */
export const generateRandomWordImages = onCall(
  {
    region: "asia-northeast3",
    secrets: ["OPENAI_API_KEY"],
    timeoutSeconds: 540,
    memory: "1GiB",
  },
  async (request) => {
    assertAdminToolsUid(request.auth?.uid);

    const dev = Boolean(request.data?.dev);
    if (!dev) {
      throw new HttpsError("failed-precondition", "dev flag is required");
    }

    const topicId = (request.data?.topicId as string | undefined)?.trim();
    if (!topicId) {
      throw new HttpsError("invalid-argument", "topicId is required");
    }

    const force = Boolean(request.data?.force);
    const missingOnly = request.data?.missingOnly !== false;
    const limitRaw = request.data?.limit;
    const offsetRaw = request.data?.offset;
    const limit =
      limitRaw == null ? undefined : Number.parseInt(String(limitRaw), 10);
    const offset =
      offsetRaw == null ? 0 : Number.parseInt(String(offsetRaw), 10);

    if (limit != null && !Number.isFinite(limit)) {
      throw new HttpsError("invalid-argument", "limit must be a number");
    }
    if (!Number.isFinite(offset) || offset < 0) {
      throw new HttpsError("invalid-argument", "offset must be >= 0");
    }

    console.log("[generateRandomWordImages] start", {
      uid: request.auth!.uid,
      topicId,
      force,
      missingOnly,
      limit,
      offset,
    });
    const t0 = Date.now();
    try {
      const summary = await generateRandomWordImagesForTopic({
        topicId,
        force,
        limit,
        offset,
        missingOnly,
      });
      console.log("[generateRandomWordImages] done", {
        elapsedMs: Date.now() - t0,
        topicId: summary.topicId,
        total: summary.total,
        generated: summary.generated,
        reused: summary.reused,
        failed: summary.failed.length,
      });
      return { ok: true as const, ...summary };
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      if (msg.startsWith("unsupported topicId=")) {
        throw new HttpsError("invalid-argument", msg);
      }
      throw e;
    }
  }
);
