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
  bool _loading = false;
  bool _aiLoading = true;
  String? _aiError;

  String? _word;
  String? _meaning;
  String? _example;

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await incrementTodayDailyProgress(user, kind: DailyProgressKind.word);
      // 완료 처리 후 다음 샘플을 바로 보여줌
      await _fetchWordSample();
    } catch (e) {
      setState(() => _error = '저장 실패: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
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
              'MVP: 샘플 단어 + 완료 처리(+1)',
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

            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _loading ? null : _markDone,
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(_loading ? '저장 중…' : '단어 1개 완료(+1)'),
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

