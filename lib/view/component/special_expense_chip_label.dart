import 'package:flutter/material.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// 明細行が特別枠の支出であることを示す「特別枠」チップ
///
/// 支出カテゴリー明細の明細行で、生活収支の支出と区別するために使う。
/// 見た目は [FixedCostChipLabel] と同語彙（角丸4px・塗りのみ・グレー系）。
class SpecialExpenseChipLabel extends StatelessWidget {
  const SpecialExpenseChipLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(left: AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.colors.fillTertiary,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        AccountTypeConstants.specialLabel,
        style: AppTextStyles.chipLabel,
      ),
    );
  }
}
