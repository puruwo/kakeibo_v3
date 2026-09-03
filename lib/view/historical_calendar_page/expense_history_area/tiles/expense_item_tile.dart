import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/expense/expense_usecase.dart';
import 'package:kakeibo/application/fixed_cost_record/fixed_cost_record_usecase.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/fixed_cost_chip_label.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/register_page/expense_tab/open_fixed_cost_record_edit_sheet.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

class ExpenseItemTile extends ConsumerWidget {
  const ExpenseItemTile({
    super.key,
    required this.value,
    required this.leftsidePadding,
    required this.listSmallcategoryMemoOffset,
    required this.screenHorizontalMagnification,
  });

  final ExpenseHistoryTileValue value;
  final double leftsidePadding;
  final double listSmallcategoryMemoOffset;
  final double screenHorizontalMagnification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseUsecase = ref.read(expenseUsecaseProvider);
    final color = ColorCode.toColor(value.colorCode);

    // 固定費由来の行かどうか（仕様 §8.4）
    final isFixedCost = value.fixedCostId != null;
    // 未確定の固定費行は金額が未入力
    final isUnconfirmed = isFixedCost && value.isConfirmed == 0;

    // アイコン
    final icon = FittedBox(
      fit: BoxFit.scaleDown,
      child: SvgPicture.asset(
        value.iconPath,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        semanticsLabel: 'categoryIcon',
        width: 25,
        height: 25,
      ),
    );
    // 値段ラベル（未確定の固定費行は「未入力」）
    final priceLabel = isUnconfirmed
        ? '未入力'
        : yenmarkFormattedPriceGetter(value.price);

    return AppInkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        // 固定費行は編集範囲が違うため専用シートを開く（仕様 §6.6）
        if (isFixedCost) {
          await openFixedCostRecordEditSheet(context, ref,
              expenseId: value.id);
          return;
        }
        final expenseEntity = ExpenseEntity(
          id: value.id,
          date: DateFormat('yyyyMMdd').format(value.date),
          price: value.price,
          paymentCategoryId: value.paymentCategoryId,
          memo: value.memo,
          incomeSourceBigCategory: value.incomeSourceBigCategory,
        );
        showAppModalBottomSheet(
          context,
          child: RegisaterPageBase.editExpense(expenseEntity: expenseEntity),
        );
      },
      child: Dismissible(
        direction: DismissDirection.endToStart,
        key: Key(value.id.toString()),
        dragStartBehavior: DragStartBehavior.start,
        background: Container(color: context.colors.surface),
        secondaryBackground: Container(
          color: context.colors.expense,
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 18.0),
              child: Icon(Icons.delete, color: context.colors.icon),
            ),
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            return await showDeleteConfirmationDialog(context);
          }
          return null;
        },
        onDismissed: (direction) {
          // 固定費行の削除は推定額の再計算を伴うため専用ユースケースを使う（仕様 §6.5）
          if (isFixedCost) {
            ref.read(fixedCostRecordUsecaseProvider).delete(id: value.id);
          } else {
            expenseUsecase.delete(id: value.id);
          }
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: leftsidePadding,
                right: leftsidePadding,
              ),
              child: SizedBox(
                height: 49,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // アイコン
                    SizedBox(height: 49, width: 49, child: icon),

                    // 大カテゴリー、小カテゴリーのColumn
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 大カテゴリー（固定費行には「固定費」チップを添える）
                          SizedBox(
                            width: 153 * screenHorizontalMagnification,
                            child: Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    value.bigCategoryName,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles.listTilePrimaryTitle,
                                  ),
                                ),
                                if (isFixedCost) const FixedCostChipLabel(),
                              ],
                            ),
                          ),

                          // 小カテゴリーとメモ
                          Row(
                            children: [
                              // 小カテゴリー
                              SizedBox(
                                width: 56,
                                child: Text(
                                  ' ${value.smallCategoryName}',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.listTileTertiaryTitle,
                                ),
                              ),
                              // メモ
                              SizedBox(
                                width: 90 + listSmallcategoryMemoOffset,
                                child: Text(
                                  ' ${value.memo}',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyles.listTileTertiaryTitle,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 値段
                    Padding(
                      padding: const EdgeInsets.only(right: 2.0),
                      child: SizedBox(
                        width: 100,
                        child: Text(
                          priceLabel,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: isUnconfirmed
                              ? AppTextStyles.listTileUnconfirmedPriceLabel
                              : AppTextStyles.listTilePriceLabel,
                        ),
                      ),
                    ),

                    // nextArrowアイコン
                    Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(size: 18, Icons.remove, color: context.colors.expense),
                    ),
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 0.25,
              height: 0.25,
              indent: 50 + leftsidePadding,
              endIndent: leftsidePadding,
              color: context.colors.separator,
            ),
          ],
        ),
      ),
    );
  }
}
