import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/daily_progress_sync.dart';
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
  final List<_WrapUpItem> _items = [];
  final Map<int, bool> _revealed = <int, bool>{};
  final Set<int> _checked = <int>{};

  @override
  void initState() {
    super.initState();
    _loadWrapUp();
  }

  Future<void> _loadWrapUp() async {
    final l10n = AppLocalizations.of(context)!;
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

      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-northeast3',
      ).httpsCallable('getWrapUpDeck');

      final result = await callable.call<Map<String, dynamic>>({
        'targetLanguage': widget.targetLanguage,
        'level': widget.level,
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      final rawItems = (data['items'] as List?) ?? const [];
      for (final e in rawItems) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);
        final kind = m['kind']?.toString() ?? '';
        final meaning = m['meaningKo']?.toString() ?? '';
        final answer = m['answer']?.toString() ?? '';
        if (meaning.isEmpty || answer.isEmpty) continue;
        if (kind == 'word') {
          _items.add(_WrapUpItem(
            kind: l10n.wrapup_kind_word,
            question:
                '${l10n.wrapup_meaning_label} $meaning\n${l10n.wrapup_word_instruction}',
            answer: answer,
          ));
        } else if (kind == 'sentence') {
          _items.add(_WrapUpItem(
            kind: l10n.wrapup_kind_sentence,
            question:
                '${l10n.wrapup_meaning_label} $meaning\n${l10n.wrapup_sentence_instruction}',
            answer: answer,
          ));
        }
      }
      if (!mounted) return;
      setState(() => _loading = false);
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _error = l10n.wrapup_load_failed(e.toString());
        _loading = false;
      });
    }
  }

  Future<void> _finishWrapUp() async {
    if (_submitting) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _submitting = true);
    try {
      final current = await ensureTodayDailyProgress(user);
      final need = (current.quizGoal - current.quizDone).clamp(0, current.quizGoal);
      for (var i = 0; i < need; i++) {
        await incrementTodayDailyProgress(user, kind: DailyProgressKind.quiz);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.wrapup_completed_snackbar)),
      );
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
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.wrapup_appbar_title)),
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
                        child: Text(l10n.wrapup_reload_button),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.wrapup_summary_title,
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
                                      '[${item.kind}] ${l10n.wrapup_problem_label} ${i + 1}\n${item.question}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    if (shown)
                                      Text(
                                        '${l10n.wrapup_answer_prefix}${item.answer}',
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
                                        child: Text(l10n.wrapup_show_answer_button),
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
                            label: Text(l10n.wrapup_problem_new_button),
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
                              label: Text(_submitting
                                  ? l10n.wrapup_reflecting_progress
                                  : l10n.wrapup_finish_button_label),
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
