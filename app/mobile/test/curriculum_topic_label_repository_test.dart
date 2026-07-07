import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/curriculum_topic_label_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CurriculumTopicLabelRepository', () {
    late CurriculumTopicLabelRepository repo;

    setUp(() {
      repo = CurriculumTopicLabelRepository();
    });

    test('loadCatalog는 50개 topicId를 반환한다', () async {
      final catalog = await repo.loadCatalog();
      expect(catalog.length, 50);
      expect(catalog.containsKey('DL-11'), isTrue);
      expect(catalog.containsKey('SC-10'), isTrue);
    });

    test('labelForTopicId는 locale에 맞는 주제명을 반환한다', () async {
      expect(await repo.labelForTopicId('DL-11', 'ko'), '시간');
      expect(await repo.labelForTopicId('DL-11', 'en'), 'Time');
      expect(await repo.labelForTopicId('DL-11', 'ja'), '時間');
    });

    test('labelForLearningDay는 일차에 맞는 주제명을 반환한다', () async {
      expect(
        CurriculumTopicLabelRepository.topicIdForLearningDay(11),
        'DL-11',
      );
      expect(await repo.labelForLearningDay(11, 'ko'), '시간');
      expect(await repo.labelForLearningDay(50, 'en'), 'Career & counseling');
    });

    test('알 수 없는 topicId는 id를 그대로 반환한다', () async {
      expect(await repo.labelForTopicId('XX-99', 'en'), 'XX-99');
    });

    test('미지원 locale은 en으로 fallback한다', () async {
      expect(await repo.labelForTopicId('DL-11', 'fr'), 'Time');
    });
  });
}
