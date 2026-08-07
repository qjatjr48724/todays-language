import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/models/random_word_item.dart';
import 'package:mobile/services/random_word_repository.dart';


void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const sampleJson = '''
{
  "version": 1,
  "imagePromptTemplate": "Educational flashcard illustration of {conceptEn}.",
  "items": [
    {
      "id": "tree_01",
      "topicId": "DL-01",
      "conceptEn": "a tree",
      "words": {
        "KOR": { "word": "나무" },
        "JPN": { "word": "木", "reading": "き" },
        "USA": { "word": "tree" }
      },
      "meanings": {
        "ko": "나무",
        "en": "tree",
        "ja": "木"
      },
      "imageFile": null,
      "imagePrompt": "Educational flashcard illustration of a single tree."
    },
    {
      "id": "job_01",
      "topicId": "JOB-01",
      "conceptEn": "a job",
      "words": {
        "KOR": { "word": "직업" },
        "JPN": { "word": "職業", "reading": "しょくぎょう" },
        "USA": { "word": "job" }
      },
      "meanings": {
        "ko": "직업",
        "en": "job",
        "ja": "職業"
      }
    },
    {
      "id": "hi_01",
      "topicId": "DL-01",
      "conceptEn": "hi",
      "words": {
        "KOR": { "word": "안녕" },
        "JPN": { "word": "こんにちは" },
        "USA": { "word": "hi" }
      },
      "meanings": {
        "ko": "안녕",
        "en": "hi",
        "ja": "こんにちは"
      }
    }
  ]
}
''';

  test('loadAll parses tree_01 for all target languages', () async {
    final bundle = _FakeBundle({RandomWordRepository.assetPath: sampleJson});
    final repo = RandomWordRepository(bundle: bundle);

    final items = await repo.loadAll();
    expect(items, hasLength(3));
    final item = items.first;
    expect(item.id, 'tree_01');
    expect(item.topicId, 'DL-01');
    expect(item.surfaceFor('JPN')?.word, '木');
    expect(item.surfaceFor('JPN')?.reading, 'き');
    expect(item.surfaceFor('KOR')?.word, '나무');
    expect(item.surfaceFor('USA')?.word, 'tree');
    expect(item.meaningForLocale('ko'), '나무');
    expect(item.meaningForLocale('en'), 'tree');
    expect(item.imagePrompt, contains('tree'));
  });

  test('pickRandom returns an item from the pool', () async {
    final bundle = _FakeBundle({RandomWordRepository.assetPath: sampleJson});
    final repo = RandomWordRepository(bundle: bundle, random: _FixedRandom(0));
    final picked = await repo.pickRandom();
    expect(picked, isA<RandomWordItem>());
    expect(picked!.id, 'tree_01');
  });

  test('pickRandom with topicId stays inside that topic', () async {
    final bundle = _FakeBundle({RandomWordRepository.assetPath: sampleJson});
    final repo = RandomWordRepository(bundle: bundle, random: _FixedRandom(0));
    final picked = await repo.pickRandom(topicId: 'DL-01');
    expect(picked?.topicId, 'DL-01');
    expect(picked?.id, anyOf('tree_01', 'hi_01'));
  });

  test('pickRandom with unknown topic returns null', () async {
    final bundle = _FakeBundle({RandomWordRepository.assetPath: sampleJson});
    final repo = RandomWordRepository(bundle: bundle);
    final picked = await repo.pickRandom(topicId: 'DL-99');
    expect(picked, isNull);
  });

  test('listTopicIds uses curriculum order then extras', () async {
    final bundle = _FakeBundle({RandomWordRepository.assetPath: sampleJson});
    final repo = RandomWordRepository(bundle: bundle);
    final ids = await repo.listTopicIds();
    expect(ids, ['DL-01', 'JOB-01']);
  });

  test('app asset pool loads cleaned items', () async {
    final repo = RandomWordRepository();
    final items = await repo.loadAll();
    expect(items.length, 960);
    expect(items.any((e) => e.id == 'dl01_002'), isFalse);
    expect(
      items.any((e) => e.surfaceFor('KOR')?.word == '자기, 자신'),
      isTrue,
    );
  });
}


class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this._map);

  final Map<String, String> _map;

  @override
  Future<ByteData> load(String key) async {
    throw UnsupportedError('load not used');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final value = _map[key];
    if (value == null) {
      throw StateError('Missing asset $key');
    }
    return value;
  }
}


class _FixedRandom implements Random {
  _FixedRandom(this.value);

  final int value;

  @override
  int nextInt(int max) => value % max;

  @override
  bool nextBool() => false;

  @override
  double nextDouble() => 0;
}
