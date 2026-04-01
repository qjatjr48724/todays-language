import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyInfoScreen extends StatelessWidget {
  const MyInfoScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final scheme = Theme.of(context).colorScheme;

    if (user == null) {
      final child = Center(
        child: Text(
          '로그인 후 이용할 수 있습니다.',
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
      if (embedded) return child;
      return Scaffold(
        appBar: AppBar(title: const Text('내 정보')),
        body: child,
      );
    }

    final docStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();

    final content = StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docStream,
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? <String, dynamic>{};
        final displayName = (data['displayName'] as String?)?.trim();
        final provider = (data['provider'] as String?) ?? 'unknown';
        final nativeLanguage = (data['nativeLanguage'] as String?) ?? 'ko';
        final targetLanguage = (data['targetLanguage'] as String?) ?? 'ja';
        final createdAt = data['createdAt'];

        String createdText = '-';
        if (createdAt is Timestamp) {
          final dt = createdAt.toDate();
          createdText =
              '${dt.year.toString().padLeft(4, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
        }

        final shownName = (displayName == null || displayName.isEmpty)
            ? (user.email?.split('@').first ?? '사용자')
            : displayName;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Container(
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        shownName,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(width: 8),
                      _ProviderBadge(provider: provider),
                      const Spacer(),
                      Text(
                        '최초 가입일 : $createdText',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _providerLabel(provider),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: scheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    '설정된 언어',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '로컬언어 : ${_languageLabel(nativeLanguage)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '대상언어 : ${_languageLabel(targetLanguage)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 12),
                  Divider(color: scheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    '기기변경',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('백업 기능은 다음 단계에서 구현합니다.')),
                        );
                      },
                      child: const Text('전체 데이터 백업'),
                    ),
                  ),
                  const SizedBox(height: 280),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('리뷰 작성 연결은 다음 단계에서 구현합니다.')),
                        );
                      },
                      child: const Text('리뷰 작성하기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (embedded) {
      return SafeArea(
        top: true,
        bottom: false,
        child: content,
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: '뒤로가기',
        ),
        title: const Text('내 정보'),
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: '언어 설정',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('언어 변경 기능은 다음 단계에서 연결합니다.')),
              );
            },
          ),
        ],
      ),
      body: content,
    );
  }
}

class _ProviderBadge extends StatelessWidget {
  const _ProviderBadge({required this.provider});

  final String provider;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    IconData icon;
    Color color;

    switch (provider) {
      case 'google':
        icon = Icons.g_mobiledata_rounded;
        color = Colors.redAccent;
      case 'apple':
        icon = Icons.apple;
        color = Colors.black87;
      case 'email':
        icon = Icons.email_outlined;
        color = scheme.primary;
      default:
        icon = Icons.person_outline;
        color = scheme.primary;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.14),
        border: Border.all(color: color),
      ),
      child: Icon(icon, size: 18, color: color),
    );
  }
}

String _providerLabel(String provider) {
  switch (provider) {
    case 'google':
      return '로그인 방식 : Google';
    case 'apple':
      return '로그인 방식 : Apple';
    case 'email':
      return '로그인 방식 : Email';
    default:
      return '로그인 방식 : Unknown';
  }
}

String _languageLabel(String code) {
  switch (code) {
    case 'ko':
      return '한국어';
    case 'ja':
      return '일본어(히라가나)';
    case 'en':
      return '영어';
    default:
      return code;
  }
}
