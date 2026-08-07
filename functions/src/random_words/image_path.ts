/** 랜덤 단어 이미지 Storage 경로 규칙 */
const STORAGE_PREFIX = "random_words/images";


/** 예: random_words/images/dl01_001.png */
export function buildRandomWordImageStoragePath(itemId: string): string {
  const id = itemId.trim();
  return `${STORAGE_PREFIX}/${id}.png`;
}
