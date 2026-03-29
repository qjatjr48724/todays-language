import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/user_profile_sync.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _profileError;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      ensureUserProfileDocument(user).catchError((Object e) {
        if (mounted) {
          setState(() => _profileError = '프로필 저장 실패: $e');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final scheme = Theme.of(context).colorScheme;

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
              'Firestore에 users/{uid}가 동기화됩니다. 콘솔에서 데이터를 확인해 보세요.',
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
