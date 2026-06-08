import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../config/firebase_functions_config.dart';
import '../l10n/app_localizations.dart';
import '../services/daily_progress_sync.dart';
import '../services/user_profile_sync.dart';
import '../utils/app_restart.dart';
import '../widgets/flag_thumb.dart';


/// 내 정보·설정 등에서 학습 대상 언어를 변경합니다.
Future<void> openTargetLanguagePicker(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final l10n = AppLocalizations.of(context)!;

    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snap = await docRef.get();
    if (!context.mounted) return;
    final data = snap.data() ?? <String, dynamic>{};
    final currentRaw = (data['targetLanguage'] as String?) ?? 'JPN';
    final current = _normalizeTargetLanguageAlpha3(currentRaw);
    final currentLevelRaw = (data['level'] as String?) ?? 'beginner';
    final levelForCall = _normalizeLevel(currentLevelRaw);

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

    final enabledRaw = enabledCountries.docs
        .map((d) => d.data())
        .toList(growable: false);
    final allRaw = allCountries.docs
        .map((d) => d.data())
        .toList(growable: false);

    String alpha3Of(Map<String, dynamic> m) =>
        (m['alpha3'] as String?)?.trim().toUpperCase() ?? '';

    final enabled = enabledRaw
        .where((m) => isTargetLanguageSelectable(alpha3Of(m)))
        .toList(growable: false);
    final disabled = allRaw
        .where((m) {
            final alpha3 = alpha3Of(m);
            final firestoreEnabled = (m['enabled'] as bool?) == true;
            return !firestoreEnabled || !isTargetLanguageSelectable(alpha3);
        })
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
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 12),
                                Flexible(
                                    child: ListView(
                                        shrinkWrap: true,
                                        children: [
                                            ...enabled.map((m) {
                                                final alpha3 =
                                                    (m['alpha3'] as String?)
                                                            ?.trim()
                                                            .toUpperCase() ??
                                                        '';
                                                final endonym =
                                                    (m['endonym'] as String?)
                                                            ?.trim() ??
                                                        alpha3;
                                                final flagUrl =
                                                    (m['flagUrl'] as String?)
                                                        ?.trim();
                                                return ListTile(
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    leading:
                                                        FlagThumb(url: flagUrl),
                                                    title: Text(endonym),
                                                    subtitle: Text(alpha3),
                                                    trailing: selected == alpha3
                                                        ? const Icon(Icons.check)
                                                        : null,
                                                    onTap: () => setState(
                                                        () => selected = alpha3,
                                                    ),
                                                );
                                            }),
                                            const SizedBox(height: 8),
                                            Text(
                                                l10n
                                                    .my_info_language_picker_additional_disabled,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge,
                                            ),
                                            ...disabled.map((m) {
                                                final alpha3 =
                                                    (m['alpha3'] as String?)
                                                            ?.trim()
                                                            .toUpperCase() ??
                                                        '';
                                                final endonym =
                                                    (m['endonym'] as String?)
                                                            ?.trim() ??
                                                        alpha3;
                                                final flagUrl =
                                                    (m['flagUrl'] as String?)
                                                        ?.trim();
                                                return ListTile(
                                                    enabled: false,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                    leading:
                                                        FlagThumb(url: flagUrl),
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
                                                onPressed: () => Navigator.of(
                                                    context,
                                                ).pop(false),
                                                child: Text(l10n.common_cancel),
                                            ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                            child: FilledButton(
                                                onPressed: selected == current
                                                    ? null
                                                    : () => Navigator.of(
                                                        context,
                                                    ).pop(true),
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

    final languageChanged = selected != current;

    if (languageChanged) {
        final agreeRestart = await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) {
                return AlertDialog(
                    title: Text(l10n.my_info_language_restart_dialog_title),
                    content: Text(
                        l10n.my_info_language_restart_dialog_content,
                    ),
                    actions: [
                        TextButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(false),
                            child: Text(l10n.my_info_language_restart_dialog_no),
                        ),
                        FilledButton(
                            onPressed: () =>
                                Navigator.of(dialogContext).pop(true),
                            child:
                                Text(l10n.my_info_language_restart_dialog_yes),
                        ),
                    ],
                );
            },
        );
        if (!context.mounted) return;
        if (agreeRestart != true) return;
    }

    Future<void> persistLanguageChange() async {
        await docRef.set({'targetLanguage': selected}, SetOptions(merge: true));
        await user.getIdToken(true);
        final callable = callableEnsureLearningSetForToday();
        await callable.call<Map<String, dynamic>>({
            'targetLanguage': selected,
            'level': levelForCall,
        });
        await ensureTodayDailyProgress(user);
    }

    try {
        if (languageChanged) {
            if (!context.mounted) return;
            await _showRestartPreparingOverlay(
                context,
                l10n,
                persistLanguageChange,
            );
            if (!context.mounted) return;
            AppRestart.restart();
            return;
        }

        await persistLanguageChange();
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


Future<void> _showRestartPreparingOverlay(
    BuildContext context,
    AppLocalizations l10n,
    Future<void> Function() prepareTask,
) async {
    final error = await showGeneralDialog<Object?>(
        context: context,
        barrierDismissible: false,
        barrierLabel: 'restart_preparing',
        barrierColor: Colors.black38,
        transitionDuration: const Duration(milliseconds: 120),
        pageBuilder: (dialogContext, animation, secondaryAnimation) {
            return _RestartPreparingOverlay(
                l10n: l10n,
                prepareTask: prepareTask,
            );
        },
    );

    if (error != null) {
        throw error;
    }
}


class _RestartPreparingOverlay extends StatefulWidget {
    const _RestartPreparingOverlay({
        required this.l10n,
        required this.prepareTask,
    });

    final AppLocalizations l10n;
    final Future<void> Function() prepareTask;

    @override
    State<_RestartPreparingOverlay> createState() =>
        _RestartPreparingOverlayState();
}


class _RestartPreparingOverlayState extends State<_RestartPreparingOverlay> {
    @override
    void initState() {
        super.initState();
        WidgetsBinding.instance.addPostFrameCallback((_) => _runPrepareTask());
    }

    Future<void> _runPrepareTask() async {
        try {
            await widget.prepareTask();
            if (!mounted) return;
            Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
            if (!mounted) return;
            Navigator.of(context, rootNavigator: true).pop(e);
        }
    }

    @override
    Widget build(BuildContext context) {
        final messageStyle = Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
            );

        return PopScope(
            canPop: false,
            child: Material(
                type: MaterialType.transparency,
                child: Center(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            const CircularProgressIndicator(color: Colors.white),
                            const SizedBox(height: 16),
                            Text(
                                widget.l10n.my_info_language_restart_preparing,
                                textAlign: TextAlign.center,
                                style: messageStyle,
                            ),
                        ],
                    ),
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
