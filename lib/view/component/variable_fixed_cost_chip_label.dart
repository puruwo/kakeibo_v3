import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';

/// 変動型の固定費であることを示す「変動」チップ
///
/// 固定費一覧で使う。塗りのみ（primaryTint）・枠なし・アイコンなしの控えめな表現
/// （案件: 固定費バッジデザイン調整 決定A-1）。
/// 「この回の支払いが未確定」の意味では使わない（未確定は金額欄の「未入力」表示が担う）。
class VariableFixedCostChipLabel extends StatelessWidget {
  const VariableFixedCostChipLabel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(right: AppSpacing.xs),
      decoration: BoxDecoration(
        color: context.colors.primaryTint,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '変動',
        style: AppTextStyles.chipLabelAccent,
      ),
    );
  }
}
