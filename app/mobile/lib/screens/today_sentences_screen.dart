import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/daily_progress_sync.dart';

class TodaySentencesScreen extends StatefulWidget {
  const TodaySentencesScreen({super.key});

  @override
  State<TodaySentencesScreen> createState() => _TodaySentencesScreenState();
}

class _TodaySentencesScreenState extends State<TodaySentencesScreen> {
  bool _loading = false;
  String? _error;

  bool _aiLoading = true;
  String? _aiError;
  String? _sentence;
  String? _meaning;

  @override
  void initState() {
    super.initState();
    _fetchSentenceSample();
  }

  Future<void> _fetchSentenceSample() async {
    setState(() {
      _aiLoading = true;
      _aiError = null;
      _sentence = null;
      _meaning = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('로그인 상태가 아닙니다.');
      await user.getIdToken(true);

      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-northeast3',
      ).httpsCallable('generateSentence');

      final result = await callable.call<Map<String, dynamic>>({
        'targetLanguage': 'ja',
        'level': 'beginner',
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      final sentence = data['sentence']?.toString() ?? '';
      final meaning = data['meaningKo']?.toString() ?? '';

      if (!mounted) return;
      setState(() {
        _sentence = sentence;
        _meaning = meaning;
        _aiLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiError = '샘플 문장 불러오기 실패: $e';
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
      await incrementTodayDailyProgress(user, kind: DailyProgressKind.sentence);
      await _fetchSentenceSample();
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
      appBar: AppBar(title: const Text('오늘의 문장')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MVP: 샘플 문장 + 완료 처리(+1)',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (_aiLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Text('샘플을 불러오는 중…',
                  style: TextStyle(color: scheme.onSurfaceVariant)),
            ] else if (_aiError != null) ...[
              Text(_aiError!, style: TextStyle(color: scheme.error)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _fetchSentenceSample,
                child: const Text('샘플 다시 불러오기'),
              ),
            ] else ...[
              Text(
                _sentence ?? '-',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                _meaning ?? '-',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
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
              label: Text(_loading ? '저장 중…' : '문장 1개 완료(+1)'),
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

