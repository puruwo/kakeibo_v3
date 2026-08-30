import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';

/// 絞り込みチップの横並び（支出一覧の 全体/生活収支/特別枠）
///
/// 選択中は塗り（text色）に反転文字、非選択は枠線のみ。
class FilterChipRow<T> extends StatelessWidget {
  const FilterChipRow({
    super.key,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.onSelected,
  });

  final List<T> options;
  final T selected;
  final String Function(T option) labelOf;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final option in options) ...[
          _FilterChip(
            label: labelOf(option),
            isSelected: option == selected,
            onTap: () => onSelected(option),
          ),
          if (option != options.last) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppInkWell(
      borderRadius: BorderRadius.circular(14),
      color: isSelected ? colors.text : Colors.transparent,
      border: isSelected
          ? null
          : Border.all(color: colors.surfaceBorder, width: 1),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: isSelected
              ? AppTextStyles.filterChipSelectedLabel.copyWith(
                  color: colors.surface,
                )
              : AppTextStyles.listCardSecondaryTitle,
        ),
      ),
    );
  }
}
