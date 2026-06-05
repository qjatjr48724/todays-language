import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// 학습 난이도(초/중/고) 선택 — 온보딩·내 정보 등에서 공통 사용.
class LearningLevelSelector extends StatelessWidget {
  const LearningLevelSelector({
    super.key,
    required this.selectedLevel,
    required this.onSelect,
  });

  final String selectedLevel;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    final options = <_LevelOption>[
      _LevelOption(
        value: 'beginner',
        label: l10n.my_info_difficulty_tile_beginner_label,
        description: l10n.onboarding_level_beginner_desc,
      ),
      _LevelOption(
        value: 'intermediate',
        label: l10n.my_info_difficulty_tile_intermediate_label,
        description: l10n.onboarding_level_intermediate_desc,
      ),
      _LevelOption(
        value: 'advanced',
        label: l10n.my_info_difficulty_tile_advanced_label,
        description: l10n.onboarding_level_advanced_desc,
      ),
    ];

    return Column(
      children: options.map((opt) {
        final isSelected = selectedLevel == opt.value;
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? scheme.surfaceContainerHighest : null,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? scheme.primary : scheme.outlineVariant,
            ),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            title: Text(opt.label),
            subtitle: Text(
              opt.description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
            trailing: isSelected ? Icon(Icons.check, color: scheme.primary) : null,
            onTap: () => onSelect(opt.value),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _LevelOption {
  const _LevelOption({
    required this.value,
    required this.label,
    required this.description,
  });

  final String value;
  final String label;
  final String description;
}
