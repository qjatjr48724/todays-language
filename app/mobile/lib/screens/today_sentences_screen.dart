import '../config/firebase_functions_config.dart';
import '../utils/callable_request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../services/daily_progress_sync.dart';
import '../l10n/app_localizations.dart';

class TodaySentencesScreen extends StatefulWidget {
  const TodaySentencesScreen({
    super.key,
    required this.targetLanguage,
    required this.level,
  });

  final String targetLanguage;
  final String level;

  @override
  State<TodaySentencesScreen> createState() => _TodaySentencesScreenState();
}

class _TodaySentencesScreenState extends State<TodaySentencesScreen> {
  bool _savingProgress = false;
  String? _error;

  bool _aiLoading = true;
  String? _aiError;
  String? _sentence;
  String? _sentenceHira;
  String? _meaning;
  List<_SentenceVocabHint> _vocabHints = const [];
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
    final l10n = AppLocalizations.of(context)!;
    setState(() => _relearnActive = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.sentences_relearn_snackbar)),
    );
  }

  Future<void> _fetchSentenceSample({bool forceRefreshToken = false}) async {
    setState(() {
      _aiLoading = true;
      _aiError = null;
      _sentence = null;
      _sentenceHira = null;
      _meaning = null;
      _vocabHints = const [];
      _debugSource = null;
      _completedCurrent = false;
      _error = null;
    });

    try {
      if (FirebaseAuth.instance.currentUser == null) {
        throw Exception('로그인 상태가 아닙니다.');
      }

      final data = await invokeCallableMap(
        callableGenerateSentence(),
        {
          'targetLanguage': widget.targetLanguage,
          'level': widget.level,
        },
        forceRefreshToken: forceRefreshToken,
      );
      final sentence = data['sentence']?.toString() ?? '';
      final sentenceHira = data['sentenceHira']?.toString();
      final meaning = data['meaningKo']?.toString() ?? '';
      final debugSource = data['debugSource']?.toString();
      final hintsRaw = data['vocabularyHints'];
      final hints = <_SentenceVocabHint>[];
      if (hintsRaw is List) {
        for (final el in hintsRaw) {
          if (el is! Map) continue;
          final m = Map<String, dynamic>.from(el);
          final mk = m['meaningKo']?.toString().trim() ?? '';
          final w = m['word']?.toString().trim() ?? '';
          if (mk.isEmpty || w.isEmpty) continue;
          hints.add(_SentenceVocabHint(meaningKo: mk, word: w));
        }
      }

      if (!mounted) return;
      setState(() {
        _sentence = sentence;
        _sentenceHira = sentenceHira;
        _meaning = meaning;
        _vocabHints = hints;
        _debugSource = debugSource;
        _aiLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _aiError = l10n.sentences_ai_sample_load_failed(
          formatCallableLoadError(e),
        );
        _aiLoading = false;
      });
    }
  }

  Future<void> _markDone() async {
    if (_completedCurrent) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final l10n = AppLocalizations.of(context)!;
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
        SnackBar(content: Text(l10n.sentences_completed_snackbar)),
      );
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      setState(() => _error = l10n.sentences_save_failed(e.toString()));
    } finally {
      if (mounted) setState(() => _savingProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;
    final showHiraLine =
        widget.targetLanguage.toUpperCase() == 'JPN' &&
        widget.level != 'beginner' &&
        _sentenceHira != null &&
        _sentenceHira!.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.sentences_appbar_title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_sentenceCapReached && !_relearnActive) ...[
              Text(
                l10n.sentences_description_goal_reached(
                  _todayProgress?.sentenceGoal ?? kDailySentenceGoalDefault,
                ),
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_sentenceCapReached && _relearnActive) ...[
              Text(
                l10n.sentences_description_relearn_mode,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (_aiLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Text(l10n.sentences_loading_sample,
                  style: TextStyle(color: scheme.onSurfaceVariant)),
            ] else if (_aiError != null) ...[
              Text(_aiError!, style: TextStyle(color: scheme.error)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _fetchSentenceSample(forceRefreshToken: true),
                child: Text(l10n.sentences_sample_reload),
              ),
            ] else ...[
              Text(
                _sentence ?? '-',
                style: textTheme.headlineSmall,
              ),
              if (showHiraLine) ...[
                const SizedBox(height: 8),
                Text(
                  _sentenceHira!,
                  style: textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
              const SizedBox(height: 8),
              Text(
                _meaning ?? '-',
                style: textTheme.titleMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
              if (_vocabHints.isNotEmpty) ...[
                const SizedBox(height: 20),
                Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
                const SizedBox(height: 16),
                _VocabularyHintsCard(l10n: l10n, hints: _vocabHints),
              ],
            ],
            const Spacer(),
            if (!_sentenceCapReached)
              Text(
                l10n.sentences_description_normal,
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            if (kDebugMode && _debugSource != null) ...[
              if (!_sentenceCapReached) const SizedBox(height: 8),
              Text(
                l10n.sentences_debug_source(_debugSource!),
                style: textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
            if (!_sentenceCapReached || (kDebugMode && _debugSource != null))
              const SizedBox(height: 12),
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
                    ? l10n.sentences_button_goal_reached
                    : _savingProgress
                        ? l10n.sentences_button_saving
                        : (_completedCurrent
                            ? l10n.sentences_button_completed_reflected
                            : l10n.sentences_button_increment),
              ),
            ),
            const SizedBox(height: 8),
            if (_showRelearnButton) ...[
              FilledButton.tonalIcon(
                onPressed: (_aiLoading || _savingProgress) ? null : _startRelearn,
                icon: const Icon(Icons.school_outlined),
                label: Text(l10n.sentences_relearn_button_label),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: _canUseNextButton ? _fetchSentenceSample : null,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.sentences_next_button_label),
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


/// 문장 속 표현: 목업과 같이 한 카드 안에 행(뜻 → 표현)으로 묶는다.
class _VocabularyHintsCard extends StatelessWidget {
  const _VocabularyHintsCard({
    required this.l10n,
    required this.hints,
  });

  final AppLocalizations l10n;
  final List<_SentenceVocabHint> hints;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.sentences_vocab_section_title,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < hints.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  color: scheme.outlineVariant.withValues(alpha: 0.65),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        hints[i].meaningKo,
                        style: textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 20,
                        color: scheme.outline,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        hints[i].word,
                        textAlign: TextAlign.right,
                        style: textTheme.bodyLarge?.copyWith(
                          color: scheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


class _SentenceVocabHint {
  const _SentenceVocabHint({required this.meaningKo, required this.word});

  final String meaningKo;
  final String word;
}

