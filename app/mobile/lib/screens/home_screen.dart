import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/daily_progress_sync.dart';
import '../services/user_profile_sync.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _profileError;
  DailyProgressView? _todayProgress;
  bool _loadingProgress = true;

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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '로그인됨',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            SelectableText('UID: ${user?.uid ?? '-'}'),
            const SizedBox(height: 8),
            SelectableText('이메일: ${user?.email ?? '-'}'),
            if (_profileError != null) ...[
              const SizedBox(height: 16),
              Text(
                _profileError!,
                style: TextStyle(color: scheme.error),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              '오늘의 진도 (KST)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_loadingProgress)
              const LinearProgressIndicator()
            else if (p != null) ...[
              SelectableText('날짜 키: ${p.dateKst}'),
              const SizedBox(height: 8),
              Text(
                '단어: ${p.wordDone} / ${p.wordGoal} · 문장: ${p.sentenceDone} / ${p.sentenceGoal} · 퀴즈: ${p.quizDone} / ${p.quizGoal}',
              ),
              const SizedBox(height: 4),
              Text('진행률(저장값): ${p.progressPercent}%'),
            ],
            const SizedBox(height: 24),
            Text(
              'Firestore: users/{uid} 및 users/{uid}/daily_progress/{yyyy-MM-dd}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
