import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/services/certification_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CertificationRepository', () {
    late CertificationRepository repo;

    setUp(() {
      repo = CertificationRepository();
    });

    test('loadCatalog는 JPN·USA·KOR 언어 그룹을 반환', () async {
      final catalog = await repo.loadCatalog();
      expect(catalog.languages.length, 3);
      expect(
        catalog.languages.map((e) => e.languageAlpha3).toList(),
        ['JPN', 'USA', 'KOR'],
      );
    });

    test('JPN 그룹에 JLPT가 포함된다', () async {
      final group = await repo.groupForLanguage('JPN');
      expect(group, isNotNull);
      expect(group!.certifications.length, 1);
      expect(group.certifications.first.id, 'jlpt');
      expect(group.certifications.first.name, 'JLPT');
    });

    test('USA 그룹에 TOEIC·TOEFL·IELTS가 포함된다', () async {
      final group = await repo.groupForLanguage('USA');
      expect(group, isNotNull);
      final ids = group!.certifications.map((e) => e.id).toList();
      expect(ids, ['toeic', 'toefl', 'ielts']);
    });

    test('KOR 그룹에 TOPIK·KLAT가 포함된다', () async {
      final group = await repo.groupForLanguage('KOR');
      expect(group, isNotNull);
      final ids = group!.certifications.map((e) => e.id).toList();
      expect(ids, ['topik', 'klat']);
    });

    test('findById로 자격증 상세를 조회한다', () async {
      final topik = await repo.findById('topik');
      expect(topik, isNotNull);
      expect(topik!.officialUrl, contains('topik.go.kr'));
      expect(topik.summaryForLocale('ko'), isNotEmpty);
    });

    test('localized summary는 locale에 맞게 반환', () async {
      final jlpt = await repo.findById('jlpt');
      expect(jlpt, isNotNull);
      expect(jlpt!.summaryForLocale('ko'), contains('일본어'));
      expect(jlpt.summaryForLocale('ja'), contains('日本語'));
    });
  });
}
