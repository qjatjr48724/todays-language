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
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String? progressText;
  final bool enabled;

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
          padding: const EdgeInsets.all(12),
          child: Column(
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
              const SizedBox(height: 8),
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (progressText != null) ...[
                const SizedBox(height: 6),
                Text(
                  progressText!,
                  style: t.labelSmall?.copyWith(color: scheme.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }
}

