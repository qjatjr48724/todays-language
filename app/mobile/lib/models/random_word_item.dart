/// 랜덤 단어 풀 한 항목 — 대상 언어 표기 + UI 로케일 뜻.
class RandomWordItem {
  const RandomWordItem({
    required this.id,
    required this.conceptEn,
    required this.wordsByTarget,
    required this.meaningsByLocale,
    this.topicId,
    this.imageFile,
    this.imagePrompt,
    this.wordAudioPathByTarget = const {},
  });

  final String id;

  /// 커리큘럼 topicId (예: DL-01). 없으면 주제 미표시.
  final String? topicId;

  /// 이미지 프롬프트용 영어 개념 (예: a tree).
  final String conceptEn;

  /// alpha-3 → 표기 (`word`, 선택 `reading`).
  final Map<String, RandomWordSurface> wordsByTarget;

  /// UI locale (`ko`/`en`/`ja`) → 뜻.
  final Map<String, String> meaningsByLocale;

  /// 에셋/Storage 파일명. 없으면 플레이스홀더.
  final String? imageFile;

  /// OpenAI 이미지 생성용 확정 프롬프트 (사전 생성 파이프라인용).
  final String? imagePrompt;

  /// 대상 언어별 Storage 음성 경로 (없으면 듣기 비활성).
  final Map<String, String> wordAudioPathByTarget;


  RandomWordSurface? surfaceFor(String targetLanguageAlpha3) {
    final key = targetLanguageAlpha3.trim().toUpperCase();
    return wordsByTarget[key];
  }


  String meaningForLocale(String languageCode) {
    final code = languageCode.trim().toLowerCase();
    return meaningsByLocale[code] ??
        meaningsByLocale['ko'] ??
        meaningsByLocale['en'] ??
        '';
  }


  String? audioPathFor(String targetLanguageAlpha3) {
    final key = targetLanguageAlpha3.trim().toUpperCase();
    final path = wordAudioPathByTarget[key]?.trim();
    if (path == null || path.isEmpty) return null;
    return path;
  }
}


/// 대상 언어 표기.
class RandomWordSurface {
  const RandomWordSurface({
    required this.word,
    this.reading,
  });

  final String word;
  final String? reading;
}
