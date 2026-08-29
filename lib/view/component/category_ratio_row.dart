import 'package:flutter/material.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';

/// カテゴリー別内訳の1行（収入一覧・支出一覧で共用）
///
/// 月間分析のカテゴリーカード（CategorySumTile）と同じ構成:
/// 左にアイコン＋名称と構成比バー、右に金額と比率、末尾にシェブロン。
/// タップでカテゴリー明細へ遷移する。
class CategoryRatioRow extends StatelessWidget {
  const CategoryRatioRow({
    super.key,
    required this.icon,
    required this.name,
    required this.priceLabel,
    required this.ratio,
    required this.colorCode,
    required this.onTap,
  });

  /// カテゴリーアイコン（25px）
  final Widget icon;
  final String name;

  /// フォーマット済みの金額
  final String priceLabel;

  /// 合計に対する構成比（0.0〜1.0）
  final double ratio;
  final String colorCode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final percentLabel = '${(ratio * 100).toStringAsFixed(1)}%';

    return AppInkWell(
      borderRadius: BorderRadius.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 2.0),
                        child: icon,
                      ),
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.listTilePrimaryTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  CategoryRatioBar(ratio: ratio, colorCode: colorCode),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // 右列は固定幅にして、金額の桁数が違ってもバーの右端が行間で揃うようにする
            SizedBox(
              width: 104,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      priceLabel,
                      style: AppTextStyles.appCardSecondaryPriceLabel,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    percentLabel,
                    style: AppTextStyles.listCardSecondaryTitle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            MyIcon.next,
          ],
        ),
      ),
    );
  }
}

/// 構成比バー（月間分析のカテゴリーカードと同じ高さ7・角丸10）
class CategoryRatioBar extends StatelessWidget {
  const CategoryRatioBar({
    super.key,
    required this.ratio,
    required this.colorCode,
  });

  final double ratio;
  final String colorCode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 1, bottom: 3),
      child: SizedBox(
        height: 7,
        width: double.infinity,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              Container(color: context.colors.fillSecondary),
              FractionallySizedBox(
                widthFactor: ratio.clamp(0.0, 1.0),
                // heightFactor未指定だと子の高さが0になり塗りが見えない
                heightFactor: 1,
                child: ColoredBox(color: ColorCode.toColor(colorCode)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// カテゴリー行の間に入れる区切り線（アイコン分だけ左をあける）
class CategoryRowDivider extends StatelessWidget {
  const CategoryRowDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.lg),
      child: Divider(
        height: 0.5,
        thickness: 0.5,
        color: context.colors.separator,
      ),
    );
  }
}
