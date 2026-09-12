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
///
/// 左右の要素は段ごとに横並びにし、上段（アイコン＋名称／金額）と
/// 下段（構成比バー／比率）がそれぞれ縦方向の中心で揃うようにする。
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

  /// 右列（金額・比率）の固定幅
  static const double _trailingWidth = 104;

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
                children: [
                  // 上段: アイコン＋名称と金額を縦中心で揃える
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 2.0),
                        child: icon,
                      ),
                      Expanded(
                        child: Text(
                          name,
                          style: context.textStyles.listTilePrimaryTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // 右列は固定幅にして、金額の桁数が違ってもバーの右端が行間で揃うようにする
                      SizedBox(
                        width: _trailingWidth,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            priceLabel,
                            style: context.textStyles.appCardSecondaryPriceLabel,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  // 下段: 構成比バーと比率を縦中心で揃える
                  Row(
                    children: [
                      Expanded(
                        child: CategoryRatioBar(
                          ratio: ratio,
                          colorCode: colorCode,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      SizedBox(
                        width: _trailingWidth,
                        child: Text(
                          percentLabel,
                          textAlign: TextAlign.right,
                          style: context.textStyles.listCardSecondaryNumeric,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            MyIcon.next(context),
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
    // 行側で比率テキストと縦中心を揃えるため、上下非対称の余白は付けない
    return SizedBox(
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
