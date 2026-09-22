import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_chip_label.dart';
import 'package:kakeibo/view/component/check_box.dart';

/// 一括削除ページの行（KP-031）
///
/// 履歴タブのタイル（ExpenseItemTile / IncomeItemTile）と同じ見た目の行の先頭に
/// 円チェック（[CheckBox]）を足したもの。タップで選択を切り替え、選択中は行の地を
/// `primaryTint` にする（カンバス B1）。編集・スワイプ削除はしない。
class BulkDeleteItemTile extends StatelessWidget {
  const BulkDeleteItemTile._({
    super.key,
    required this.iconPath,
    required this.colorCode,
    required this.primaryTitle,
    required this.secondaryTitle,
    required this.memo,
    required this.priceLabel,
    required this.isUnconfirmed,
    required this.isFixedCost,
    required this.isIncome,
    required this.isSelected,
    required this.onTap,
    required this.leftsidePadding,
  });

  /// 支出行（固定費行は「固定費」チップ・未確定は「未入力」）
  factory BulkDeleteItemTile.expense({
    Key? key,
    required ExpenseHistoryTileValue value,
    required bool isSelected,
    required VoidCallback onTap,
    required double leftsidePadding,
  }) {
    final isFixedCost = value.fixedCostId != null;
    final isUnconfirmed = isFixedCost && value.isConfirmed == 0;
    return BulkDeleteItemTile._(
      key: key,
      iconPath: value.iconPath,
      colorCode: value.colorCode,
      primaryTitle: value.bigCategoryName,
      secondaryTitle: value.smallCategoryName,
      memo: value.memo,
      priceLabel: isUnconfirmed
          ? '未入力'
          : yenmarkFormattedPriceGetter(value.price),
      isUnconfirmed: isUnconfirmed,
      isFixedCost: isFixedCost,
      isIncome: false,
      isSelected: isSelected,
      onTap: onTap,
      leftsidePadding: leftsidePadding,
    );
  }

  /// 収入行
  factory BulkDeleteItemTile.income({
    Key? key,
    required IncomeHistoryTileValue value,
    required bool isSelected,
    required VoidCallback onTap,
    required double leftsidePadding,
  }) {
    return BulkDeleteItemTile._(
      key: key,
      iconPath: value.iconPath,
      colorCode: value.colorCode,
      primaryTitle: value.bigCategoryName,
      secondaryTitle: value.smallCategoryName,
      memo: value.memo,
      priceLabel: yenmarkFormattedPriceGetter(value.price),
      isUnconfirmed: false,
      isFixedCost: false,
      isIncome: true,
      isSelected: isSelected,
      onTap: onTap,
      leftsidePadding: leftsidePadding,
    );
  }

  final String iconPath;
  final String colorCode;
  final String primaryTitle;
  final String secondaryTitle;
  final String memo;
  final String priceLabel;
  final bool isUnconfirmed;
  final bool isFixedCost;
  final bool isIncome;
  final bool isSelected;
  final VoidCallback onTap;
  final double leftsidePadding;

  /// 行の高さ（履歴タブのタイルと同じ）
  static const double rowHeight = 49;

  /// 円チェックの直径（共通部品 CheckBox の寸法）
  static const double checkBoxSize = 23;

  @override
  Widget build(BuildContext context) {
    // 参照先のカテゴリーが無い行はアイコンを出さない（仕様 §5）
    final icon = iconPath.isEmpty
        ? const SizedBox.shrink()
        : FittedBox(
            fit: BoxFit.scaleDown,
            child: SvgPicture.asset(
              iconPath,
              colorFilter: ColorFilter.mode(
                ColorCode.toColor(colorCode),
                BlendMode.srcIn,
              ),
              semanticsLabel: 'categoryIcon',
              width: 25,
              height: 25,
            ),
          );

    return Semantics(
      button: true,
      selected: isSelected,
      child: AppInkWell(
        borderRadius: BorderRadius.zero,
        color: isSelected ? context.colors.primaryTint : null,
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
              child: SizedBox(
                height: rowHeight,
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 選択チェック
                    CheckBox(isChecked: isSelected),
                    const SizedBox(width: AppSpacing.sm),

                    // カテゴリーアイコン
                    SizedBox(height: rowHeight, width: rowHeight, child: icon),

                    // 大カテゴリー／小カテゴリーとメモ
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  primaryTitle,
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      context.textStyles.listTilePrimaryTitle,
                                ),
                              ),
                              if (isFixedCost) ...[
                                const SizedBox(width: AppSpacing.xs),
                                const AppChipLabel(label: '固定費'),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  ' $secondaryTitle',
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      context.textStyles.listTileTertiaryTitle,
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  ' $memo',
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      context.textStyles.listTileTertiaryTitle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 金額（最小幅100・桁が多い金額は省略せず名前側を縮める。
                    // 履歴タブの固定幅100では ¥3,000,000 が収まらないため）
                    Padding(
                      padding: const EdgeInsets.only(right: 2.0),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 100),
                        child: Text(
                          priceLabel,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: isUnconfirmed
                              ? context.textStyles.listTileUnconfirmedPriceLabel
                              : context.textStyles.listTilePriceLabel,
                        ),
                      ),
                    ),

                    // 行末の種別サイン（支出「−」・収入「+」。履歴タブと同じ）
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Icon(
                        size: 18,
                        isIncome ? AppIcons.add : AppIcons.remove,
                        color: isIncome
                            ? context.colors.income
                            : context.colors.expense,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 0.25,
              height: 0.25,
              // チェック＋間隔＋アイコン枠のぶんだけ区切り線を右へ寄せる
              indent: leftsidePadding + checkBoxSize + AppSpacing.sm + 50,
              endIndent: leftsidePadding,
              color: context.colors.separator,
            ),
          ],
        ),
      ),
    );
  }
}
