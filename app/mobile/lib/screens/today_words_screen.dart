import '../config/firebase_functions_config.dart';
import '../utils/callable_request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../services/analytics/analytics_action_log.dart';
import '../services/analytics/analytics_screens.dart';
import '../services/daily_progress_sync.dart';
import '../services/learning_audio_service.dart';
import '../l10n/app_localizations.dart';
import '../ui/learning_audio_icon_button.dart';

class TodayWordsScreen extends StatefulWidget {
  const TodayWordsScreen({
    super.key,
    required this.targetLanguage,
    required this.level,
    this.curriculumReviewMode = false,
    this.reviewLearningDay,
    this.embedded = false,
  });

  final String targetLanguage;
  final String level;

  /// 이전 일차 복습 — 진도에 영향 없음.
  final bool curriculumReviewMode;
  final int? reviewLearningDay;

  /// 탭 등 상위 Scaffold 안에 넣을 때 body만 렌더링.
  final bool embedded;

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
  String? _exampleMeaningKo;
  String? _wordAudioPath;
  String? _exampleAudioPath;
  String? _debugSource;
  final _learningAudio = LearningAudioService();
  bool _completedCurrent = false;

  String? _error;

  DailyProgressView? _todayProgress;
  /// 오늘 단어 목표 달성 후 「다음 단어」를 다시 쓰려면 true.
  bool _relearnActive = false;

  bool get _inReviewMode => widget.curriculumReviewMode;

  bool get _wordCapReached =>
      !_inReviewMode &&
      _todayProgress != null &&
      _todayProgress!.wordDone >= _todayProgress!.wordGoal;

  bool get _showRelearnButton => !_inReviewMode && _wordCapReached && !_relearnActive;

  bool get _canUseNextButton =>
      !_aiLoading &&
      !_savingProgress &&
      (_inReviewMode || !_wordCapReached || _relearnActive);

  bool get _canMarkComplete =>
      !_inReviewMode &&
      !_wordCapReached &&
      !(_aiLoading || _aiError != null || _completedCurrent || _savingProgress);

  String get _analyticsScreenName => _inReviewMode
      ? AnalyticsScreens.reviewStudyWords
      : AnalyticsScreens.todayWords;

  @override
  void initState() {
    super.initState();
    _loadTodayProgress();
    _fetchWordSample();
  }

  @override
  void dispose() {
    _learningAudio.dispose();
    super.dispose();
  }

  Future<void> _loadTodayProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final p = await ensureTodayDailyProgress(
        user,
        targetLanguage: widget.targetLanguage,
      );
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
    final l10n = AppLocalizations.of(context)!;
    logLearningRelearnStart(screenName: _analyticsScreenName);
    setState(() => _relearnActive = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.words_relearn_snackbar),
      ),
    );
  }

  Future<void> _onNextSampleTap({bool forceRefreshToken = false}) async {
    await logLearningNextSample(
      screenName: _analyticsScreenName,
      reviewMode: _inReviewMode,
    );
    await _fetchWordSample(forceRefreshToken: forceRefreshToken);
  }

  Future<void> _fetchWordSample({bool forceRefreshToken = false}) async {
    await _learningAudio.stop();
    setState(() {
      _aiLoading = true;
      _aiError = null;
      _word = null;
      _wordReadingHira = null;
      _meaning = null;
      _example = null;
      _exampleMeaningKo = null;
      _wordAudioPath = null;
      _exampleAudioPath = null;
      _debugSource = null;
      _completedCurrent = false;
      _error = null;
    });

    try {
      if (FirebaseAuth.instance.currentUser == null) {
        throw Exception('로그인 상태가 아닙니다.');
      }

      final data = await invokeCallableMap(
        callableGenerateWord(),
        {
          'targetLanguage': widget.targetLanguage,
          'level': widget.level,
        },
        forceRefreshToken: forceRefreshToken,
      );
      final word = data['word']?.toString() ?? '';
      final readingHira = data['readingHira']?.toString();
      final meaning = data['meaningKo']?.toString() ?? '';
      final example = data['example']?.toString();
      final exampleMeaningKo = data['exampleMeaningKo']?.toString();
      final wordAudioPath = data['wordAudioPath']?.toString();
      final exampleAudioPath = data['exampleAudioPath']?.toString();
      final debugSource = data['debugSource']?.toString();

      if (!mounted) return;
      setState(() {
        _word = word;
        _wordReadingHira = readingHira;
        _meaning = meaning;
        _example = example;
        _exampleMeaningKo = exampleMeaningKo;
        _wordAudioPath = wordAudioPath;
        _exampleAudioPath = exampleAudioPath;
        _debugSource = debugSource;
        _aiLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _aiError = l10n.words_ai_sample_load_failed(
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
      final p = await incrementTodayDailyProgress(
        user,
        kind: DailyProgressKind.word,
        targetLanguage: widget.targetLanguage,
      );
      if (!mounted) return;
      setState(() {
        _completedCurrent = true;
        _todayProgress = p;
        if (p.wordDone < p.wordGoal) {
          _relearnActive = false;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.words_completed_snackbar)),
      );
      await logLearningMarkDone(
        screenName: _analyticsScreenName,
        targetLanguage: widget.targetLanguage,
        level: widget.level,
      );
    } catch (e) {
      final l10n = AppLocalizations.of(context)!;
      setState(() => _error = l10n.words_save_failed(e.toString()));
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
        _wordReadingHira != null &&
        _wordReadingHira!.trim().isNotEmpty;
    final body = Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_inReviewMode &&
              widget.reviewLearningDay != null &&
              !widget.embedded) ...[
            Text(
              l10n.words_description_curriculum_review(widget.reviewLearningDay!),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
          ],
            if (_wordCapReached && !_relearnActive) ...[
              Text(
                l10n.words_description_goal_reached(
                  _todayProgress?.wordGoal ?? kDailyWordGoalDefault,
                ),
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
            ] else if (_wordCapReached && _relearnActive) ...[
              Text(
                l10n.words_description_relearn_mode,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
            ],

            if (_aiLoading) ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Text(l10n.words_loading_sample,
                  style: TextStyle(color: scheme.onSurfaceVariant)),
            ] else if (_aiError != null) ...[
              Text(_aiError!, style: TextStyle(color: scheme.error)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => _fetchWordSample(forceRefreshToken: true),
                child: Text(l10n.words_sample_reload),
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      _word ?? '-',
                      style: textTheme.headlineMedium?.copyWith(
                        fontSize: (textTheme.headlineMedium?.fontSize ?? 28) + 4,
                      ),
                    ),
                  ),
                  LearningAudioIconButton(
                    storagePath: _wordAudioPath,
                    tooltip: l10n.learning_audio_play_word,
                    audioService: _learningAudio,
                    onError: (e) => showLearningAudioErrorSnackBar(context, e),
                  ),
                ],
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
                style: textTheme.titleMedium?.copyWith(
                  fontSize: (textTheme.titleMedium?.fontSize ?? 16) + 4,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              if (_example != null && _example!.trim().isNotEmpty) ...[
                const SizedBox(height: 20),
                Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
                const SizedBox(height: 16),
                _WordExampleCard(
                  l10n: l10n,
                  example: _example!.trim(),
                  exampleMeaningKo: _exampleMeaningKo?.trim(),
                  exampleAudioPath: _exampleAudioPath,
                  audioService: _learningAudio,
                ),
              ],
            ],

            const Spacer(),
            if (!_inReviewMode && !_wordCapReached)
              Text(
                l10n.words_description_normal,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            if (kDebugMode && _debugSource != null) ...[
              if (!_wordCapReached) const SizedBox(height: 8),
              Text(
                l10n.words_debug_source(_debugSource!),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
              ),
            ],
            if ((!_inReviewMode && !_wordCapReached) || (kDebugMode && _debugSource != null))
              const SizedBox(height: 12),
            if (!_inReviewMode)
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
                      ? l10n.words_button_goal_reached
                      : _savingProgress
                          ? l10n.words_button_saving
                          : (_completedCurrent
                              ? l10n.words_button_completed_reflected
                              : l10n.words_button_increment),
                ),
              ),
            if (!_inReviewMode) const SizedBox(height: 8),
            if (_showRelearnButton) ...[
              FilledButton.tonalIcon(
                onPressed: (_aiLoading || _savingProgress) ? null : _startRelearn,
                icon: const Icon(Icons.school_outlined),
                label: Text(l10n.words_relearn_button_label),
              ),
              const SizedBox(height: 8),
            ],
            OutlinedButton.icon(
              onPressed: _canUseNextButton ? _onNextSampleTap : null,
              icon: const Icon(Icons.refresh),
              label: Text(l10n.words_next_button_label),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: TextStyle(color: scheme.error)),
            ],
          ],
        ),
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _inReviewMode && widget.reviewLearningDay != null
              ? l10n.words_appbar_title_review(widget.reviewLearningDay!)
              : l10n.words_appbar_title,
        ),
      ),
      body: body,
    );
  }
}


/// 예문·예문 뜻: 오늘의 문장의 문장 속 표현 카드와 동일한 카드 UI 패턴.
class _WordExampleCard extends StatelessWidget {
  const _WordExampleCard({
    required this.l10n,
    required this.example,
    this.exampleMeaningKo,
    this.exampleAudioPath,
    this.audioService,
  });

  final AppLocalizations l10n;
  final String example;
  final String? exampleMeaningKo;
  final String? exampleAudioPath;
  final LearningAudioService? audioService;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final meaning = exampleMeaningKo?.trim() ?? '';
    final bodySize = (textTheme.bodyLarge?.fontSize ?? 16) + 2;

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
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.words_example_section_title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: scheme.onSurface,
                    ),
                  ),
                ),
                LearningAudioIconButton(
                  storagePath: exampleAudioPath,
                  tooltip: l10n.learning_audio_play_example,
                  audioService: audioService,
                  onError: (e) => showLearningAudioErrorSnackBar(context, e),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              example,
              style: textTheme.bodyLarge?.copyWith(
                fontSize: bodySize,
                color: scheme.onSurface,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            if (meaning.isNotEmpty) ...[
              Divider(
                height: 24,
                thickness: 1,
                color: scheme.outlineVariant.withValues(alpha: 0.65),
              ),
              Text(
                meaning,
                style: textTheme.bodyLarge?.copyWith(
                  fontSize: bodySize,
                  color: scheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                  height: 1.35,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

