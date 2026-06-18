import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/curriculum_review_service.dart';
import '../utils/target_language_label.dart';
import 'curriculum_review_study_screen.dart';

/// 현재 학습 일차보다 이전 일차(1..N-1) 복습 선택.
class CurriculumReviewScreen extends StatefulWidget {
  const CurriculumReviewScreen({
    super.key,
    required this.targetLanguage,
    required this.level,
    required this.currentLearningDay,
    required this.curriculumPhase,
  });

  final String targetLanguage;
  final String level;
  final int currentLearningDay;
  final int curriculumPhase;

  @override
  State<CurriculumReviewScreen> createState() => _CurriculumReviewScreenState();
}

class _CurriculumReviewScreenState extends State<CurriculumReviewScreen> {
  bool _loading = true;
  String? _error;
  List<CurriculumReviewDayItem> _items = const [];
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await loadPriorCurriculumReviewDays(
        currentLearningDay: widget.currentLearningDay,
        targetLanguage: widget.targetLanguage,
        level: widget.level,
        curriculumPhase: widget.curriculumPhase,
      );
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _selectDay(int day) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _busy) return;
    setState(() => _busy = true);
    try {
      await saveCurriculumReviewDay(
        uid: user.uid,
        targetLanguage: widget.targetLanguage,
        learningDay: day,
      );
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CurriculumReviewStudyScreen(
            reviewLearningDay: day,
            targetLanguage: widget.targetLanguage,
            level: widget.level,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final languageLabel = targetLanguageLabel(widget.targetLanguage, l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.curriculum_review_title),
      ),
      body: AbsorbPointer(
        absorbing: _busy,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      l10n.curriculum_review_target_language(languageLabel),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: scheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.curriculum_review_subtitle(widget.currentLearningDay),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 12),
                  if (_error != null) ...[
                    Text(_error!, style: TextStyle(color: scheme.error)),
                    const SizedBox(height: 12),
                  ],
                  if (_items.isEmpty)
                    Text(
                      l10n.curriculum_review_empty,
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    )
                  else
                    ..._items.map((item) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.curriculum_review_day_label(item.learningDay)),
                        subtitle: item.ready
                            ? Text(l10n.curriculum_review_day_ready)
                            : Text(
                                l10n.curriculum_review_day_not_ready,
                                style: TextStyle(color: scheme.onSurfaceVariant),
                              ),
                        trailing: item.ready
                            ? const Icon(Icons.chevron_right)
                            : Icon(Icons.hourglass_empty, color: scheme.outline),
                        enabled: item.ready && !_busy,
                        onTap: item.ready ? () => _selectDay(item.learningDay) : null,
                      );
                    }),
                  if (_busy) ...[
                    const SizedBox(height: 16),
                    const LinearProgressIndicator(),
                  ],
                ],
              ),
      ),
    );
  }
}
