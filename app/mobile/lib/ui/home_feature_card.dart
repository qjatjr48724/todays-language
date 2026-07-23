import 'package:flutter/material.dart';

class HomeFeatureCard extends StatelessWidget {
  const HomeFeatureCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.progressText,
    this.enabled = true,
    /// true면 가로 한 줄(아이콘·제목·부제·chevron) — 홈 상단 전폭 버튼 등에 사용.
    this.compactRow = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String? progressText;
  final bool enabled;
  final bool compactRow;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;

    final muted = !enabled;
    final cardOpacity = muted ? 0.65 : 1.0;
    final iconBg = muted
        ? scheme.surfaceContainerHighest.withValues(alpha: 0.7)
        : scheme.primaryContainer;
    final iconFg = muted ? scheme.onSurfaceVariant : scheme.onPrimaryContainer;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: cardOpacity,
        child: Card(
          color: muted ? scheme.surfaceContainerLow : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: muted
                ? BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.6))
                : BorderSide.none,
          ),
          child: Padding(
            padding: compactRow
                ? const EdgeInsets.symmetric(horizontal: 14, vertical: 14)
                : const EdgeInsets.all(8),
            child: compactRow ? _buildCompactRow(context, scheme, t, iconBg, iconFg) : _buildGridTile(context, scheme, t, iconBg, iconFg),
          ),
        ),
      ),
    );
  }

  Widget _buildGridTile(
    BuildContext context,
    ColorScheme scheme,
    TextTheme t,
    Color iconBg,
    Color iconFg,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconFg,
              ),
            ),
            const Spacer(),
            Icon(
              enabled ? Icons.chevron_right : Icons.lock_outline,
              size: 20,
              color: scheme.onSurfaceVariant,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: t.titleSmall,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (progressText != null) ...[
          const SizedBox(height: 4),
          Text(
            progressText!,
            style: t.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildCompactRow(
    BuildContext context,
    ColorScheme scheme,
    TextTheme t,
    Color iconBg,
    Color iconFg,
  ) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 22,
            color: iconFg,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: t.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: t.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(
          enabled ? Icons.chevron_right : Icons.lock_outline,
          size: 22,
          color: scheme.onSurfaceVariant,
        ),
      ],
    );
  }
}

