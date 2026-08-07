/// 랜덤 단어 이미지 경로 판별 (로컬 asset 파일명 vs Storage 상대 경로)
bool isRandomWordStorageImagePath(String? imageFile) {
  final file = imageFile?.trim();
  if (file == null || file.isEmpty) return false;
  return file.contains('/');
}
