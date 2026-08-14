import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/component/card_container.dart';

/// ADR-016 B: 「押すと別画面へ遷移する行」専用のコンポーネント。
///
/// ボタン（[MainButton] 等、ピル形状）とは意図的に形を分ける。
/// 角丸はカードと同じ[appCardRadius]（18px）を使い、ピルではなく
/// 「カード寄りの行」であることを示す。
class AppNavigationListTile extends StatelessWidget {
  const AppNavigationListTile({
    super.key,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.height = 46,
  });

  final String title;
  final VoidCallback onTap;

  /// 「9件」等、シェブロンの左に添える補足テキスト
  final String? trailingText;
  final double height;

  @override
  Widget build(BuildContext context) {
    // ADR-017実装メモ: MaterialベースのAppInkWellはborderを持てないため、
    // 外側にborderだけのContainerを重ねてCardContainer/AppPillContainerと
    // 同じ境界線を出す。
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.surfaceBorder, width: 1),
        borderRadius: appCardRadius,
      ),
      child: AppInkWell(
        color: context.colors.fillQuaternary,
        borderRadius: appCardRadius,
        onTap: onTap,
        child: Container(
          height: height,
          decoration: BoxDecoration(borderRadius: appCardRadius),
          child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: AppTextStyles.oneLineButtonText),
              Row(
                children: [
                  if (trailingText != null) ...[
                    Text(trailingText!, style: AppTextStyles.listTileLegendTitle),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Icon(
                    size: 16,
                    Icons.arrow_forward_ios_rounded,
                    color: context.colors.textSecondary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }
}
