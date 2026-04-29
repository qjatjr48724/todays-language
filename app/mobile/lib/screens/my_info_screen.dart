import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../auth_gate.dart';
import 'admin_tools_screen.dart';
import '../l10n/app_localizations.dart';

class MyInfoScreen extends StatelessWidget {
  const MyInfoScreen({super.key, this.embedded = false});

  final bool embedded;
  static const _testAdminUid = AdminToolsScreen.testAdminUid;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    if (user == null) {
      final child = Center(
        child: Text(
          l10n.my_info_login_required,
          style: TextStyle(color: scheme.onSurfaceVariant),
        ),
      );
      if (embedded) return child;
      return Scaffold(
        appBar: AppBar(title: Text(l10n.my_info_screen_title)),
        body: child,
      );
    }

    final docStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();
    final isAdmin = user.uid == _testAdminUid;

    final content = StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: docStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              l10n.my_info_load_failed_error(
                (snapshot.error?.toString() ?? '').isEmpty
                    ? '-'
                    : snapshot.error.toString(),
              ),
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.error),
            ),
          );
        }
        final data = snapshot.data?.data() ?? <String, dynamic>{};
        final displayName = (data['displayName'] as String?)?.trim();
        final provider = (data['provider'] as String?) ?? 'unknown';
        final nativeLanguage = (data['nativeLanguage'] as String?) ?? 'KOR';
        final targetLanguage = (data['targetLanguage'] as String?) ?? 'JPN';
        final level = (data['level'] as String?) ?? 'beginner';
        final createdAt = data['createdAt'];

        String createdText = '-';
        if (createdAt is Timestamp) {
          final dt = createdAt.toDate();
          createdText =
              '${dt.year.toString().padLeft(4, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
        }

        final shownName = (displayName == null || displayName.isEmpty)
            ? (user.email?.split('@').first ?? l10n.my_info_user_fallback_name)
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
                      if (isAdmin)
                        IconButton(
                          tooltip: l10n.my_info_admin_tools_tooltip,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AdminToolsScreen()),
                            );
                          },
                          icon: const Icon(Icons.admin_panel_settings_outlined),
                        ),
                      Text(
                        l10n.my_info_first_joined_at_prefix(createdText),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _providerLabel(provider, l10n),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Divider(color: scheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    l10n.my_info_settings_language_header,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _LanguageRow(
                    label: l10n.my_info_local_language_label,
                    alpha3: nativeLanguage,
                  ),
                  const SizedBox(height: 4),
                  _LanguageRow(
                    label: l10n.my_info_target_language_label,
                    alpha3: targetLanguage,
                  ),
                  const SizedBox(height: 12),
                  Divider(color: scheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    l10n.my_info_difficulty_header,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _levelLabel(level, l10n),
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: OutlinedButton.icon(
                          onPressed: () => _openLevelPicker(
                            context,
                            currentLevel: level,
                            targetLanguage: targetLanguage,
                          ),
                          icon: const Icon(Icons.tune, size: 18),
                          label: Text(l10n.my_info_change_button),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(color: scheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    l10n.my_info_device_change_header,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: OutlinedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.my_info_backup_not_ready_snackbar),
                          ),
                        );
                      },
                      child: Text(l10n.my_info_backup_button),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          minimumSize: const Size(0, 40),
                        ),
                        icon: const Icon(Icons.logout, size: 18),
                        label: Text(l10n.my_info_logout_button),
                        onPressed: () async {
                          // 로그아웃 시 StreamBuilder가 permission error를 뿜기 전에
                          // 2초 로딩을 보여주고 로그인/회원가입(AuthGate)로 이동합니다.
                          showDialog<void>(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              final scheme = Theme.of(context).colorScheme;
                              return PopScope(
                                canPop: false,
                                child: AlertDialog(
                                  content: Row(
                                    children: [
                                      const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          l10n.my_info_logout_loading,
                                          style: TextStyle(color: scheme.onSurface),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );

                          await FirebaseAuth.instance.signOut();
                          await Future<void>.delayed(const Duration(seconds: 2));
                          if (!context.mounted) return;

                          // 다이얼로그 닫기
                          Navigator.of(context, rootNavigator: true).pop();

                          // 내 정보(탭/스택) 상태를 끊고 AuthGate로 복귀
                          Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                            MaterialPageRoute(builder: (_) => const AuthGate()),
                            (route) => false,
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          minimumSize: const Size(0, 40),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.my_info_review_not_ready_snackbar,
                              ),
                            ),
                          );
                        },
                        child: Text(l10n.my_info_review_button),
                      ),
                    ],
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
          tooltip: l10n.my_info_back_tooltip,
        ),
        title: Text(l10n.my_info_screen_title),
        actions: [
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings_outlined),
              tooltip: l10n.my_info_admin_tools_tooltip,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminToolsScreen()),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.language),
            tooltip: l10n.my_info_language_settings_tooltip,
            onPressed: () => _openLanguagePicker(context),
          ),
        ],
      ),
      body: content,
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.alpha3,
  });

  final String label;
  final String alpha3;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('public_metadata')
          .doc('countries')
          .collection('items')
          .doc(alpha3.toUpperCase())
          .get(),
      builder: (context, snapshot) {
        final rowL10n = AppLocalizations.of(context)!;
        final data = snapshot.data?.data();
        final endonym = (data?['endonym'] as String?)?.trim();
        final flagUrl = (data?['flagUrl'] as String?)?.trim();
        final name = (endonym == null || endonym.isEmpty)
            ? _languageLabel(alpha3, rowL10n)
            : endonym;
        return Row(
          children: [
            Text(
              '$label : ',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(width: 6),
            _FlagThumb(url: flagUrl),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Text(
              alpha3.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ],
        );
      },
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

Future<void> _openLanguagePicker(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;
  final l10n = AppLocalizations.of(context)!;

  final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  final snap = await docRef.get();
  if (!context.mounted) return;
  final data = snap.data() ?? <String, dynamic>{};
  final currentRaw = (data['targetLanguage'] as String?) ?? 'JPN';
  final current = _normalizeTargetLanguageAlpha3(currentRaw);

  String selected = current;
  final enabledCountries = await FirebaseFirestore.instance
      .collection('public_metadata')
      .doc('countries')
      .collection('items')
      .where('enabled', isEqualTo: true)
      .get();
  if (!context.mounted) return;
  final allCountries = await FirebaseFirestore.instance
      .collection('public_metadata')
      .doc('countries')
      .collection('items')
      .get();
  if (!context.mounted) return;

  final enabled = enabledCountries.docs
      .map((d) => d.data())
      .toList(growable: false);
  final disabled = allCountries.docs
      .map((d) => d.data())
      .where((m) => (m['enabled'] as bool?) != true)
      .toList(growable: false);

  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.my_info_language_picker_title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      ...enabled.map((m) {
                        final alpha3 = (m['alpha3'] as String?)?.trim().toUpperCase() ?? '';
                        final endonym = (m['endonym'] as String?)?.trim() ?? alpha3;
                        final flagUrl = (m['flagUrl'] as String?)?.trim();
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: _FlagThumb(url: flagUrl),
                          title: Text(endonym),
                          subtitle: Text(alpha3),
                          trailing: selected == alpha3 ? const Icon(Icons.check) : null,
                          onTap: () => setState(() => selected = alpha3),
                        );
                      }),
                      const SizedBox(height: 8),
                      Text(
                        l10n.my_info_language_picker_additional_disabled,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      ...disabled.map((m) {
                        final alpha3 = (m['alpha3'] as String?)?.trim().toUpperCase() ?? '';
                        final endonym = (m['endonym'] as String?)?.trim() ?? alpha3;
                        final flagUrl = (m['flagUrl'] as String?)?.trim();
                        return ListTile(
                          enabled: false,
                          contentPadding: EdgeInsets.zero,
                          leading: _FlagThumb(url: flagUrl),
                          title: Text(endonym),
                          subtitle: Text(alpha3),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.common_cancel),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(l10n.common_save),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
  if (!context.mounted) return;

  if (confirmed != true) return;

  // 1) 유저 프로필 업데이트
  await docRef.set({'targetLanguage': selected}, SetOptions(merge: true));
  if (!context.mounted) return;

  // 2) 선택된 언어의 "오늘 세트"가 없으면 즉시 생성(사용자 액션 기반)
  try {
    await user.getIdToken(true);
    final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast3')
        .httpsCallable('ensureLearningSetForToday');
    await callable.call<Map<String, dynamic>>({
      'targetLanguage': selected,
      'level': 'beginner',
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.my_info_language_saved_snackbar)),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.my_info_language_save_failed_snackbar(e.toString()),
        ),
      ),
    );
  }
}

Future<void> _openLevelPicker(
  BuildContext context, {
  required String currentLevel,
  required String targetLanguage,
}) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final l10n = AppLocalizations.of(context)!;

  final normalizedCurrent = _normalizeLevel(currentLevel);
  String selected = normalizedCurrent;

  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          Widget tile(String value, String label) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(label),
              trailing: selected == value ? const Icon(Icons.check) : null,
              onTap: () => setState(() => selected = value),
            );
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.my_info_difficulty_picker_title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                tile('beginner', l10n.my_info_difficulty_tile_beginner_label),
                tile(
                  'intermediate',
                  l10n.my_info_difficulty_tile_intermediate_label,
                ),
                tile('advanced', l10n.my_info_difficulty_tile_advanced_label),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(l10n.common_cancel),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(l10n.common_save),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    },
  );
  if (!context.mounted) return;
  if (confirmed != true) return;

  final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
  await docRef.set({'level': selected}, SetOptions(merge: true));
  if (!context.mounted) return;

  // 선택된 난이도의 "오늘 세트"가 없으면 즉시 생성(사용자 액션 기반)
  try {
    await user.getIdToken(true);
    final callable = FirebaseFunctions.instanceFor(region: 'asia-northeast3')
        .httpsCallable('ensureLearningSetForToday');
    await callable.call<Map<String, dynamic>>({
      'targetLanguage': targetLanguage,
      'level': selected,
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.my_info_difficulty_saved_snackbar)),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.my_info_difficulty_save_failed_snackbar(e.toString()),
        ),
      ),
    );
  }
}

String _normalizeTargetLanguageAlpha3(String raw) {
  final v = raw.trim();
  if (v.isEmpty) return 'JPN';
  switch (v.toLowerCase()) {
    case 'ja':
      return 'JPN';
    case 'es':
      return 'ESP';
    default:
      return v.toUpperCase();
  }
}

String _normalizeLevel(String raw) {
  final v = raw.trim().toLowerCase();
  switch (v) {
    case 'beginner':
    case 'intermediate':
    case 'advanced':
      return v;
    default:
      return 'beginner';
  }
}

String _levelLabel(String raw, AppLocalizations l10n) {
  switch (_normalizeLevel(raw)) {
    case 'beginner':
      return l10n.level_beginner_label;
    case 'intermediate':
      return l10n.level_intermediate_label;
    case 'advanced':
      return l10n.level_advanced_label;
  }
  return l10n.level_beginner_label;
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

String _providerLabel(String provider, AppLocalizations l10n) {
  switch (provider) {
    case 'google':
      return l10n.provider_google_label;
    case 'apple':
      return l10n.provider_apple_label;
    case 'email':
      return l10n.provider_email_label;
    default:
      return l10n.provider_unknown_label;
  }
}

String _languageLabel(String code, AppLocalizations l10n) {
  switch (code) {
    // ISO-3166-1 alpha-3 (프로젝트 내부 표준)
    case 'KOR':
      return l10n.language_kor_label;
    case 'JPN':
      return l10n.language_jpn_label;
    case 'ESP':
      return l10n.language_esp_label;
    case 'USA':
      return l10n.language_usa_label;
    default:
      return code;
  }
}
