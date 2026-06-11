import { TextToSpeechClient } from "@google-cloud/text-to-speech";
import * as admin from "firebase-admin";

import { buildLearningAudioStoragePath } from "./audio_path";
import { resolveLearningAudioVoice } from "./language_config";

let ttsClient: TextToSpeechClient | null = null;

function getTtsClient(): TextToSpeechClient {
  if (!ttsClient) {
    ttsClient = new TextToSpeechClient();
  }
  return ttsClient;
}

function getDefaultBucket() {
  return admin.storage().bucket();
}


/** 텍스트를 TTS로 합성해 Storage에 저장하고 경로를 반환. 실패 시 null. */
export async function synthesizeLearningAudioToStorage(
  text: string,
  targetLanguage: string
): Promise<string | null> {
  const trimmed = text.trim();
  if (!trimmed) return null;

  const voice = resolveLearningAudioVoice(targetLanguage);
  if (!voice) {
    console.error(`[learning-audio] unsupported targetLanguage=${targetLanguage}`);
    return null;
  }

  const storagePath = buildLearningAudioStoragePath(targetLanguage, trimmed);
  const bucket = getDefaultBucket();
  const file = bucket.file(storagePath);

  try {
    const [exists] = await file.exists();
    if (exists) {
      return storagePath;
    }

    const client = getTtsClient();
    const [response] = await client.synthesizeSpeech({
      input: { text: trimmed },
      voice: {
        languageCode: voice.languageCode,
        name: voice.name,
      },
      audioConfig: {
        audioEncoding: "MP3",
        speakingRate: 0.95,
      },
    });

    const audio = response.audioContent;
    if (!audio || (typeof audio === "string" && audio.length === 0)) {
      console.error(`[learning-audio] empty audio for path=${storagePath}`);
      return null;
    }

    const buffer = typeof audio === "string" ? Buffer.from(audio, "base64") : Buffer.from(audio);
    await file.save(buffer, {
      contentType: "audio/mpeg",
      resumable: false,
      metadata: {
        cacheControl: "public, max-age=31536000",
      },
    });

    return storagePath;
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    console.error(`[learning-audio] synthesize failed path=${storagePath} msg=${msg}`);
    return null;
  }
}
