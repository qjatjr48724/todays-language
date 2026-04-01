import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/daily_progress_sync.dart';

class TodayWrapUpScreen extends StatefulWidget {
  const TodayWrapUpScreen({super.key});

  @override
  State<TodayWrapUpScreen> createState() => _TodayWrapUpScreenState();
}

class _TodayWrapUpScreenState extends State<TodayWrapUpScreen> {
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  final List<_WrapUpItem> _items = [];
  final Map<int, bool> _revealed = <int, bool>{};
  final Set<int> _checked = <int>{};

  @override
  void initState() {
    super.initState();
    _loadWrapUp();
  }

  Future<void> _loadWrapUp() async {
    setState(() {
      _loading = true;
      _error = null;
      _items.clear();
      _revealed.clear();
      _checked.clear();
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('로그인 상태가 아닙니다.');
      await user.getIdToken(true);

      final wordCallable = FirebaseFunctions.instanceFor(
        region: 'asia-northeast3',
      ).httpsCallable('generateWord');
      final sentenceCallable = FirebaseFunctions.instanceFor(
        region: 'asia-northeast3',
      ).httpsCallable('generateSentence');

      for (var i = 0; i < 20; i++) {
        final result = await wordCallable.call<Map<String, dynamic>>({
          'targetLanguage': 'ja',
          'level': 'beginner',
        });
        final data = Map<String, dynamic>.from(result.data as Map);
        final word = data['word']?.toString() ?? '';
        final meaning = data['meaningKo']?.toString() ?? '';
        if (word.isEmpty || meaning.isEmpty) continue;
        _items.add(_WrapUpItem(
          kind: '단어',
          question: '뜻: $meaning\n해당하는 단어를 확인해보세요.',
          answer: word,
        ));
      }

      for (var i = 0; i < 5; i++) {
        final result = await sentenceCallable.call<Map<String, dynamic>>({
          'targetLanguage': 'ja',
          'level': 'beginner',
        });
        final data = Map<String, dynamic>.from(result.data as Map);
        final sentence = data['sentence']?.toString() ?? '';
        final meaning = data['meaningKo']?.toString() ?? '';
        if (sentence.isEmpty || meaning.isEmpty) continue;
        _items.add(_WrapUpItem(
          kind: '문장',
          question: '뜻: $meaning\n해당하는 문장을 확인해보세요.',
          answer: sentence,
        ));
      }

      _items.shuffle();
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '마무리 문제를 불러오지 못했습니다: $e';
        _loading = false;
      });
    }
  }

  Future<void> _finishWrapUp() async {
    if (_submitting) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() => _submitting = true);
    try {
      final current = await ensureTodayDailyProgress(user);
      final need = (current.quizGoal - current.quizDone).clamp(0, current.quizGoal);
      for (var i = 0; i < need; i++) {
        await incrementTodayDailyProgress(user, kind: DailyProgressKind.quiz);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오늘의 마무리 완료가 반영되었습니다.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('마무리 반영 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 마무리')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_error!, style: TextStyle(color: scheme.error)),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _loadWrapUp,
                        child: const Text('다시 불러오기'),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '당일 학습 최종 점검: 단어 20개 + 문장 5개',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.separated(
                          itemCount: _items.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 10),
                          itemBuilder: (context, i) {
                            final item = _items[i];
                            final shown = _revealed[i] == true;
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '[${item.kind}] 문제 ${i + 1}\n${item.question}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    if (shown)
                                      Text(
                                        '정답: ${item.answer}',
                                        style: TextStyle(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    else
                                      OutlinedButton(
                                        onPressed: () => setState(() {
                                          _revealed[i] = true;
                                          _checked.add(i);
                                        }),
                                        child: const Text('정답 보기'),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _loadWrapUp,
                              icon: const Icon(Icons.refresh),
                              label: const Text('문제 새로 받기'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: (_submitting || _items.isEmpty) ? null : _finishWrapUp,
                              icon: _submitting
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.task_alt),
                              label: Text(_submitting ? '반영 중…' : '마무리 완료'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _WrapUpItem {
  const _WrapUpItem({
    required this.kind,
    required this.question,
    required this.answer,
  });

  final String kind;
  final String question;
  final String answer;
}
