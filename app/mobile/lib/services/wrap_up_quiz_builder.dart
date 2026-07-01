import 'dart:math';

/// 마무리 덱 1문항(서버·Firestore 원본).
class WrapUpDeckEntry {
  const WrapUpDeckEntry({
    required this.kind,
    required this.meaningKo,
    required this.answer,
    this.answerAudioPath,
  });

  final String kind;
  final String meaningKo;
  final String answer;
  final String? answerAudioPath;
}

/// 4지선다 1문항(앱에서 생성).
class WrapUpQuizQuestion {
  const WrapUpQuizQuestion({
    required this.kind,
    required this.kindLabel,
    required this.meaningKo,
    required this.correctAnswer,
    required this.choices,
    required this.correctIndex,
    this.answerAudioPath,
  });

  final String kind;
  final String kindLabel;
  final String meaningKo;
  final String correctAnswer;
  final List<String> choices;
  final int correctIndex;
  final String? answerAudioPath;
}

/// 덱 항목으로 4지선다 문항 목록을 만든다. 보기는 덱 내 다른 정답에서 추출한다.
List<WrapUpQuizQuestion> buildWrapUpQuizQuestions({
  required List<WrapUpDeckEntry> items,
  required String wordKindLabel,
  required String sentenceKindLabel,
  int choicesPerQuestion = 4,
  Random? random,
}) {
  if (items.length < choicesPerQuestion) {
    return const [];
  }

  final rng = random ?? Random();
  final questions = <WrapUpQuizQuestion>[];

  for (final item in items) {
    final kind = item.kind;
    if (kind != 'word' && kind != 'sentence') continue;

    final distractors = _pickDistractors(
      current: item,
      all: items,
      count: choicesPerQuestion - 1,
      rng: rng,
    );
    if (distractors.length < choicesPerQuestion - 1) {
      continue;
    }

    final choices = <String>[item.answer, ...distractors]..shuffle(rng);
    final correctIndex = choices.indexOf(item.answer);
    if (correctIndex < 0) continue;

    questions.add(
      WrapUpQuizQuestion(
        kind: kind,
        kindLabel: kind == 'word' ? wordKindLabel : sentenceKindLabel,
        meaningKo: item.meaningKo,
        correctAnswer: item.answer,
        choices: choices,
        correctIndex: correctIndex,
        answerAudioPath: item.answerAudioPath,
      ),
    );
  }

  return questions;
}

List<String> _pickDistractors({
  required WrapUpDeckEntry current,
  required List<WrapUpDeckEntry> all,
  required int count,
  required Random rng,
}) {
  final sameKind = all
      .where(
        (e) =>
            e.kind == current.kind &&
            e.answer.trim() != current.answer.trim(),
      )
      .map((e) => e.answer.trim())
      .toSet()
      .toList();

  var pool = List<String>.from(sameKind);
  if (pool.length < count) {
    final fallback = all
        .where((e) => e.answer.trim() != current.answer.trim())
        .map((e) => e.answer.trim())
        .toSet()
        .where((a) => !pool.contains(a));
    pool.addAll(fallback);
  }

  pool.shuffle(rng);
  return pool.take(count).toList();
}
