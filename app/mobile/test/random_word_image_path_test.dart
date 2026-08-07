import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/random_word_image_path.dart';


void main() {
  test('slash 없는 파일명은 로컬 asset', () {
    expect(isRandomWordStorageImagePath('tree_01.png'), isFalse);
    expect(isRandomWordStorageImagePath(null), isFalse);
    expect(isRandomWordStorageImagePath(''), isFalse);
  });

  test('slash 포함 경로는 Storage', () {
    expect(
      isRandomWordStorageImagePath('random_words/images/dl01_001.png'),
      isTrue,
    );
  });
}
