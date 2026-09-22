import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/income/income_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/application/bulk_delete/bulk_delete_mode.dart';
import 'package:kakeibo/util/common_widget/app_dialog.dart';
import 'package:kakeibo/view/bulk_delete_page/open_bulk_delete_page.dart';

class IncomeItemTile extends ConsumerWidget {
  const IncomeItemTile({
    super.key,
    required this.value,
    required this.leftsidePadding,
    required this.screenHorizontalMagnification,
  });

  final IncomeHistoryTileValue value;
  final double leftsidePadding;
  final double screenHorizontalMagnification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // アイコン
    final icon = FittedBox(
      fit: BoxFit.scaleDown,
      child: SvgPicture.asset(
        value.iconPath,
        // KP-023: アセットは無着色（黒）になったため、カテゴリー色で着色する
        colorFilter: ColorFilter.mode(
          ColorCode.toColor(value.colorCode),
          BlendMode.srcIn,
        ),
        semanticsLabel: 'categoryIcon',
        width: 25,
        height: 25,
      ),
    );
    // 値段ラベル
    final priceLabel = yenmarkFormattedPriceGetter(value.price);

    return AppInkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => _showModalBottomSheet(context),
      // 長押しメニュー（編集／まとめて削除／削除）。KP-031 で新設。スワイプ削除は残す
      onLongPress: () => _showMenuDialog(context, ref),
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
              child: Icon(AppIcons.delete, color: context.colors.icon),
            ),
          ),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            return await showDeleteConfirmationDialog(context);
          }
          return null;
        },
        onDismissed: (direction) => _delete(ref),
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
                          // 大カテゴリー
                          SizedBox(
                            width: 153 * screenHorizontalMagnification,
                            child: Text(
                              value.bigCategoryName,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              style: context.textStyles.listTilePrimaryTitle,
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
                                  style: context.textStyles.listTileTertiaryTitle,
                                ),
                              ),
                              // メモ
                              SizedBox(
                                width: 90 * screenHorizontalMagnification,
                                child: Text(
                                  ' ${value.memo}',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textStyles.listTileTertiaryTitle,
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              priceLabel,
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: context.textStyles.listTilePriceLabel,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // addアイコン
                    Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        size: 18,
                        AppIcons.add,
                        color: context.colors.income,
                      ),
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

  /// 1件削除
  void _delete(WidgetRef ref) {
    ref.read(incomeUsecaseProvider).delete(id: value.id);
  }

  /// 長押しメニュー（編集／まとめて削除／削除。KP-031）
  Future<void> _showMenuDialog(BuildContext context, WidgetRef ref) async {
    await showMenuDialog(context, items: [
      MenuDialogItem(
        label: '編集',
        icon: AppIcons.edit,
        onPressed: () => _showModalBottomSheet(context),
      ),
      bulkDeleteMenuItem(
        context,
        mode: BulkDeleteMode.income,
        recordId: value.id,
      ),
      MenuDialogItem(
        label: '削除',
        icon: AppIcons.delete,
        isDestructive: true,
        onPressed: () {
          showDeleteConfirmationDialog(context, onConfirm: () => _delete(ref));
        },
      ),
    ]);
  }

  void _showModalBottomSheet(BuildContext context) {
    final incomeEntity = IncomeEntity(
      id: value.id,
      date: DateFormat('yyyyMMdd').format(value.date),
      price: value.price,
      categoryId: value.paymentCategoryId,
      memo: value.memo,
    );
    showAppModalBottomSheet(
      context,
      child: RegisaterPageBase.editIncome(incomeEntity: incomeEntity),
    );
  }
}
