import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/expense/expense_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';
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
    final color = MyColors().getColorFromHex(value.colorCode);

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
    // 値段ラベル
    final priceLabel =
        value.price == 0 ? '未確定' : yenmarkFormattedPriceGetter(value.price);

    return AppInkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () async {
        showModalBottomSheet(
          useRootNavigator: true,
          isScrollControlled: true,
          useSafeArea: true,
          constraints: const BoxConstraints(
            maxWidth: 2000,
          ),
          context: context,
          builder: (context) {
            ExpenseEntity expenseEntity = ExpenseEntity(
                id: value.id,
                date: DateFormat('yyyyMMdd').format(value.date),
                price: value.price,
                paymentCategoryId: value.paymentCategoryId,
                memo: value.memo,
                incomeSourceBigCategory: value.incomeSourceBigCategory);

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData.dark(),
              themeMode: ThemeMode.dark,
              darkTheme: ThemeData.dark(),
              home: MediaQuery.withClampedTextScaling(
                minScaleFactor: 0.7,
                maxScaleFactor: 0.95,
                child: RegisaterPageBase.editExpense(
                  expenseEntity: expenseEntity,
                ),
              ),
            );
          },
        );
      },
      child: Dismissible(
        direction: DismissDirection.endToStart,
        key: Key(value.id.toString()),
        dragStartBehavior: DragStartBehavior.start,
        background: Container(color: MyColors.black),
        secondaryBackground: Container(
          color: MyColors.red,
          child: const Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.only(right: 18.0),
                child: Icon(
                  Icons.delete,
                  color: MyColors.systemGray,
                ),
              )),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            return await showDeleteConfirmationDialog(context);
          }
          return null;
        },
        onDismissed: (direction) {
          expenseUsecase.delete(id: value.id);
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  left: leftsidePadding, right: leftsidePadding),
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
                              style: MyFonts.historyTileBigCategoryLabel,
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
                                  style: MyFonts.historyTileSubLabel,
                                ),
                              ),
                              // メモ
                              SizedBox(
                                width: 90 + listSmallcategoryMemoOffset,
                                child: Text(
                                  ' ${value.memo}',
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: MyColors.secondaryLabel),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    // 値段
                    Padding(
                      padding: const EdgeInsets.only(right: 22.0),
                      child: SizedBox(
                        width: 100,
                        child: Text(
                          priceLabel,
                          textAlign: TextAlign.end,
                          overflow: TextOverflow.ellipsis,
                          style: MyFonts.historyTilePriceLabel,
                        ),
                      ),
                    ),

                    // nextArrowアイコン
                    const Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: Icon(
                        size: 18,
                        Icons.arrow_forward_ios_rounded,
                        color: MyColors.white,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 0.25,
              height: 0.25,
              indent: 50 + leftsidePadding,
              endIndent: leftsidePadding,
              color: MyColors.separater,
            )
          ],
        ),
      ),
    );
  }
}
