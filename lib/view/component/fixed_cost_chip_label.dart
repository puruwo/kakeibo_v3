import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// 明細行が固定費由来であることを示す「固定費」チップ
///
/// 履歴・日次サマリ・カテゴリー詳細の明細行で、通常支出と区別するために使う（仕様 §7.2 / §8.4）。
/// 角丸4px・塗りのみ（枠なし）。配色はグレー系（背景: fillTertiary / 文字: textSecondary）。
class FixedCostChipLabel extends StatelessWidget {
  const FixedCostChipLabel({super.key});

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
        '固定費',
        style: AppTextStyles.chipLabel,
      ),
    );
  }
}
