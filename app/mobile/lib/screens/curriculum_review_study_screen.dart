import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/curriculum_review_service.dart';
import 'today_sentences_screen.dart';
import 'today_words_screen.dart';

/// 선택한 일차의 단어·문장 복습(탭 UI, 기본 단어 탭).
class CurriculumReviewStudyScreen extends StatefulWidget {
  const CurriculumReviewStudyScreen({
    super.key,
    required this.reviewLearningDay,
    required this.targetLanguage,
    required this.level,
  });

  final int reviewLearningDay;
  final String targetLanguage;
  final String level;

  @override
  State<CurriculumReviewStudyScreen> createState() =>
      _CurriculumReviewStudyScreenState();
}

class _CurriculumReviewStudyScreenState extends State<CurriculumReviewStudyScreen> {
  @override
  void dispose() {
    _clearReviewDay();
    super.dispose();
  }

  Future<void> _clearReviewDay() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await saveCurriculumReviewDay(
        uid: user.uid,
        targetLanguage: widget.targetLanguage,
        learningDay: null,
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.curriculum_review_study_appbar_title(
            widget.reviewLearningDay,
          )),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.home_today_words_title),
              Tab(text: l10n.home_today_sentences_title),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
              child: Text(
                l10n.curriculum_review_study_notice,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  TodayWordsScreen(
                    targetLanguage: widget.targetLanguage,
                    level: widget.level,
                    curriculumReviewMode: true,
                    reviewLearningDay: widget.reviewLearningDay,
                    embedded: true,
                  ),
                  TodaySentencesScreen(
                    targetLanguage: widget.targetLanguage,
                    level: widget.level,
                    curriculumReviewMode: true,
                    reviewLearningDay: widget.reviewLearningDay,
                    embedded: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
