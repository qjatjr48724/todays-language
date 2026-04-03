import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../services/daily_progress_sync.dart';

class TodaySentencesScreen extends StatefulWidget {
  const TodaySentencesScreen({super.key});

  @override
  State<TodaySentencesScreen> createState() => _TodaySentencesScreenState();
}

class _TodaySentencesScreenState extends State<TodaySentencesScreen> {
  bool _savingProgress = false;
  String? _error;

  bool _aiLoading = true;
  String? _aiError;
  String? _sentence;
  String? _meaning;
  String? _debugSource;
  bool _completedCurrent = false;

  DailyProgressView? _todayProgress;
  bool _relearnActive = false;

  bool get _sentenceCapReached =>
      _todayProgress != null &&
      _todayProgress!.sentenceDone >= _todayProgress!.sentenceGoal;

  bool get _showRelearnButton => _sentenceCapReached && !_relearnActive;

  bool get _canUseNextButton =>
      !_aiLoading &&
      !_savingProgress &&
      (!_sentenceCapReached || _relearnActive);

  bool get _canMarkComplete =>
      !_sentenceCapReached &&
      !(_aiLoading || _aiError != null || _completedCurrent || _savingProgress);

  @override
  void initState() {
    super.initState();
    _loadTodayProgress();
    _fetchSentenceSample();
  }

  Future<void> _loadTodayProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final p = await ensureTodayDailyProgress(user);
      if (!mounted) return;
      setState(() {
        _todayProgress = p;
        if (p.sentenceDone < p.sentenceGoal) {
          _relearnActive = false;
        }
      });
    } catch (_) {}
  }

  void _startRelearn() {
    setState(() => _relearnActive = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '연습 모드입니다. 「다음 문장」으로 복습할 수 있어요. (오늘 진도는 이미 목표에 도달했습니다.)',
        ),
      ),
    );
  }

  Future<void> _fetchSentenceSample() async {
    setState(() {
      _aiLoading = true;
      _aiError = null;
      _sentence = null;
      _meaning = null;
      _debugSource = null;
      _completedCurrent = false;
      _error = null;
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
      final debugSource = data['debugSource']?.toString();

      if (!mounted) return;
      setState(() {
        _sentence = sentence;
        _meaning = meaning;
        _debugSource = debugSource;
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
    if (_completedCurrent) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    setState(() {
      _savingProgress = true;
      _error = null;
    });
    try {
      final p =
          await incrementTodayDailyProgress(user, kind: DailyProgressKind.sentence);
      if (!mounted) return;
      setState(() {
        _completedCurrent = true;
        _todayProgress = p;
        if (p.sentenceDone < p.sentenceGoal) {
          _relearnActive = false;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('문장 학습 완료! 오늘 진도 +1')),
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
      appBar: AppBar(title: const Text('오늘의 문장')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _sentenceCapReached && !_relearnActive
                  ? '오늘 문장 목표(${_todayProgress?.sentenceGoal ?? 10}개)를 달성했습니다. 「재학습 시작」 후 「다음 문장」으로 복습할 수 있어요.'
                  : _sentenceCapReached && _relearnActive
                      ? '연습 모드: 새 문장을 불러오며 복습할 수 있습니다. (진도는 더 올라가지 않습니다.)'
                      : '완료 버튼은 현재 문장에서 1회만 +1 됩니다. 이후 다음 문장으로 넘어가세요.',
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
              if (kDebugMode && _debugSource != null) ...[
                const SizedBox(height: 10),
                Text(
                  'debugSource: $_debugSource',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
            ],
            const Spacer(),
            FilledButton.icon(
              onPressed: _canMarkComplete ? _markDone : null,
              icon: _savingProgress
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(
                _sentenceCapReached
                    ? '오늘 목표 달성 (진도 +0)'
                    : _savingProgress
                        ? '저장 중…'
                        : (_completedCurrent ? '완료 반영됨 (+1)' : '이 문장 완료(+1)'),
              ),
            ),
            const SizedBox(height: 8),
            if (_showRelearnButton) ...[
              FilledButton.tonalIcon(
                onPressed: (_aiLoading || _savingProgress) ? null : _startRelearn,
                icon: const Icon(Icons.school_outlined),
                label: const Text('재학습 시작'),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: _canUseNextButton ? _fetchSentenceSample : null,
              icon: const Icon(Icons.refresh),
              label: const Text('다음 문장'),
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

