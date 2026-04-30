import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../services/daily_progress_sync.dart';
import '../services/user_profile_sync.dart';
import '../services/user_prefs.dart';
import '../ui/home_feature_card.dart';
import '../ui/section_card.dart';
import 'my_info_screen.dart';
import 'today_sentences_screen.dart';
import 'today_words_screen.dart';
import 'today_wrap_up_screen.dart';
import '../utils/kst_date.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.showMyInfoButton = true});

  final bool showMyInfoButton;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _profileError;
  DailyProgressView? _todayProgress;
  UserPrefs _prefs = UserPrefs.fallback();
  bool _loadingProgress = true;
  bool _resettingProgress = false;
  StreamSubscription? _profileSub;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _bootstrap(user);
    } else {
      _loadingProgress = false;
    }
  }

  Future<void> _bootstrap(User user) async {
    try {
      await ensureUserProfileDocument(user);
      final prefs = await fetchUserPrefs(user);
      final progress = await ensureTodayDailyProgress(user);
      if (!mounted) return;
      setState(() {
        _prefs = prefs;
        _todayProgress = progress;
        _profileError = null;
        _loadingProgress = false;
      });

      // 유저 프로필(targetLanguage/level)이 변경되면 홈에서 즉시 반영
      _profileSub?.cancel();
      _profileSub = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snap) {
        final data = snap.data() ?? <String, dynamic>{};
        final tl = (data['targetLanguage'] as String?)?.trim();
        final lv = (data['level'] as String?)?.trim();
        if (!mounted) return;
        setState(() {
          _prefs = UserPrefs(
            targetLanguage: (tl == null || tl.isEmpty) ? _prefs.targetLanguage : tl,
            level: (lv == null || lv.isEmpty) ? _prefs.level : lv,
          );
        });
      }, onError: (_) {
        // Firestore 규칙/네트워크 이슈 등으로 스트림이 실패해도 홈 흐름을 깨지지 않게 함
      });

      // 개발 단계: 홈 진입을 막지 않고 백그라운드로 세트 생성 워밍업을 시도합니다.
      if (kDebugMode) {
        Future<void>(() async {
          try {
            await user.getIdToken(true);
            final callable = FirebaseFunctions.instanceFor(
              region: 'asia-northeast3',
            ).httpsCallable('ensureTodayLearningSets');
            await callable.call<Map<String, dynamic>>({
              'dev': true,
              'targetLanguage': _prefs.targetLanguage,
              'level': _prefs.level,
            });
          } catch (_) {
            // 개발 워밍업 실패는 앱 흐름을 막지 않음
          }
        });
      }
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      setState(() {
        _profileError = l10n.home_profile_sync_failed(e.toString());
        _loadingProgress = false;
      });
    }
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    super.dispose();
  }

  Future<void> _refreshTodayProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final p = await ensureTodayDailyProgress(user);
      if (!mounted) return;
      setState(() => _todayProgress = p);
    } catch (_) {
      // 홈 새로고침 실패는 UI 흐름을 막지 않음
    }
  }

  Future<void> _resetTodayProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _resettingProgress = true);
    try {
      final p = await resetTodayDailyProgress(user);
      if (!mounted) return;
      setState(() => _todayProgress = p);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.home_reset_success)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.home_reset_failed(e.toString()))),
      );
    } finally {
      if (mounted) setState(() => _resettingProgress = false);
    }
  }

  Future<void> _confirmAndResetTodayProgress() async {
    if (_resettingProgress) return;
    final l10n = AppLocalizations.of(context)!;
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.home_reset_dialog_title),
          content: Text(l10n.home_reset_dialog_content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.home_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.home_reset),
            ),
          ],
        );
      },
    );

    if (shouldReset == true) {
      await _resetTodayProgress();
    }
  }

  int _computedProgressPercent(DailyProgressView p) {
    final totalGoal = p.wordGoal + p.sentenceGoal + p.quizGoal;
    if (totalGoal <= 0) return 0;
    final totalDone = p.wordDone + p.sentenceDone + p.quizDone;
    return ((totalDone / totalGoal) * 100).round().clamp(0, 100);
  }

  Color _progressColor(ColorScheme scheme, int percent) {
    if (percent >= 80) return Colors.green;
    if (percent >= 40) return Colors.orange;
    return Colors.red;
  }

  double _progressValue01(int percent) {
    // 0%일 때는 채움이 아예 없어 색이 안 보이므로,
    // UI상 최소 표시값을 주되 텍스트는 0%로 유지합니다.
    if (percent <= 0) return 0.02;
    return (percent / 100).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final scheme = Theme.of(context).colorScheme;
    final p = _todayProgress;
    final canOpenWrapUp = p != null &&
        p.wordDone >= p.wordGoal &&
        p.sentenceDone >= p.sentenceGoal;
    final percent = p == null
        ? null
        : (p.progressPercent > 0 ? p.progressPercent : _computedProgressPercent(p));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.launch_subtitle),
        actions: [
          if (widget.showMyInfoButton)
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: l10n.home_my_info_tooltip,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const MyInfoScreen(),
                  ),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.home_home_tab_title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (user?.email != null)
                  Text(
                    user!.email!,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
              ],
            ),
            if (_profileError != null) ...[
              const SizedBox(height: 8),
              Text(_profileError!, style: TextStyle(color: scheme.error)),
            ],
            const SizedBox(height: 16),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              // 카드 안 Column(아이콘행+제목+부제+진행)이 세로로 넉넉히 들어가도록 셀을 약간 높임
              childAspectRatio: 0.9,
              children: [
                HomeFeatureCard(
                  title: l10n.home_today_words_title,
                  subtitle: l10n.home_today_words_subtitle,
                  icon: Icons.translate,
                  progressText: p == null ? null : '${p.wordDone} / ${p.wordGoal}',
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (_) => TodayWordsScreen(
                          targetLanguage: _prefs.targetLanguage,
                          level: _prefs.level,
                        ),
                      ),
                    )
                        .then((_) => _refreshTodayProgress());
                  },
                ),
                HomeFeatureCard(
                  title: l10n.home_today_sentences_title,
                  subtitle: l10n.home_today_sentences_subtitle,
                  icon: Icons.format_quote,
                  progressText: p == null
                      ? null
                      : '${p.sentenceDone} / ${p.sentenceGoal}',
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (_) => TodaySentencesScreen(
                          targetLanguage: _prefs.targetLanguage,
                          level: _prefs.level,
                        ),
                      ),
                    )
                        .then((_) => _refreshTodayProgress());
                  },
                ),
                HomeFeatureCard(
                  title: l10n.home_today_wrap_up_title,
                  subtitle: canOpenWrapUp
                      ? l10n.home_today_wrap_up_subtitle_ready
                      : l10n.home_today_wrap_up_subtitle_locked,
                  icon: Icons.fact_check_outlined,
                  progressText: p == null ? null : '${p.quizDone} / ${p.quizGoal}',
                  enabled: canOpenWrapUp,
                  onTap: canOpenWrapUp
                      ? () {
                          Navigator.of(context)
                              .push(
                            MaterialPageRoute(
                              builder: (_) => TodayWrapUpScreen(
                                targetLanguage: _prefs.targetLanguage,
                                level: _prefs.level,
                              ),
                            ),
                          )
                              .then((_) => _refreshTodayProgress());
                        }
                      : () {},
                ),
              ],
            ),

            const SizedBox(height: 16),
            SectionCard(
              title: l10n.home_progress_section_title,
              subtitle: l10n.home_progress_section_subtitle_prefix(todayKstYyyyMmDd()),
              child: _loadingProgress
                  ? const LinearProgressIndicator()
                  : (percent == null)
                      ? Text(l10n.home_no_data, style: TextStyle(color: scheme.error))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(999),
                                    child: LinearProgressIndicator(
                                      value: _progressValue01(percent),
                                      minHeight: 12,
                                      backgroundColor:
                                          scheme.surfaceContainerHighest,
                                      valueColor: AlwaysStoppedAnimation(
                                        _progressColor(scheme, percent),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                              Text(l10n.common_percent(percent)),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (p != null)
                              Text(
                            l10n.home_progress_counts(
                              p.wordDone,
                              p.wordGoal,
                              p.sentenceDone,
                              p.sentenceGoal,
                              p.quizDone,
                              p.quizGoal,
                            ),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            if (kDebugMode) ...[
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _resettingProgress
                                    ? null
                                    : _confirmAndResetTodayProgress,
                                icon: _resettingProgress
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.restart_alt),
                                label: Text(l10n.home_reset_debug_button_label),
                              ),
                            ],
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
