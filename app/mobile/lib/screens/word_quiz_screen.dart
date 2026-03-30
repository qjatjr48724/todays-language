import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/daily_progress_sync.dart';

class WordQuizScreen extends StatefulWidget {
  const WordQuizScreen({super.key});

  @override
  State<WordQuizScreen> createState() => _WordQuizScreenState();
}

class _WordQuizScreenState extends State<WordQuizScreen> {
  String? _error;

  bool _aiLoading = true;
  String? _aiError;
  String? _promptKo;
  List<String> _choices = const [];
  int? _answerIndex;
  bool _showAnswer = false;
  int? _selectedIndex;
  bool _progressSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchQuizSample();
  }

  Future<void> _fetchQuizSample() async {
    setState(() {
      _aiLoading = true;
      _aiError = null;
      _promptKo = null;
      _choices = const [];
      _answerIndex = null;
      _showAnswer = false;
      _selectedIndex = null;
      _error = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('로그인 상태가 아닙니다.');
      await user.getIdToken(true);

      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-northeast3',
      ).httpsCallable('generateQuiz');

      final result = await callable.call<Map<String, dynamic>>({
        'targetLanguage': 'ja',
        'level': 'beginner',
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      final prompt = data['promptKo']?.toString() ?? '';
      final choicesRaw = (data['choices'] as List?) ?? const [];
      final choices = choicesRaw.map((e) => e.toString()).toList();
      final answerIndex = (data['answerIndex'] as num?)?.toInt();

      if (!mounted) return;
      setState(() {
        _promptKo = prompt;
        _choices = choices;
        _answerIndex = answerIndex;
        _aiLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _aiError = '퀴즈 샘플 불러오기 실패: $e';
        _aiLoading = false;
      });
    }
  }

  Color _choiceBgColor(ColorScheme scheme, int index) {
    if (!_showAnswer) return scheme.surface;
    final answer = _answerIndex;
    final selected = _selectedIndex;
    if (answer == null || selected == null) return scheme.surface;

    final isAnswer = index == answer;
    final isSelected = index == selected;

    if (isAnswer) return Colors.green.withValues(alpha: 0.18);
    if (isSelected && selected != answer) {
      return Colors.red.withValues(alpha: 0.18);
    }
    return scheme.surfaceContainerHighest;
  }

  Color _choiceFgColor(ColorScheme scheme, int index) {
    if (!_showAnswer) return scheme.onSurface;
    final answer = _answerIndex;
    final selected = _selectedIndex;
    if (answer == null || selected == null) return scheme.onSurface;

    final isAnswer = index == answer;
    final isSelectedWrong = index == selected && selected != answer;
    if (isAnswer) return Colors.green.shade900;
    if (isSelectedWrong) return Colors.red.shade900;
    return scheme.onSurfaceVariant;
  }

  Future<void> _onChoiceTap(int i) async {
    if (_showAnswer) return;

    setState(() {
      _selectedIndex = i;
      _showAnswer = true;
      _error = null;
    });

    final answer = _answerIndex;
    if (answer == null || i != answer) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _progressSaving = true);
    try {
      await incrementTodayDailyProgress(user, kind: DailyProgressKind.quiz);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('정답! 오늘 퀴즈 진도 +1')),
      );
    } catch (e) {
      if (mounted) setState(() => _error = '진도 저장 실패: $e');
    } finally {
      if (mounted) setState(() => _progressSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('단어 퀴즈')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '보기를 고르면 정답/오답이 표시됩니다. 정답일 때만 진도가 +1 됩니다.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (_aiLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Text(
                '문제를 불러오는 중…',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
            ] else if (_aiError != null) ...[
              Text(_aiError!, style: TextStyle(color: scheme.error)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _fetchQuizSample,
                child: const Text('다시 불러오기'),
              ),
            ] else ...[
              Text(
                _promptKo ?? '-',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              for (var i = 0; i < _choices.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: OutlinedButton(
                    onPressed: _showAnswer ? null : () => _onChoiceTap(i),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: _choiceBgColor(scheme, i),
                      foregroundColor: _choiceFgColor(scheme, i),
                      side: BorderSide(color: scheme.outlineVariant),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text('${i + 1}. ${_choices[i]}'),
                    ),
                  ),
                ),
              if (_showAnswer && _answerIndex != null) ...[
                const SizedBox(height: 8),
                Text(
                  '정답: ${_answerIndex! + 1}번',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ],
            const Spacer(),
            if (!_aiLoading && _aiError == null && _promptKo != null) ...[
              if (_progressSaving)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              FilledButton.icon(
                onPressed: (_aiLoading || !_showAnswer || _progressSaving)
                    ? null
                    : _fetchQuizSample,
                icon: const Icon(Icons.refresh),
                label: const Text('다음 문제'),
              ),
            ],
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
