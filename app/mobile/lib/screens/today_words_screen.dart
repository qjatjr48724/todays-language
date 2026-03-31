import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/daily_progress_sync.dart';

class TodayWordsScreen extends StatefulWidget {
  const TodayWordsScreen({super.key});

  @override
  State<TodayWordsScreen> createState() => _TodayWordsScreenState();
}

class _TodayWordsScreenState extends State<TodayWordsScreen> {
  bool _savingProgress = false;
  bool _aiLoading = true;
  String? _aiError;

  String? _word;
  String? _meaning;
  String? _example;
  bool _completedCurrent = false;

  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchWordSample();
  }

  Future<void> _fetchWordSample() async {
    setState(() {
      _aiLoading = true;
      _aiError = null;
      _word = null;
      _meaning = null;
      _example = null;
      _completedCurrent = false;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인 상태가 아닙니다.');
      }
      // callable에서 unauthenticated가 가끔 뜨는 경우를 방지
      await user.getIdToken(true);

      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-northeast3',
      ).httpsCallable('generateWord');

      final result = await callable.call<Map<String, dynamic>>({
        'targetLanguage': 'ja',
        'level': 'beginner',
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      final word = data['word']?.toString() ?? '';
      final meaning = data['meaningKo']?.toString() ?? '';
      final example = data['example']?.toString();

      if (!mounted) return;
      setState(() {
        _word = word;
        _meaning = meaning;
        _example = example;
        _aiLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiError = '샘플 단어 불러오기 실패: $e';
        _aiLoading = false;
      });
    }
  }

  Future<void> _markDone() async {
    if (_completedCurrent) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      _savingProgress = true;
      _error = null;
    });
    try {
      await incrementTodayDailyProgress(user, kind: DailyProgressKind.word);
      if (!mounted) return;
      setState(() => _completedCurrent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('단어 학습 완료! 오늘 진도 +1')),
      );
    } catch (e) {
      setState(() => _error = '저장 실패: $e');
    } finally {
      if (mounted) setState(() => _savingProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 단어')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '완료 버튼은 현재 단어에서 1회만 +1 됩니다. 이후 다음 단어로 넘어가세요.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),

            if (_aiLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Text('샘플을 불러오는 중…', style: TextStyle(color: scheme.onSurfaceVariant)),
            ] else if (_aiError != null) ...[
              Text(_aiError!, style: TextStyle(color: scheme.error)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _fetchWordSample,
                child: const Text('샘플 다시 불러오기'),
              ),
            ] else ...[
              Text(
                _word ?? '-',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                _meaning ?? '-',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              if (_example != null && _example!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  '예문: ${_example!}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],

            const Spacer(),
            FilledButton.icon(
              onPressed: (_aiLoading || _aiError != null || _completedCurrent || _savingProgress)
                  ? null
                  : _markDone,
              icon: _savingProgress
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(
                _savingProgress
                    ? '저장 중…'
                    : (_completedCurrent ? '완료 반영됨 (+1)' : '이 단어 완료(+1)'),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: (_aiLoading || _savingProgress) ? null : _fetchWordSample,
              icon: const Icon(Icons.refresh),
              label: const Text('다음 단어'),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: scheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}

