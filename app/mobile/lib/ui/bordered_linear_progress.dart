import 'package:flutter/material.dart';

/// 오늘 진행률용 프로그레스바 — 테두리·배경으로 빈 구간이 구분되게 표시합니다.
class BorderedLinearProgress extends StatelessWidget {
  const BorderedLinearProgress({
    super.key,
    required this.percent,
    this.minHeight = 12,
  });

  final int percent;
  final double minHeight;

  static double value01(int percent) {
    if (percent <= 0) return 0.02;
    return (percent / 100).clamp(0.0, 1.0);
  }

  static Color barColor(int percent) {
    if (percent >= 80) return Colors.green;
    if (percent >= 40) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: scheme.outline.withValues(alpha: 0.5),
        ),
        color: scheme.surfaceContainerHigh,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          value: value01(percent),
          minHeight: minHeight,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation(barColor(percent)),
        ),
      ),
    );
  }
}
