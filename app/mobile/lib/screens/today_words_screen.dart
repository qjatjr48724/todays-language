import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../services/daily_progress_sync.dart';

class TodayWordsScreen extends StatefulWidget {
  const TodayWordsScreen({
    super.key,
    required this.targetLanguage,
    required this.level,
  });

  final String targetLanguage;
  final String level;

  @override
  State<TodayWordsScreen> createState() => _TodayWordsScreenState();
}

class _TodayWordsScreenState extends State<TodayWordsScreen> {
  bool _savingProgress = false;
  bool _aiLoading = true;
  String? _aiError;

  String? _word;
  String? _wordReadingHira;
  String? _meaning;
  String? _example;
  String? _debugSource;
  bool _completedCurrent = false;

  String? _error;

  DailyProgressView? _todayProgress;
  /// 오늘 단어 목표(30) 달성 후 「다음 단어」를 다시 쓰려면 true.
  bool _relearnActive = false;

  bool get _wordCapReached =>
      _todayProgress != null &&
      _todayProgress!.wordDone >= _todayProgress!.wordGoal;

  bool get _showRelearnButton => _wordCapReached && !_relearnActive;

  bool get _canUseNextButton =>
      !_aiLoading &&
      !_savingProgress &&
      (!_wordCapReached || _relearnActive);

  bool get _canMarkComplete =>
      !_wordCapReached &&
      !(_aiLoading || _aiError != null || _completedCurrent || _savingProgress);

  @override
  void initState() {
    super.initState();
    _loadTodayProgress();
    _fetchWordSample();
  }

  Future<void> _loadTodayProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final p = await ensureTodayDailyProgress(user);
      if (!mounted) return;
      setState(() {
        _todayProgress = p;
        if (p.wordDone < p.wordGoal) {
          _relearnActive = false;
        }
      });
    } catch (_) {
      // 진도 로드 실패는 학습 화면을 막지 않음
    }
  }

  void _startRelearn() {
    setState(() => _relearnActive = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          '연습 모드입니다. 「다음 단어」로 복습할 수 있어요. (오늘 진도는 이미 목표에 도달했습니다.)',
        ),
      ),
    );
  }

  Future<void> _fetchWordSample() async {
    setState(() {
      _aiLoading = true;
      _aiError = null;
      _word = null;
      _wordReadingHira = null;
      _meaning = null;
      _example = null;
      _debugSource = null;
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
        'targetLanguage': widget.targetLanguage,
        'level': widget.level,
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      final word = data['word']?.toString() ?? '';
      final readingHira = data['readingHira']?.toString();
      final meaning = data['meaningKo']?.toString() ?? '';
      final example = data['example']?.toString();
      final debugSource = data['debugSource']?.toString();

      if (!mounted) return;
      setState(() {
        _word = word;
        _wordReadingHira = readingHira;
        _meaning = meaning;
        _example = example;
        _debugSource = debugSource;
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
      final p = await incrementTodayDailyProgress(user, kind: DailyProgressKind.word);
      if (!mounted) return;
      setState(() {
        _completedCurrent = true;
        _todayProgress = p;
        if (p.wordDone < p.wordGoal) {
          _relearnActive = false;
        }
      });
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
    final showHiraLine =
        widget.targetLanguage.toUpperCase() == 'JPN' &&
        widget.level != 'beginner' &&
        _wordReadingHira != null &&
        _wordReadingHira!.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: const Text('오늘의 단어')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _wordCapReached && !_relearnActive
                  ? '오늘 단어 목표(${_todayProgress?.wordGoal ?? 30}개)를 달성했습니다. 「재학습 시작」 후 「다음 단어」로 복습할 수 있어요.'
                  : _wordCapReached && _relearnActive
                      ? '연습 모드: 새 단어를 불러오며 복습할 수 있습니다. (진도는 더 올라가지 않습니다.)'
                      : '완료 버튼은 현재 단어에서 1회만 +1 됩니다. 이후 다음 단어로 넘어가세요.',
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
              if (showHiraLine) ...[
                const SizedBox(height: 6),
                Text(
                  _wordReadingHira!,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
              const SizedBox(height: 6),
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
              onPressed: _canMarkComplete ? _markDone : null,
              icon: _savingProgress
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: Text(
                _wordCapReached
                    ? '오늘 목표 달성 (진도 +0)'
                    : _savingProgress
                        ? '저장 중…'
                        : (_completedCurrent ? '완료 반영됨 (+1)' : '이 단어 완료(+1)'),
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
              onPressed: _canUseNextButton ? _fetchWordSample : null,
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

