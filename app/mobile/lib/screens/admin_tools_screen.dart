import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/firebase_functions_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'language_setup_screen.dart';
import 'notification_permission_screen.dart';
import 'target_language_setup_screen.dart';
import '../l10n/app_localizations.dart';
import '../models/curriculum_state.dart';
import '../services/daily_progress_sync.dart';

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
  bool _countryListExpanded = false;
  final TextEditingController _curriculumDayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurriculumDayDefault();
  }

  Future<void> _loadCurriculumDayDefault() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = snap.data() ?? <String, dynamic>{};
    final tl = (data['targetLanguage'] as String?)?.trim() ?? 'JPN';
    final day = CurriculumState.effectiveLearningDayForLanguage(data, tl);
    if (mounted) {
      _curriculumDayController.text = '$day';
    }
  }

  @override
  void dispose() {
    _curriculumDayController.dispose();
    super.dispose();
  }

  int? _parseCurriculumDayInput(AppLocalizations l10n) {
    final raw = _curriculumDayController.text.trim();
    final day = int.tryParse(raw);
    if (day == null || day < 1 || day > CurriculumState.totalDays) {
      setState(() => _error = l10n.admin_tools_curriculum_day_invalid);
      return null;
    }
    return day;
  }

  Future<Map<String, dynamic>> _ensureCurriculumDaySetForAdmin({
    required User user,
    required int day,
    required String targetLanguage,
    required String level,
  }) async {
    await user.getIdToken(true);
    final callable = callableEnsureCurriculumDaySet();
    final result = await callable.call<Map<String, dynamic>>({
      'learningDay': day,
      'targetLanguage': targetLanguage,
      'level': level,
    });
    return result.data;
  }

  Future<void> _run(
    Future<void> Function() fn, {
    String? successMessage,
    bool showSuccessSnackbar = true,
  }) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await fn();
      if (!mounted) return;
      if (showSuccessSnackbar) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage ?? l10n.admin_tools_done_snackbar),
          ),
        );
      }
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
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.admin_tools_confirm_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.admin_tools_confirm_run),
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
    final l10n = AppLocalizations.of(context)!;
    final user = FirebaseAuth.instance.currentUser;
    final isAdmin = user != null && user.uid == AdminToolsScreen.testAdminUid;

    if (!isAdmin) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.admin_tools_title)),
        body: Center(
          child: Text(
            l10n.admin_tools_no_permission,
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
      appBar: AppBar(title: Text(l10n.admin_tools_title)),
      body: AbsorbPointer(
        absorbing: _busy,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Text(
              l10n.admin_tools_test_only,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              l10n.admin_tools_uid_prefix(user.uid),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),

            _Section(
              title: l10n.admin_tools_section_language_flow,
              children: [
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LanguageSetupScreen()),
                  ),
                  child: Text(l10n.admin_tools_open_step1),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TargetLanguageSetupScreen()),
                  ),
                  child: Text(l10n.admin_tools_open_step2),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    final ok = await _confirm(
                      l10n.admin_tools_reset_language_flow_title,
                      l10n.admin_tools_reset_language_flow_message,
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
                  child: Text(l10n.admin_tools_reset_language_flow_button),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _Section(
              title: l10n.admin_tools_section_country_cache,
              children: [
                FilledButton.tonal(
                  onPressed: () => _run(() async {
                    await user.getIdToken(true);
                    final callable = callableSeedCountryCatalog();
                    await callable.call<Map<String, dynamic>>({});
                  }),
                  child: Text(l10n.admin_tools_seed_catalog),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () => _run(() async {
                    await user.getIdToken(true);
                    final callable = callableSyncCountryFlags();
                    await callable.call<Map<String, dynamic>>({'force': true});
                  }),
                  child: Text(l10n.admin_tools_sync_flags_force),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _countryStatusNonce++),
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.admin_tools_refresh_cache_status),
                ),
                const SizedBox(height: 12),
                FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: countryCol.get(),
                  builder: (context, snapshot) {
                    final innerL10n = AppLocalizations.of(context)!;
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const LinearProgressIndicator();
                    }
                    final docs = snapshot.data?.docs ?? const [];
                    if (docs.isEmpty) {
                      return Text(
                        innerL10n.admin_tools_cache_empty,
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
                        subtitle: Text(
                          '$alpha3  •  ${innerL10n.admin_tools_enabled_label(enabled ? "true" : "false")}',
                        ),
                        trailing: Icon(
                          hasFlag ? Icons.check_circle : Icons.error_outline,
                          color: hasFlag ? scheme.primary : scheme.error,
                        ),
                      );
                    }

                    return Theme(
                      data: Theme.of(context).copyWith(
                        dividerColor: Colors.transparent,
                      ),
                      child: ExpansionTile(
                        key: ValueKey<int>(_countryStatusNonce),
                        initiallyExpanded: _countryListExpanded,
                        onExpansionChanged: (expanded) {
                          setState(() => _countryListExpanded = expanded);
                        },
                        tilePadding: EdgeInsets.zero,
                        childrenPadding: EdgeInsets.zero,
                        title: Text(
                          innerL10n.admin_tools_country_list_title(
                            items.length,
                          ),
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        children: items.map(row).toList(growable: false),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 16),
            _Section(
              title: l10n.admin_tools_section_notification_permission,
              children: [
                FilledButton.tonal(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NotificationPermissionScreen(),
                    ),
                  ),
                  child: Text(l10n.admin_tools_open_notification_permission),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    final ok = await _confirm(
                      l10n.admin_tools_reset_notification_permission_title,
                      l10n.admin_tools_reset_notification_permission_message,
                    );
                    if (!ok) {
                      return;
                    }
                    await _run(NotificationPermissionScreen.resetAskedPref);
                  },
                  child: Text(
                    l10n.admin_tools_reset_notification_permission_button,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _Section(
              title: l10n.admin_tools_section_daily_progress,
              children: [
                FilledButton.tonal(
                  onPressed: () async {
                    final snap = await docRef.get();
                    final data = snap.data() ?? <String, dynamic>{};
                    final tl =
                        (data['targetLanguage'] as String?)?.trim() ?? 'JPN';
                    final ok = await _confirm(
                      l10n.admin_tools_fill_daily_progress_title,
                      l10n.admin_tools_fill_daily_progress_message,
                    );
                    if (!ok) {
                      return;
                    }
                    await _run(
                      () async {
                        await fillTodayDailyProgressForAdmin(
                          user,
                          targetLanguage: tl,
                        );
                      },
                      successMessage:
                          l10n.admin_tools_fill_daily_progress_snackbar,
                    );
                  },
                  child: Text(l10n.admin_tools_fill_daily_progress_button),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    final ok = await _confirm(
                      l10n.home_reset_dialog_title,
                      l10n.home_reset_dialog_content,
                    );
                    if (!ok) {
                      return;
                    }
                    await _run(() async {
                      await resetTodayDailyProgress(user);
                    });
                  },
                  icon: const Icon(Icons.restart_alt),
                  label: Text(l10n.home_reset_debug_button_label),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _Section(
              title: l10n.admin_tools_section_curriculum_day,
              children: [
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: docRef.snapshots(),
                  builder: (context, snap) {
                    final data = snap.data?.data() ?? <String, dynamic>{};
                    final tl =
                        (data['targetLanguage'] as String?)?.trim() ?? 'JPN';
                    final preview = CurriculumState.adminPreviewDayForLanguage(
                      data,
                      tl,
                    );
                    final actual = CurriculumState.learningDayForLanguage(
                      data,
                      tl,
                    );
                    if (preview == null) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        l10n.admin_tools_curriculum_preview_active(
                          preview,
                          actual,
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    );
                  },
                ),
                TextField(
                  controller: _curriculumDayController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.admin_tools_curriculum_day_hint,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () async {
                    final day = _parseCurriculumDayInput(l10n);
                    if (day == null) {
                      return;
                    }
                    final snap = await docRef.get();
                    final data = snap.data() ?? <String, dynamic>{};
                    final tl =
                        (data['targetLanguage'] as String?)?.trim() ?? 'JPN';
                    final level =
                        (data['level'] as String?)?.trim() ?? 'beginner';
                    final ok = await _confirm(
                      l10n.admin_tools_ensure_curriculum_day_set_title,
                      l10n.admin_tools_ensure_curriculum_day_set_message(day),
                    );
                    if (!ok) {
                      return;
                    }
                    await _run(
                      () async {
                        final result = await _ensureCurriculumDaySetForAdmin(
                          user: user,
                          day: day,
                          targetLanguage: tl,
                          level: level,
                        );
                        if (!mounted) return;
                        final innerL10n = AppLocalizations.of(context)!;
                        final status = result['status'] as String? ?? '';
                        final msg = status == 'skipped'
                            ? innerL10n
                                .admin_tools_ensure_curriculum_day_set_skipped(
                                day,
                              )
                            : innerL10n
                                .admin_tools_ensure_curriculum_day_set_created(
                                day,
                              );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(msg)),
                        );
                      },
                      showSuccessSnackbar: false,
                    );
                  },
                  child: Text(l10n.admin_tools_ensure_curriculum_day_set),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () async {
                    final day = _parseCurriculumDayInput(l10n);
                    if (day == null) {
                      return;
                    }
                    final snap = await docRef.get();
                    final data = snap.data() ?? <String, dynamic>{};
                    final tl =
                        (data['targetLanguage'] as String?)?.trim() ?? 'JPN';
                    final level =
                        (data['level'] as String?)?.trim() ?? 'beginner';
                    final ok = await _confirm(
                      l10n.admin_tools_apply_curriculum_preview_title,
                      l10n.admin_tools_apply_curriculum_preview_message(day),
                    );
                    if (!ok) {
                      return;
                    }
                    await _run(
                      () async {
                        await _ensureCurriculumDaySetForAdmin(
                          user: user,
                          day: day,
                          targetLanguage: tl,
                          level: level,
                        );
                        await user.getIdToken(true);
                        final callable = callableSetAdminCurriculumPreviewDay();
                        await callable.call<Map<String, dynamic>>({
                          'learningDay': day,
                          'targetLanguage': tl,
                        });
                      },
                      successMessage:
                          l10n.admin_tools_apply_curriculum_preview_snackbar(
                        day,
                      ),
                    );
                  },
                  child: Text(l10n.admin_tools_apply_curriculum_preview),
                ),
                const SizedBox(height: 8),
                OutlinedButton(
                  onPressed: () async {
                    final ok = await _confirm(
                      l10n.admin_tools_clear_curriculum_preview_title,
                      l10n.admin_tools_clear_curriculum_preview_message,
                    );
                    if (!ok) {
                      return;
                    }
                    await _run(
                      () async {
                        await user.getIdToken(true);
                        final callable = callableSetAdminCurriculumPreviewDay();
                        await callable.call<Map<String, dynamic>>({
                          'learningDay': null,
                        });
                      },
                      successMessage:
                          l10n.admin_tools_clear_curriculum_preview_snackbar,
                    );
                  },
                  child: Text(l10n.admin_tools_clear_curriculum_preview),
                ),
              ],
            ),

            const SizedBox(height: 16),
            _Section(
              title: l10n.admin_tools_section_learning_set,
              children: [
                OutlinedButton(
                  onPressed: () => _run(() async {
                    final snap = await docRef.get();
                    final data = snap.data() ?? <String, dynamic>{};
                    final tl = (data['targetLanguage'] as String?)?.trim() ?? 'JPN';
                    final level = (data['level'] as String?)?.trim() ?? 'beginner';
                    await user.getIdToken(true);
                    final callable = callableEnsureLearningSetForToday();
                    await callable.call<Map<String, dynamic>>({
                      'targetLanguage': tl,
                      'level': level,
                    });
                  }),
                  child: Text(l10n.admin_tools_ensure_learning_set),
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

