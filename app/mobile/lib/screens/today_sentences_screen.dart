import 'package:cloud_functions/cloud_functions.dart';
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

  Future<void> _fetchSentenceSample() async {
    setState(() {
      _aiLoading = true;
      _aiError = null;
      _sentence = null;
      _sentenceHira = null;
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
        'targetLanguage': widget.targetLanguage,
        'level': widget.level,
      });

      final data = Map<String, dynamic>.from(result.data as Map);
      final sentence = data['sentence']?.toString() ?? '';
      final sentenceHira = data['sentenceHira']?.toString();
      final meaning = data['meaningKo']?.toString() ?? '';
      final debugSource = data['debugSource']?.toString();

      if (!mounted) return;
      setState(() {
        _sentence = sentence;
        _sentenceHira = sentenceHira;
        _meaning = meaning;
        _debugSource = debugSource;
        _aiLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _aiError = l10n.sentences_ai_sample_load_failed(e.toString());
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
            Text(
              _sentenceCapReached && !_relearnActive
                  ? l10n.sentences_description_goal_reached(
                      _todayProgress?.sentenceGoal ?? 10,
                    )
                  : _sentenceCapReached && _relearnActive
                      ? l10n.sentences_description_relearn_mode
                      : l10n.sentences_description_normal,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            if (_aiLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Text(l10n.sentences_loading_sample,
                  style: TextStyle(color: scheme.onSurfaceVariant)),
            ] else if (_aiError != null) ...[
              Text(_aiError!, style: TextStyle(color: scheme.error)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: _fetchSentenceSample,
                child: Text(l10n.sentences_sample_reload),
              ),
            ] else ...[
              Text(
                _sentence ?? '-',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              if (showHiraLine) ...[
                const SizedBox(height: 8),
                Text(
                  _sentenceHira!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
              ],
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

