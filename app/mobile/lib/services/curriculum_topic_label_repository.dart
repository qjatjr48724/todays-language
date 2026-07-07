import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../models/certification.dart';

/// 커리큘럼 주제명 카탈로그 — [assets/curriculum/curriculum_topic_labels.json].
///
/// topicId(`DL-11` 등)별 ko/en/ja 주제명을 로드하고, 앱 UI 로컬에 맞게 반환합니다.
class CurriculumTopicLabelRepository {
  CurriculumTopicLabelRepository({AssetBundle? bundle})
      : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  static const String assetPath = 'assets/curriculum/curriculum_topic_labels.json';

  /// Functions `CURRICULUM_CORE_V1_DAYS` learningDay 1..50 순서와 동기.
  static const List<String> topicIdByLearningDay = [
    'DL-01',
    'DL-02',
    'DL-03',
    'DL-04',
    'DL-05',
    'DL-06',
    'DL-07',
    'DL-08',
    'DL-09',
    'DL-10',
    'DL-11',
    'DL-12',
    'DL-13',
    'DL-14',
    'DL-15',
    'DL-16',
    'DL-17',
    'DL-18',
    'DL-19',
    'DL-20',
    'TM-01',
    'TM-11',
    'TM-03',
    'TM-05',
    'TM-06',
    'TM-07',
    'TM-08',
    'TM-09',
    'TM-10',
    'TR-01',
    'TR-02',
    'TR-03',
    'TR-04',
    'TR-05',
    'TR-06',
    'TR-07',
    'TR-08',
    'TR-09',
    'TR-11',
    'TR-12',
    'SC-01',
    'SC-02',
    'SC-03',
    'SC-04',
    'SC-05',
    'SC-06',
    'SC-07',
    'SC-08',
    'SC-09',
    'SC-10',
  ];

  Map<String, LocalizedCertificationText>? _cache;


  /// learningDay(1..50)에 해당하는 topicId.
  static String? topicIdForLearningDay(int learningDay) {
    if (learningDay < 1 || learningDay > topicIdByLearningDay.length) {
      return null;
    }
    return topicIdByLearningDay[learningDay - 1];
  }


  /// JSON 카탈로그를 메모리에 로드합니다.
  Future<Map<String, LocalizedCertificationText>> loadCatalog({
    bool forceReload = false,
  }) async {
    if (!forceReload && _cache != null) return _cache!;

    final raw = await _bundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'curriculum_topic_labels.json root must be an object',
      );
    }

    final topics = <String, LocalizedCertificationText>{};
    for (final entry in decoded.entries) {
      final topicId = entry.key.trim();
      if (topicId.isEmpty) continue;
      final value = entry.value;
      if (value is! Map<String, dynamic>) continue;
      topics[topicId] = LocalizedCertificationText.fromJson(value);
    }

    _cache = topics;
    return topics;
  }


  /// topicId에 해당하는 주제명 — 미지원 locale은 en fallback.
  Future<String> labelForTopicId(
    String topicId,
    String languageCode,
  ) async {
    final topics = await loadCatalog();
    final text = topics[topicId.trim()];
    if (text == null) return topicId.trim();
    return text.resolve(languageCode);
  }


  /// [BuildContext]의 UI 로컬에 맞는 주제명을 반환합니다.
  Future<String> labelForTopicIdFromContext(
    BuildContext context,
    String topicId,
  ) {
    return labelForTopicId(topicId, Localizations.localeOf(context).languageCode);
  }


  /// learningDay(1..50) 주제명 — 미지원 locale은 en fallback.
  Future<String?> labelForLearningDay(
    int learningDay,
    String languageCode,
  ) async {
    final topicId = topicIdForLearningDay(learningDay);
    if (topicId == null) return null;
    return labelForTopicId(topicId, languageCode);
  }


  /// [BuildContext] UI 로컬에 맞는 learningDay 주제명.
  Future<String?> labelForLearningDayFromContext(
    BuildContext context,
    int learningDay,
  ) {
    return labelForLearningDay(
      learningDay,
      Localizations.localeOf(context).languageCode,
    );
  }
}