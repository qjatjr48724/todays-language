import { onCall } from "firebase-functions/v2/https";

import {
  clampLearningDay,
  normalizeCurriculumLanguageCode,
} from "../curriculum/curriculum_state";
import { db } from "../shared/firebase";
import {
  ADMIN_CURRICULUM_PREVIEW_DAY_BY_LANGUAGE_FIELD,
  parseAdminPreviewDayByLanguage,
} from "./curriculum_preview";
import { assertAdminToolsUid } from "./admin_tools_auth";

/** 관리자: 지정 언어의 커리큘럼 테스트 일차 설정(해제 시 learningDay null) */
export const setAdminCurriculumPreviewDay = onCall(
  { region: "asia-northeast3" },
  async (
    request
  ): Promise<{
    ok: true;
    targetLanguage: string;
    previewLearningDay: number | null;
  }> => {
    assertAdminToolsUid(request.auth?.uid);

    const rawDay = request.data?.learningDay;
    const clear = rawDay === null || rawDay === undefined;
    const learningDay = clear
      ? null
      : clampLearningDay(
          typeof rawDay === "number" ? rawDay : Number.parseInt(String(rawDay), 10)
        );

    const userSnap = await db.collection("users").doc(request.auth!.uid).get();
    const userData = (userSnap.data() ?? {}) as Record<string, unknown>;
    const tl = normalizeCurriculumLanguageCode(
      (request.data?.targetLanguage as string | undefined) ??
        (userData.targetLanguage as string | undefined) ??
        "JPN"
    );

    const byLang = parseAdminPreviewDayByLanguage(
      userData[ADMIN_CURRICULUM_PREVIEW_DAY_BY_LANGUAGE_FIELD]
    );
    if (learningDay == null) {
      delete byLang[tl];
    } else {
      byLang[tl] = learningDay;
    }

    await db.collection("users").doc(request.auth!.uid).set(
      {
        [ADMIN_CURRICULUM_PREVIEW_DAY_BY_LANGUAGE_FIELD]: byLang,
        updatedAt: new Date(),
      },
      { merge: true }
    );

    return {
      ok: true,
      targetLanguage: tl,
      previewLearningDay: learningDay,
    };
  }
);
