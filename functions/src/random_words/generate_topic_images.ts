import { DL01_IMAGE_ITEMS, DL01_IMAGE_PROMPT_TEMPLATE } from "./dl01_catalog";
import { synthesizeRandomWordImageToStorage } from "./synthesize_image";


export type GenerateTopicImagesResult = {
  topicId: string;
  total: number;
  generated: number;
  reused: number;
  failed: Array<{ id: string; error: string }>;
  paths: Array<{ id: string; storagePath: string; reused: boolean }>;
};


function catalogForTopic(topicId: string): {
  promptTemplate: string;
  items: Array<{ id: string; conceptEn: string; imagePrompt: string | null }>;
} | null {
  const id = topicId.trim().toUpperCase();
  if (id === "DL-01") {
    return {
      promptTemplate: DL01_IMAGE_PROMPT_TEMPLATE,
      items: DL01_IMAGE_ITEMS,
    };
  }
  return null;
}


/**
 * 주제별 랜덤 단어 이미지를 Storage에 생성(현재 DL-01만).
 * - missingOnly(기본 true): 없는 파일만 최대 limit개 생성. 있으면 건너뜀.
 * - missingOnly false: offset~offset+limit 구간을 순서대로 처리(있으면 reuse).
 */
export async function generateRandomWordImagesForTopic(params: {
  topicId: string;
  force?: boolean;
  limit?: number;
  offset?: number;
  missingOnly?: boolean;
}): Promise<GenerateTopicImagesResult> {
  const catalog = catalogForTopic(params.topicId);
  if (!catalog) {
    throw new Error(`unsupported topicId=${params.topicId}`);
  }

  const missingOnly = params.missingOnly !== false;
  const force = params.force === true;
  const offset = Math.max(0, params.offset ?? 0);
  const limit = params.limit != null ? Math.max(0, params.limit) : undefined;

  const slice =
    missingOnly
      ? catalog.items
      : limit == null
        ? catalog.items.slice(offset)
        : catalog.items.slice(offset, offset + limit);

  const paths: GenerateTopicImagesResult["paths"] = [];
  const failed: GenerateTopicImagesResult["failed"] = [];
  let generated = 0;
  let reused = 0;

  for (const item of slice) {
    if (missingOnly && limit != null && generated >= limit) {
      break;
    }

    try {
      const result = await synthesizeRandomWordImageToStorage({
        itemId: item.id,
        conceptEn: item.conceptEn,
        imagePrompt: item.imagePrompt,
        promptTemplate: catalog.promptTemplate,
        force,
      });

      if (result.reused) {
        reused += 1;
        if (missingOnly && !force) {
          continue;
        }
      } else {
        generated += 1;
      }

      paths.push({
        id: item.id,
        storagePath: result.storagePath,
        reused: result.reused,
      });
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      failed.push({ id: item.id, error: msg });
      console.error(`[random-word-image] failed id=${item.id} msg=${msg}`);
      if (missingOnly && limit != null && generated + failed.length >= limit) {
        break;
      }
    }
  }

  return {
    topicId: params.topicId.trim().toUpperCase(),
    total: paths.length + failed.length,
    generated,
    reused,
    failed,
    paths,
  };
}
