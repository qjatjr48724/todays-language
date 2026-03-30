import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/daily_progress_sync.dart';
import '../services/user_profile_sync.dart';
import '../ui/section_card.dart';
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final scheme = Theme.of(context).colorScheme;
    final p = _todayProgress;

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
            SectionCard(
              title: '내 계정',
              subtitle: user?.email ?? '-',
              trailing: CircleAvatar(
                radius: 16,
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
                child: const Icon(Icons.person, size: 18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText('UID: ${user?.uid ?? '-'}'),
                  if (_profileError != null) ...[
                    const SizedBox(height: 8),
                    Text(_profileError!, style: TextStyle(color: scheme.error)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: '오늘의 진도',
              subtitle: 'KST · ${todayKstYyyyMmDd()}',
              child: _loadingProgress
                  ? const LinearProgressIndicator()
                  : (p == null)
                      ? Text('데이터가 없습니다.', style: TextStyle(color: scheme.error))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '단어: ${p.wordDone} / ${p.wordGoal} · 문장: ${p.sentenceDone} / ${p.sentenceGoal} · 퀴즈: ${p.quizDone} / ${p.quizGoal}',
                            ),
                            const SizedBox(height: 6),
                            Text('진행률(저장값): ${p.progressPercent}%'),
                          ],
                        ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'AI 프로토타입',
              subtitle: 'Cloud Functions · generateWord',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: _fnLoading ? null : _fetchSampleWord,
                    icon: _fnLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_stories_outlined),
                    label: Text(
                      _fnLoading ? '불러오는 중…' : '샘플 단어 받기',
                    ),
                  ),
                  if (_fnError != null) ...[
                    const SizedBox(height: 12),
                    Text(_fnError!, style: TextStyle(color: scheme.error)),
                  ],
                  if (_fnResult != null) ...[
                    const SizedBox(height: 12),
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
