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
  bool _aiLoading = true;
  String? _aiError;
  String? _promptKo;
  List<String> _choices = const [];
  int? _answerIndex;
  bool _showAnswer = false;
  int? _selectedIndex;
  bool _hasIncrementedForQuestion = false;
  bool _savingProgress = false;
  String? _error;

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
      _hasIncrementedForQuestion = false;
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

  Future<void> _onChoiceTapped(int i) async {
    if (_showAnswer) return;
    final answer = _answerIndex;
    if (answer == null) return;

    setState(() {
      _selectedIndex = i;
      _showAnswer = true;
    });

    if (i == answer && !_hasIncrementedForQuestion) {
      setState(() => _savingProgress = true);
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user == null) throw Exception('로그인 상태가 아닙니다.');
        await incrementTodayDailyProgress(user, kind: DailyProgressKind.quiz);
        if (!mounted) return;
        setState(() {
          _hasIncrementedForQuestion = true;
          _savingProgress = false;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _error = '진도 저장 실패: $e';
          _savingProgress = false;
        });
      }
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final answered = _showAnswer;
    final isCorrect =
        answered && _selectedIndex != null && _selectedIndex == _answerIndex;

    return Scaffold(
      appBar: AppBar(title: const Text('단어 퀴즈')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MVP: 정답일 때만 진도(+1) · 다음 문제로 진행',
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
                onPressed: _fetchQuizSample,
                child: const Text('샘플 다시 불러오기'),
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
                    onPressed: _savingProgress
                        ? null
                        : () => _onChoiceTapped(i),
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
              if (answered && _answerIndex != null) ...[
                const SizedBox(height: 8),
                if (isCorrect) ...[
                  Text(
                    _hasIncrementedForQuestion
                        ? '정답입니다. 오늘의 퀴즈 진도에 반영했습니다.'
                        : '정답입니다. 진도를 저장하는 중…',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ] else ...[
                  Text(
                    '오답입니다. 정답은 ${_answerIndex! + 1}번입니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ],
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: scheme.error)),
            ],
            if (!_aiLoading && _aiError == null && _promptKo != null) ...[
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: (_savingProgress || !answered)
                    ? null
                    : _fetchQuizSample,
                icon: const Icon(Icons.navigate_next),
                label: const Text('다음 문제'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
