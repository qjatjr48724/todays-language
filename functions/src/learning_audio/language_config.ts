/** 학습 언어(alpha-3) → Cloud TTS 음성 설정 */

export type LearningAudioVoiceConfig = {
  languageCode: string;
  name: string;
};

const VOICE_BY_TARGET: Record<string, LearningAudioVoiceConfig> = {
  KOR: { languageCode: "ko-KR", name: "ko-KR-Wavenet-A" },
  USA: { languageCode: "en-US", name: "en-US-Wavenet-C" },
  JPN: { languageCode: "ja-JP", name: "ja-JP-Wavenet-A" },
};


export function resolveLearningAudioVoice(targetLanguage: string): LearningAudioVoiceConfig | null {
  const key = targetLanguage.trim().toUpperCase();
  return VOICE_BY_TARGET[key] ?? null;
}
