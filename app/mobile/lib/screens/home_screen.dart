import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/daily_progress_sync.dart';
import '../services/user_profile_sync.dart';
import '../ui/home_feature_card.dart';
import '../ui/section_card.dart';
import 'today_sentences_screen.dart';
import 'today_words_screen.dart';
import 'word_quiz_screen.dart';
import '../utils/kst_date.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _profileError;
  DailyProgressView? _todayProgress;
  bool _loadingProgress = true;

  bool _fnLoading = false;
  String? _fnResult;
  String? _fnError;

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
      final progress = await ensureTodayDailyProgress(user);
      if (!mounted) return;
      setState(() {
        _todayProgress = progress;
        _profileError = null;
        _loadingProgress = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _profileError = '프로필 또는 진도 동기화 실패: $e';
        _loadingProgress = false;
      });
    }
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

  Future<void> _fetchSampleWord() async {
    setState(() {
      _fnLoading = true;
      _fnError = null;
      _fnResult = null;
    });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('로그인 상태가 아닙니다.');
      }
      // 로그인 직후 토큰이 아직 전파되지 않아 callable에서 unauthenticated가 뜨는 케이스가 있어
      // 호출 전에 토큰을 강제로 갱신합니다.
      await user.getIdToken(true);

      final callable = FirebaseFunctions.instanceFor(
        region: 'asia-northeast3',
      ).httpsCallable('generateWord');
      final result = await callable.call<Map<String, dynamic>>({
        'targetLanguage': 'ja',
        'level': 'beginner',
      });
      final data = Map<String, dynamic>.from(result.data as Map);
      final word = data['word']?.toString() ?? '';
      final meaning = data['meaningKo']?.toString() ?? '';
      final example = data['example']?.toString();
      final buf = StringBuffer('$word — $meaning');
      if (example != null && example.isNotEmpty) {
        buf.write('\n예문: $example');
      }
      if (!mounted) return;
      setState(() {
        _fnResult = buf.toString();
        _fnLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _fnError = '함수 호출 실패: $e';
        _fnLoading = false;
      });
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
    final user = FirebaseAuth.instance.currentUser;
    final scheme = Theme.of(context).colorScheme;
    final p = _todayProgress;
    final percent = p == null
        ? null
        : (p.progressPercent > 0 ? p.progressPercent : _computedProgressPercent(p));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Language"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () => FirebaseAuth.instance.signOut(),
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
                    '홈',
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
              childAspectRatio: 1.05,
              children: [
                HomeFeatureCard(
                  title: '오늘의 단어',
                  subtitle: '매일 50개',
                  icon: Icons.translate,
                  progressText: p == null ? null : '${p.wordDone} / ${p.wordGoal}',
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (_) => const TodayWordsScreen(),
                      ),
                    )
                        .then((_) => _refreshTodayProgress());
                  },
                ),
                HomeFeatureCard(
                  title: '오늘의 문장',
                  subtitle: '매일 10개',
                  icon: Icons.format_quote,
                  progressText: p == null
                      ? null
                      : '${p.sentenceDone} / ${p.sentenceGoal}',
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (_) => const TodaySentencesScreen(),
                      ),
                    )
                        .then((_) => _refreshTodayProgress());
                  },
                ),
                HomeFeatureCard(
                  title: '단어 퀴즈',
                  subtitle: '4지선다',
                  icon: Icons.quiz_outlined,
                  progressText: p == null ? null : '${p.quizDone} / ${p.quizGoal}',
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (_) => const WordQuizScreen(),
                      ),
                    )
                        .then((_) => _refreshTodayProgress());
                  },
                ),
                HomeFeatureCard(
                  title: 'AI 단어 샘플',
                  subtitle: '프로토타입',
                  icon: Icons.auto_stories_outlined,
                  onTap: _fnLoading ? () {} : _fetchSampleWord,
                  progressText: _fnResult == null ? null : '응답 수신됨',
                ),
              ],
            ),

            const SizedBox(height: 16),
            SectionCard(
              title: '오늘의 진행률',
              subtitle: 'KST · ${todayKstYyyyMmDd()}',
              child: _loadingProgress
                  ? const LinearProgressIndicator()
                  : (percent == null)
                      ? Text('데이터가 없습니다.', style: TextStyle(color: scheme.error))
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
                                Text('$percent%'),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (p != null)
                              Text(
                                '단어 ${p.wordDone}/${p.wordGoal} · 문장 ${p.sentenceDone}/${p.sentenceGoal} · 퀴즈 ${p.quizDone}/${p.quizGoal}',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(color: scheme.onSurfaceVariant),
                              ),
                            if (_fnError != null) ...[
                              const SizedBox(height: 10),
                              Text(_fnError!, style: TextStyle(color: scheme.error)),
                            ],
                            if (_fnResult != null) ...[
                              const SizedBox(height: 10),
                              SelectableText(_fnResult!),
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
