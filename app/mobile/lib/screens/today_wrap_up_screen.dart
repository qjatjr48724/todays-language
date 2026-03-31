import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TodayWrapUpScreen extends StatefulWidget {
  const TodayWrapUpScreen({super.key});

  @override
  State<TodayWrapUpScreen> createState() => _TodayWrapUpScreenState();
}

class _TodayWrapUpScreenState extends State<TodayWrapUpScreen> {
  bool _loading = true;
  String? _error;
  final List<_WrapUpItem> _items = [];
  final Set<int> _revealed = <int>{};

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
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('로그인 상태가 아닙니다.');
      await user.getIdToken(true);

      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-northeast3',
      ).httpsCallable('generateQuiz');

      for (var i = 0; i < 5; i++) {
        final result = await callable.call<Map<String, dynamic>>({
          'targetLanguage': 'ja',
          'level': 'beginner',
        });
        final data = Map<String, dynamic>.from(result.data as Map);
        final prompt = data['promptKo']?.toString() ?? '';
        final choices = ((data['choices'] as List?) ?? const [])
            .map((e) => e.toString())
            .toList();
        final answerIndex = (data['answerIndex'] as num?)?.toInt() ?? 0;
        if (prompt.isEmpty || choices.length != 4 || answerIndex < 0 || answerIndex > 3) {
          continue;
        }
        _items.add(
          _WrapUpItem(
            promptKo: prompt,
            answerText: choices[answerIndex],
          ),
        );
      }

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
                        '오늘 학습 내용을 최종 점검합니다. 각 문제의 정답을 확인해 보세요.',
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
                            final shown = _revealed.contains(i);
                            return Card(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '문제 ${i + 1}. ${item.promptKo}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    if (shown)
                                      Text(
                                        '정답: ${item.answerText}',
                                        style: TextStyle(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      )
                                    else
                                      OutlinedButton(
                                        onPressed: () => setState(() => _revealed.add(i)),
                                        child: const Text('정답 보기'),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _loadWrapUp,
                        icon: const Icon(Icons.refresh),
                        label: const Text('문제 새로 받기'),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _WrapUpItem {
  const _WrapUpItem({
    required this.promptKo,
    required this.answerText,
  });

  final String promptKo;
  final String answerText;
}
