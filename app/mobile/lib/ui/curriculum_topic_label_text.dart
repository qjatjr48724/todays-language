import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// 커리큘럼 일차 주제명 — 「주제: …」 형식 + 얇은 테두리.
class CurriculumTopicLabelText extends StatelessWidget {
  const CurriculumTopicLabelText({
    super.key,
    required this.label,
    this.compact = false,
  });

  final String? label;

  /// 홈 진도 영역 등 작은 텍스트 스타일.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final topic = label?.trim();
    if (topic == null || topic.isEmpty) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final style = compact
        ? Theme.of(context).textTheme.bodySmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            )
        : Theme.of(context).textTheme.titleSmall?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            );

    final box = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 12,
        vertical: compact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        l10n.curriculum_topic_label(topic),
        style: style,
        textAlign: compact ? TextAlign.end : TextAlign.start,
        // 홈 compact: 한 줄 + 말줄임. 그 외는 여러 줄 줄바꿈 허용.
        maxLines: compact ? 1 : null,
        overflow: compact ? TextOverflow.ellipsis : TextOverflow.clip,
      ),
    );

    return Padding(
      padding: EdgeInsets.only(top: compact ? 4 : 0, bottom: compact ? 0 : 16),
      child: compact
          ? Align(alignment: Alignment.centerRight, child: box)
          : box,
    );
  }
}
