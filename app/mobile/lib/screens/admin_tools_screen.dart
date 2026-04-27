import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'language_setup_screen.dart';
import 'target_language_setup_screen.dart';

class AdminToolsScreen extends StatefulWidget {
  const AdminToolsScreen({super.key});

  static const testAdminUid = 'WhyAQoWSP4Ociipn0HQtxCwQboN2';

  @override
  State<AdminToolsScreen> createState() => _AdminToolsScreenState();
}

class _AdminToolsScreenState extends State<AdminToolsScreen> {
  bool _busy = false;
  String? _error;
  int _countryStatusNonce = 0;

  Future<void> _run(Future<void> Function() fn) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await fn();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('완료')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String title, String message) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('실행'),
            ),
          ],
        );
      },
    );
    return ok == true;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = user != null && user.uid == AdminToolsScreen.testAdminUid;

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('관리자 도구')),
        body: Center(
          child: Text(
            '권한이 없습니다.',
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ),
      );
    }

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final countryCol = FirebaseFirestore.instance
        .collection('public_metadata')
        .doc('countries')
        .collection('items');

    return Scaffold(
      appBar: AppBar(title: const Text('관리자 도구')),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              '테스트 계정 전용',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'uid: ${user.uid}',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),

            _Section(
              title: '언어 선택 플로우',
              children: [
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LanguageSetupScreen()),
                  ),
                  child: const Text('1단계(로컬 언어) 화면 열기'),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TargetLanguageSetupScreen()),
                  ),
                  child: const Text('2단계(대상 언어) 화면 열기'),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    final ok = await _confirm(
                      '언어 선택 초기화',
                      'languageSetupDone을 false로 되돌리고, native/target/variant를 삭제합니다.',
                    );
                    if (!ok) {
                      return;
                    }
                    await _run(() async {
                      await docRef.set(
                        {
                          'languageSetupDone': false,
                          'nativeLanguage': FieldValue.delete(),
                          'targetLanguage': FieldValue.delete(),
                          'targetLanguageVariant': FieldValue.delete(),
                        },
                        SetOptions(merge: true),
                      );
                    });
                  },
                  child: const Text('언어 선택 초기화(다시 처음부터)'),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _Section(
              title: '국가/국기 캐시',
              children: [
                FilledButton.tonal(
                  onPressed: () => _run(() async {
                    await user.getIdToken(true);
                    final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast3')
                        .httpsCallable('seedCountryCatalog');
                    await callable.call<Map<String, dynamic>>({});
                  }),
                  child: const Text('seedCountryCatalog 실행'),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => _run(() async {
                    await user.getIdToken(true);
                    final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast3')
                        .httpsCallable('syncCountryFlags');
                    await callable.call<Map<String, dynamic>>({'force': true});
                  }),
                  child: const Text('syncCountryFlags(force:true) 실행'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _countryStatusNonce++),
                  icon: const Icon(Icons.refresh),
                  label: const Text('캐시 상태 새로고침'),
                ),
                const SizedBox(height: 12),
                FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: countryCol.get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    final docs = snapshot.data?.docs ?? const [];
                    if (docs.isEmpty) {
                      return Text(
                        'public_metadata/countries/items 가 비어있습니다. seedCountryCatalog를 먼저 실행하세요.',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      );
                    }
                    final items = docs
                        .map((d) => d.data())
                        .toList(growable: false);
                    // nonce는 setState로 새로고침 트리거 역할(버튼을 누르면 FutureBuilder가 재빌드됨)
                    // ignore: unused_local_variable
                    final _ = _countryStatusNonce;

                    Widget row(Map<String, dynamic> m) {
                      final alpha3 = (m['alpha3'] as String?)?.trim() ?? '';
                      final endonym = (m['endonym'] as String?)?.trim() ?? '';
                      final enabled = (m['enabled'] as bool?) ?? false;
                      final flagUrl = (m['flagUrl'] as String?)?.trim();
                      final hasFlag = flagUrl != null && flagUrl.isNotEmpty;
                      return ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: _FlagThumb(url: flagUrl),
                        title: Text(endonym.isEmpty ? alpha3 : endonym),
                        subtitle: Text('$alpha3  •  enabled=${enabled ? "true" : "false"}'),
                        trailing: Icon(
                          hasFlag ? Icons.check_circle : Icons.error_outline,
                          color: hasFlag ? scheme.primary : scheme.error,
                        ),
                      );
                    }

                    return Column(
                      children: [
                        ...items.map(row),
                      ],
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),
            _Section(
              title: '학습 세트',
              children: [
                OutlinedButton(
                  onPressed: () => _run(() async {
                    final snap = await docRef.get();
                    final data = snap.data() ?? <String, dynamic>{};
                    final tl = (data['targetLanguage'] as String?)?.trim() ?? 'JPN';
                    final level = (data['level'] as String?)?.trim() ?? 'beginner';
                    await user.getIdToken(true);
                    final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast3')
                        .httpsCallable('ensureLearningSetForToday');
                    await callable.call<Map<String, dynamic>>({
                      'targetLanguage': tl,
                      'level': level,
                    });
                  }),
                  child: const Text('ensureLearningSetForToday(현재 프로필)'),
                ),
              ],
            ),

            if (_busy) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
            ],
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(_error!, style: TextStyle(color: scheme.error)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _FlagThumb extends StatelessWidget {
  const _FlagThumb({required this.url});
  final String? url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Image.network(
        (url ?? ''),
        width: 28,
        height: 20,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 28,
          height: 20,
          color: scheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

