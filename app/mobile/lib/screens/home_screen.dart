import 'package:firebase_auth/firebase_auth.dart';
import '../config/firebase_functions_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import '../config/feature_flags.dart';
import '../services/daily_progress_sync.dart';
import '../services/user_profile_sync.dart';
import '../models/curriculum_state.dart';
import '../services/user_prefs.dart';
import '../ui/bordered_linear_progress.dart';
import '../ui/home_feature_card.dart';
import '../ui/section_card.dart';
import '../services/analytics/analytics_action_log.dart';
import '../services/analytics/analytics_navigation.dart';
import '../services/analytics/analytics_screens.dart';
import 'my_info_screen.dart';
import 'curriculum_review_screen.dart';
import 'today_sentences_screen.dart';
import 'random_words_screen.dart';
import 'today_words_screen.dart';
import 'today_wrap_up_screen.dart';
import 'basic_character_chart_screen.dart';
import '../l10n/app_localizations.dart';
import '../services/curriculum_topic_label_repository.dart';
import '../ui/curriculum_topic_label_text.dart';
import '../utils/kst_date.dart';

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
  StreamSubscription? _profileSub;
  String? _curriculumTopicLabel;
  final _curriculumTopicLabels = CurriculumTopicLabelRepository();

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
      await reconcilePendingLearningDayAdvances(user);
      final prefs = await fetchUserPrefs(user);
      final progress = await ensureTodayDailyProgress(
        user,
        targetLanguage: prefs.targetLanguage,
      );
      if (!mounted) return;
      setState(() {
        _prefs = prefs;
        _todayProgress = progress;
        _profileError = null;
        _loadingProgress = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _refreshCurriculumTopicLabel();
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
        final nextTargetLanguage =
            (tl == null || tl.isEmpty) ? _prefs.targetLanguage : tl;
        final languageChanged = nextTargetLanguage != _prefs.targetLanguage;
        if (!mounted) return;
        setState(() {
          _prefs = UserPrefs(
            targetLanguage: nextTargetLanguage,
            level: effectiveLearningLevel(lv),
            curriculum: CurriculumState.fromUserData(
              data,
              targetLanguage: nextTargetLanguage,
            ),
            previewLearningDay: CurriculumState.adminPreviewDayForLanguage(
              data,
              nextTargetLanguage,
            ),
            reviewLearningDay: CurriculumState.curriculumReviewDayForLanguage(
              data,
              nextTargetLanguage,
            ),
          );
        });
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _refreshCurriculumTopicLabel();
        });
        if (languageChanged) {
          _refreshTodayProgress();
        }
      }, onError: (_) {
        // Firestore 규칙/네트워크 이슈 등으로 스트림이 실패해도 홈 흐름을 깨지지 않게 함
      });

      // 개발 단계: 홈 진입을 막지 않고 백그라운드로 세트 생성 워밍업을 시도합니다.
      if (kDebugMode) {
        Future<void>(() async {
          try {
            await user.getIdToken(true);
            final callable = callableEnsureTodayLearningSets();
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
      final p = await ensureTodayDailyProgress(
        user,
        targetLanguage: _prefs.targetLanguage,
      );
      if (!mounted) return;
      setState(() => _todayProgress = p);
    } catch (_) {
      // 홈 새로고침 실패는 UI 흐름을 막지 않음
    }
  }


  /// 커리큘럼 모드일 때 현재 일차 주제명을 UI 로컬에 맞게 로드합니다.
  Future<void> _refreshCurriculumTopicLabel() async {
    if (!mounted) return;
    final languageCode = Localizations.localeOf(context).languageCode;
    final shouldShow = CurriculumState.usesCurriculumLearningSets(
      level: _prefs.level,
      learningMode: _prefs.curriculum.learningMode,
    );
    if (!shouldShow) {
      if (_curriculumTopicLabel != null) {
        setState(() => _curriculumTopicLabel = null);
      }
      return;
    }

    final label = await _curriculumTopicLabels.labelForLearningDay(
      _prefs.displayLearningDay,
      languageCode,
    );
    if (!mounted) return;
    setState(() => _curriculumTopicLabel = label);
  }

  int _computedProgressPercent(DailyProgressView p) {
    final totalGoal = p.wordGoal + p.sentenceGoal + p.quizGoal;
    if (totalGoal <= 0) return 0;
    final totalDone = p.wordDone + p.sentenceDone + p.quizDone;
    return ((totalDone / totalGoal) * 100).round().clamp(0, 100);
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

    final showReviewMenu = _prefs.curriculum.learningDay > 1 &&
        _prefs.curriculum.learningMode == 'curriculum';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Text(homeAppBarTitle(context)),
        actions: [
          if (user?.email != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 160),
                  child: Text(
                    user!.email!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ),
            ),
          if (widget.showMyInfoButton)
            IconButton(
              icon: const Icon(Icons.person_outline),
              tooltip: l10n.home_my_info_tooltip,
              onPressed: () {
                pushAnalyticsScreen(
                  context,
                  screenName: AnalyticsScreens.myInfo,
                  builder: (_) => const MyInfoScreen(),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_profileError != null) ...[
              const SizedBox(height: 8),
              Text(_profileError!, style: TextStyle(color: scheme.error)),
            ],
            if (_prefs.previewLearningDay != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  l10n.home_curriculum_preview_banner(_prefs.previewLearningDay!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: scheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ],
            const SizedBox(height: 12),

            // 기초문자표 · 랜덤 단어 — 같은 행
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.3,
              children: [
                HomeFeatureCard(
                  title: l10n.home_basic_characters_button,
                  subtitle: l10n.home_basic_characters_subtitle,
                  icon: Icons.grid_on_outlined,
                  onTap: () {
                    logHomeCardTap('basic_characters');
                    pushAnalyticsScreen(
                      context,
                      screenName: AnalyticsScreens.basicCharacterChart,
                      builder: (_) => const BasicCharacterChartScreen(),
                    ).then((_) => _refreshTodayProgress());
                  },
                ),
                HomeFeatureCard(
                  title: l10n.home_random_words_title,
                  subtitle: l10n.home_random_words_subtitle,
                  icon: Icons.casino_outlined,
                  onTap: () {
                    logHomeCardTap('random_words');
                    pushAnalyticsScreen(
                      context,
                      screenName: AnalyticsScreens.randomWords,
                      builder: (_) => RandomWordsScreen(
                        targetLanguage: _prefs.targetLanguage,
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              // 카드 높이 축소 — progressText(0/15)는 유지한 채 부제·패딩으로 공간 확보
              childAspectRatio: 1.3,
              children: [
                HomeFeatureCard(
                  title: l10n.home_today_words_title,
                  subtitle: l10n.home_today_words_subtitle,
                  icon: Icons.translate,
                  progressText: p == null ? null : '${p.wordDone} / ${p.wordGoal}',
                  onTap: () {
                    logHomeCardTap('today_words');
                    pushAnalyticsScreen(
                      context,
                      screenName: AnalyticsScreens.todayWords,
                      builder: (_) => TodayWordsScreen(
                        targetLanguage: _prefs.targetLanguage,
                        level: _prefs.level,
                      ),
                    ).then((_) => _refreshTodayProgress());
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
                    logHomeCardTap('today_sentences');
                    pushAnalyticsScreen(
                      context,
                      screenName: AnalyticsScreens.todaySentences,
                      builder: (_) => TodaySentencesScreen(
                        targetLanguage: _prefs.targetLanguage,
                        level: _prefs.level,
                      ),
                    ).then((_) => _refreshTodayProgress());
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
                          logHomeCardTap('today_wrap_up');
                          pushAnalyticsScreen(
                            context,
                            screenName: AnalyticsScreens.todayWrapUp,
                            builder: (_) => TodayWrapUpScreen(
                              targetLanguage: _prefs.targetLanguage,
                              level: _prefs.level,
                            ),
                          ).then((_) => _refreshTodayProgress());
                        }
                      : () {
                          logHomeCardTap('today_wrap_up', locked: true);
                        },
                ),
              ],
            ),

            if (showReviewMenu) ...[
              const SizedBox(height: 12),
              HomeFeatureCard(
                title: l10n.home_curriculum_review_card_title,
                subtitle: l10n.home_curriculum_review_card_subtitle,
                icon: Icons.history_edu_outlined,
                compactRow: true,
                onTap: () {
                  logHomeCardTap('curriculum_review');
                  pushAnalyticsScreen(
                    context,
                    screenName: AnalyticsScreens.curriculumReview,
                    builder: (_) => CurriculumReviewScreen(
                      targetLanguage: _prefs.targetLanguage,
                      level: _prefs.level,
                      currentLearningDay: _prefs.curriculum.learningDay,
                      curriculumPhase: _prefs.curriculum.curriculumPhase,
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 12),
            SectionCard(
              title: l10n.home_progress_section_title,
              trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    l10n.home_progress_section_subtitle_prefix(todayKstYyyyMmDd()),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  if (_prefs.curriculum.learningMode == 'curriculum') ...[
                    Text(
                      l10n.home_curriculum_day_label(
                        _prefs.displayLearningDay,
                        CurriculumState.totalDays,
                      ),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    CurriculumTopicLabelText(
                      label: _curriculumTopicLabel,
                      compact: true,
                    ),
                  ],
                ],
              ),
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
                                  child: BorderedLinearProgress(
                                    percent: percent,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(l10n.common_percent(percent)),
                              ],
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}


/// 홈 AppBar 제목 — 디바이스 로케일 기준.
///
/// ko/en/ja는 [AppLocalizations.home_appbar_title], zh는 앱 UI 미지원이므로
/// 고정 중국어 문구, 그 외 언어는 영어 l10n으로 fallback.
String resolveHomeAppBarTitle(
  Locale deviceLocale,
  AppLocalizations l10n, {
  AppLocalizations? englishL10n,
}) {
  final lang = deviceLocale.languageCode.toLowerCase();

  if (lang == 'zh') {
    return deviceLocale.scriptCode == 'Hant' ? '今日語言' : '今日的语言';
  }

  if (lang == 'ko' || lang == 'ja' || lang == 'en') {
    return l10n.home_appbar_title;
  }

  final en = englishL10n ?? lookupAppLocalizations(const Locale('en'));
  return en.home_appbar_title;
}


String homeAppBarTitle(BuildContext context) {
  final deviceLocale = View.of(context).platformDispatcher.locale;
  final l10n = AppLocalizations.of(context)!;
  return resolveHomeAppBarTitle(deviceLocale, l10n);
}
