import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/daily_progress_sync.dart';
import '../utils/kst_date.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  DailyProgressView? _progress;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final p = await ensureTodayDailyProgress(user);
    if (!mounted) return;
    setState(() {
      _progress = p;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final p = _progress;
    return Scaffold(
      appBar: AppBar(title: const Text('진행률')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : (p == null)
                ? Text('진행률 데이터가 없습니다.', style: TextStyle(color: scheme.error))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '오늘의 진행률 · ${todayKstYyyyMmDd()}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: (p.progressPercent / 100).clamp(0.0, 1.0),
                        minHeight: 14,
                        color: p.progressPercent >= 80
                            ? Colors.green
                            : p.progressPercent >= 40
                                ? Colors.orange
                                : Colors.red,
                      ),
                      const SizedBox(height: 8),
                      Text('${p.progressPercent}%'),
                      const SizedBox(height: 16),
                      Text('단어 ${p.wordDone}/${p.wordGoal}'),
                      Text('문장 ${p.sentenceDone}/${p.sentenceGoal}'),
                      Text('퀴즈 ${p.quizDone}/${p.quizGoal}'),
                      const SizedBox(height: 20),
                      Text(
                        '캘린더 스티커 기능은 다음 단계에서 구현합니다.',
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
