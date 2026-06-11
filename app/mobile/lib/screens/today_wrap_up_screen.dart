import '../config/firebase_functions_config.dart';
import '../utils/callable_request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/daily_progress_sync.dart';
import '../services/wrap_up_quiz_builder.dart';
import '../l10n/app_localizations.dart';

class TodayWrapUpScreen extends StatefulWidget {
  const TodayWrapUpScreen({
    super.key,
    required this.targetLanguage,
    required this.level,
  });

  final String targetLanguage;
  final String level;

  @override
  State<TodayWrapUpScreen> createState() => _TodayWrapUpScreenState();
}

class _TodayWrapUpScreenState extends State<TodayWrapUpScreen> {
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  final List<WrapUpQuizQuestion> _questions = [];
  int _currentIndex = 0;
  int? _selectedChoiceIndex;
  bool _answered = false;
  int _correctCount = 0;
  bool _sessionComplete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _loadWrapUp();
    });
  }

  Future<void> _loadWrapUp({bool forceRefreshToken = false}) async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
      _questions.clear();
      _currentIndex = 0;
      _selectedChoiceIndex = null;
      _answered = false;
      _correctCount = 0;
      _sessionComplete = false;
    });

    try {
      if (FirebaseAuth.instance.currentUser == null) {
        throw Exception('not_signed_in');
      }

      final data = await invokeCallableMap(
        callableGetWrapUpDeck(),
        {
          'targetLanguage': widget.targetLanguage,
          'level': widget.level,
        },
        forceRefreshToken: forceRefreshToken,
      );

      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      final deck = _parseDeckEntries(data);

      if (deck.isEmpty) {
        setState(() {
          _error = l10n.wrapup_empty_deck;
          _loading = false;
        });
        return;
      }

      final built = buildWrapUpQuizQuestions(
        items: deck,
        wordKindLabel: l10n.wrapup_kind_word,
        sentenceKindLabel: l10n.wrapup_kind_sentence,
      );

      if (built.isEmpty) {
        setState(() {
          _error = l10n.wrapup_insufficient_for_quiz;
          _loading = false;
        });
        return;
      }

      setState(() {
        _questions.addAll(built);
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _error = l10n.wrapup_load_failed(formatCallableLoadError(e));
        _loading = false;
      });
    }
  }

  List<WrapUpDeckEntry> _parseDeckEntries(Map<String, dynamic> data) {
    final loaded = <WrapUpDeckEntry>[];
    final rawItems = (data['items'] as List?) ?? const [];
    for (final e in rawItems) {
      if (e is! Map) continue;
      final m = Map<String, dynamic>.from(e);
      final kind = m['kind']?.toString() ?? '';
      final meaning = m['meaningKo']?.toString().trim() ?? '';
      final answer = m['answer']?.toString().trim() ?? '';
      if (meaning.isEmpty || answer.isEmpty) continue;
      if (kind == 'word' || kind == 'sentence') {
        loaded.add(WrapUpDeckEntry(kind: kind, meaningKo: meaning, answer: answer));
      }
    }
    return loaded;
  }

  void _onChoiceTap(int index) {
    if (_answered || _sessionComplete) return;
    final q = _questions[_currentIndex];
    final isCorrect = index == q.correctIndex;
    setState(() {
      _selectedChoiceIndex = index;
      _answered = true;
      if (isCorrect) _correctCount++;
    });
  }

  void _goNext() {
    if (!_answered) return;
    if (_currentIndex + 1 >= _questions.length) {
      setState(() => _sessionComplete = true);
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedChoiceIndex = null;
      _answered = false;
    });
  }

  Future<void> _finishWrapUp() async {
    if (_submitting) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      final current = await ensureTodayDailyProgress(
        user,
        targetLanguage: widget.targetLanguage,
      );
      final need = (current.quizGoal - current.quizDone).clamp(0, current.quizGoal);
      for (var i = 0; i < need; i++) {
        await incrementTodayDailyProgress(
          user,
          kind: DailyProgressKind.quiz,
          targetLanguage: widget.targetLanguage,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.wrapup_completed_snackbar)),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.wrapup_finish_failed_snackbar(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.wrapup_appbar_title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (_error != null)
                ? _ErrorBody(
                    error: _error!,
                    onRetry: () => _loadWrapUp(forceRefreshToken: true),
                  )
                : _sessionComplete
                    ? _CompleteBody(
                        correct: _correctCount,
                        total: _questions.length,
                        submitting: _submitting,
                        onFinish: _finishWrapUp,
                        onReload: () => _loadWrapUp(forceRefreshToken: true),
                      )
                    : _QuizBody(
                        question: _questions[_currentIndex],
                        current: _currentIndex + 1,
                        total: _questions.length,
                        selectedIndex: _selectedChoiceIndex,
                        answered: _answered,
                        onChoiceTap: _onChoiceTap,
                        onNext: _goNext,
                        pickWord: l10n.wrapup_pick_word,
                        pickSentence: l10n.wrapup_pick_sentence,
                      ),
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.error, required this.onRetry});

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(error, style: TextStyle(color: scheme.error)),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onRetry,
          child: Text(l10n.wrapup_reload_button),
        ),
      ],
    );
  }
}

class _QuizBody extends StatelessWidget {
  const _QuizBody({
    required this.question,
    required this.current,
    required this.total,
    required this.selectedIndex,
    required this.answered,
    required this.onChoiceTap,
    required this.onNext,
    required this.pickWord,
    required this.pickSentence,
  });

  final WrapUpQuizQuestion question;
  final int current;
  final int total;
  final int? selectedIndex;
  final bool answered;
  final ValueChanged<int> onChoiceTap;
  final VoidCallback onNext;
  final String pickWord;
  final String pickSentence;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final instruction =
        question.kind == 'word' ? pickWord : pickSentence;
    final isCorrect = answered && selectedIndex == question.correctIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Chip(
              label: Text(question.kindLabel),
              visualDensity: VisualDensity.compact,
            ),
            const Spacer(),
            Text(
              l10n.wrapup_progress(current, total),
              style: textTheme.labelLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.wrapup_summary_title,
          style: textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instruction,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${l10n.wrapup_meaning_label} ${question.meaningKo}',
                  style: textTheme.headlineSmall?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.separated(
            itemCount: question.choices.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final label = question.choices[i];
              final isSelected = selectedIndex == i;
              final isCorrectChoice = i == question.correctIndex;

              Color? bg;
              Color? border;
              if (answered) {
                if (isCorrectChoice) {
                  bg = scheme.primaryContainer.withValues(alpha: 0.45);
                  border = scheme.primary;
                } else if (isSelected) {
                  bg = scheme.errorContainer.withValues(alpha: 0.35);
                  border = scheme.error;
                }
              } else if (isSelected) {
                bg = scheme.surfaceContainerHighest;
                border = scheme.outline;
              }

              return Material(
                color: bg ?? scheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: border ?? scheme.outlineVariant,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: answered ? null : () => onChoiceTap(i),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Text(
                      label,
                      style: textTheme.bodyLarge?.copyWith(height: 1.35),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (answered) ...[
          Text(
            isCorrect
                ? l10n.wrapup_correct_feedback
                : l10n.wrapup_incorrect_feedback(question.correctAnswer),
            style: TextStyle(
              color: isCorrect ? scheme.primary : scheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: onNext,
            child: Text(l10n.wrapup_next_button),
          ),
        ],
      ],
    );
  }
}

class _CompleteBody extends StatelessWidget {
  const _CompleteBody({
    required this.correct,
    required this.total,
    required this.submitting,
    required this.onFinish,
    required this.onReload,
  });

  final int correct;
  final int total;
  final bool submitting;
  final VoidCallback onFinish;
  final VoidCallback onReload;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.wrapup_session_complete_title,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Text(
          l10n.wrapup_score_line(correct, total),
          style: textTheme.titleLarge?.copyWith(color: scheme.primary),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: submitting ? null : onReload,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.wrapup_problem_new_button),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: submitting ? null : onFinish,
                icon: submitting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.task_alt),
                label: Text(
                  submitting
                      ? l10n.wrapup_reflecting_progress
                      : l10n.wrapup_finish_button_label,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
