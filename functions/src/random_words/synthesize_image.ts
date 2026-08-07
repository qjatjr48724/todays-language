import * as admin from "firebase-admin";

import { buildRandomWordImageStoragePath } from "./image_path";


const OPENAI_IMAGES_URL = "https://api.openai.com/v1/images/generations";
const OPENAI_IMAGE_MODEL = process.env.OPENAI_IMAGE_MODEL ?? "gpt-image-1";


function getDefaultBucket() {
  return admin.storage().bucket();
}


function resolvePrompt(
  template: string,
  conceptEn: string,
  imagePrompt: string | null | undefined
): string {
  const fixed = imagePrompt?.trim();
  if (fixed) return fixed;
  const concept = conceptEn.trim() || "a simple everyday concept";
  return template.replace(/\{conceptEn\}/g, concept);
}


type OpenAiImageResponse = {
  data?: Array<{ b64_json?: string; url?: string }>;
  error?: { message?: string };
};


/** OpenAI Images → Storage PNG. 이미 있으면 재사용(force 아니면). */
export async function synthesizeRandomWordImageToStorage(params: {
  itemId: string;
  conceptEn: string;
  imagePrompt: string | null | undefined;
  promptTemplate: string;
  force?: boolean;
}): Promise<{ storagePath: string; reused: boolean }> {
  const storagePath = buildRandomWordImageStoragePath(params.itemId);
  const bucket = getDefaultBucket();
  const file = bucket.file(storagePath);

  if (!params.force) {
    const [exists] = await file.exists();
    if (exists) {
      return { storagePath, reused: true };
    }
  }

  const apiKey = process.env.OPENAI_API_KEY?.trim();
  if (!apiKey) {
    throw new Error("OPENAI_API_KEY is missing");
  }

  const prompt = resolvePrompt(
    params.promptTemplate,
    params.conceptEn,
    params.imagePrompt
  );

  const res = await fetch(OPENAI_IMAGES_URL, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${apiKey}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: OPENAI_IMAGE_MODEL,
      prompt,
      size: "1024x1024",
      quality: process.env.OPENAI_IMAGE_QUALITY ?? "medium",
      n: 1,
    }),
  });

  const rawText = await res.text();
  let parsed: OpenAiImageResponse;
  try {
    parsed = JSON.parse(rawText) as OpenAiImageResponse;
  } catch {
    throw new Error(`OpenAI images non-JSON status=${res.status}`);
  }

  if (!res.ok) {
    const msg = parsed.error?.message ?? rawText.slice(0, 300);
    throw new Error(`OpenAI images HTTP ${res.status}: ${msg}`);
  }

  const first = parsed.data?.[0];
  let buffer: Buffer;
  if (first?.b64_json) {
    buffer = Buffer.from(first.b64_json, "base64");
  } else if (first?.url) {
    const imgRes = await fetch(first.url);
    if (!imgRes.ok) {
      throw new Error(`image download HTTP ${imgRes.status}`);
    }
    buffer = Buffer.from(await imgRes.arrayBuffer());
  } else {
    throw new Error("OpenAI images empty data");
  }

  await file.save(buffer, {
    contentType: "image/png",
    resumable: false,
    metadata: {
      // 재생성 시 앱/CDN이 옛 이미지를 오래 붙잡지 않도록
      cacheControl: "public, max-age=3600",
    },
  });

  return { storagePath, reused: false };
}
