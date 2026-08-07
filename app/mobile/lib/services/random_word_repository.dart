import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/random_word_item.dart';
import 'curriculum_topic_label_repository.dart';


/// 랜덤 단어 풀 — [assets/random_words/random_word_pool.json].
class RandomWordRepository {
  RandomWordRepository({
    AssetBundle? bundle,
    Random? random,
  })  : _bundle = bundle ?? rootBundle,
        _random = random ?? Random();

  final AssetBundle _bundle;
  final Random _random;

  static const String assetPath = 'assets/random_words/random_word_pool.json';

  List<RandomWordItem>? _cache;
  String? _imagePromptTemplate;


  String? get imagePromptTemplate => _imagePromptTemplate;


  Future<List<RandomWordItem>> loadAll() async {
    if (_cache != null) return _cache!;
    final raw = await _bundle.loadString(assetPath);
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('random_word_pool root must be object');
    }
    _imagePromptTemplate = decoded['imagePromptTemplate']?.toString();
    final itemsRaw = decoded['items'];
    if (itemsRaw is! List) {
      throw const FormatException('random_word_pool items must be list');
    }
    final items = <RandomWordItem>[];
    for (final entry in itemsRaw) {
      if (entry is! Map) continue;
      final parsed = _parseItem(Map<String, dynamic>.from(entry));
      if (parsed != null) items.add(parsed);
    }
    _cache = items;
    return items;
  }


  /// 직전에 뽑은 id와 겹치지 않게 한 건 선택.
  /// [topicId]가 있으면 해당 주제만, null/빈 값이면 전체 풀.
  Future<RandomWordItem?> pickRandom({
    String? excludeId,
    String? topicId,
  }) async {
    final items = await loadAll();
    final filtered = _filterByTopic(items, topicId);
    if (filtered.isEmpty) return null;
    if (filtered.length == 1) return filtered.first;
    final pool = excludeId == null
        ? filtered
        : filtered.where((e) => e.id != excludeId).toList();
    final use = pool.isEmpty ? filtered : pool;
    return use[_random.nextInt(use.length)];
  }


  /// 풀에 실제 존재하는 topicId 목록 (커리큘럼 일차 순 → 나머지).
  Future<List<String>> listTopicIds() async {
    final items = await loadAll();
    final present = <String>{};
    for (final item in items) {
      final id = item.topicId?.trim();
      if (id == null || id.isEmpty) continue;
      present.add(id);
    }
    if (present.isEmpty) return const [];

    final ordered = <String>[];
    for (final id in CurriculumTopicLabelRepository.topicIdByLearningDay) {
      if (present.remove(id)) {
        ordered.add(id);
      }
    }
    final rest = present.toList()..sort();
    ordered.addAll(rest);
    return ordered;
  }


  List<RandomWordItem> _filterByTopic(
    List<RandomWordItem> items,
    String? topicId,
  ) {
    final key = topicId?.trim();
    if (key == null || key.isEmpty) return items;
    return items
        .where((e) => (e.topicId?.trim() ?? '') == key)
        .toList();
  }


  RandomWordItem? _parseItem(Map<String, dynamic> json) {
    final id = json['id']?.toString().trim();
    if (id == null || id.isEmpty) return null;
    final topicRaw = json['topicId']?.toString().trim();
    final topicId =
        (topicRaw == null || topicRaw.isEmpty) ? null : topicRaw;
    final conceptEn = json['conceptEn']?.toString().trim() ?? id;
    final wordsRaw = json['words'];
    final wordsByTarget = <String, RandomWordSurface>{};
    if (wordsRaw is Map) {
      wordsRaw.forEach((key, value) {
        if (value is! Map) return;
        final word = value['word']?.toString().trim();
        if (word == null || word.isEmpty) return;
        final reading = value['reading']?.toString().trim();
        wordsByTarget[key.toString().trim().toUpperCase()] = RandomWordSurface(
          word: word,
          reading: (reading == null || reading.isEmpty) ? null : reading,
        );
      });
    }
    if (wordsByTarget.isEmpty) return null;

    final meaningsRaw = json['meanings'];
    final meanings = <String, String>{};
    if (meaningsRaw is Map) {
      meaningsRaw.forEach((key, value) {
        final text = value?.toString().trim();
        if (text == null || text.isEmpty) return;
        meanings[key.toString().trim().toLowerCase()] = text;
      });
    }

    final imageFile = json['imageFile']?.toString().trim();
    final imagePrompt = json['imagePrompt']?.toString().trim();

    final audioRaw = json['wordAudioPath'];
    final audioByTarget = <String, String>{};
    if (audioRaw is Map) {
      audioRaw.forEach((key, value) {
        final path = value?.toString().trim();
        if (path == null || path.isEmpty) return;
        audioByTarget[key.toString().trim().toUpperCase()] = path;
      });
    }

    return RandomWordItem(
      id: id,
      topicId: topicId,
      conceptEn: conceptEn,
      wordsByTarget: wordsByTarget,
      meaningsByLocale: meanings,
      imageFile: (imageFile == null || imageFile.isEmpty) ? null : imageFile,
      imagePrompt: (imagePrompt == null || imagePrompt.isEmpty)
          ? null
          : imagePrompt,
      wordAudioPathByTarget: audioByTarget,
    );
  }
}
