import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/expense/expense_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/util/common_widget/app_delete_dialog.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/register_page/expense_tab/register_expense_page.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

class ExpenseHistoryTile extends ConsumerWidget {
  const ExpenseHistoryTile({
    super.key,
    required this.tileValueList,
    required this.leftsidePadding,
    required this.listSmallcategoryMemoOffset,
    required this.screenHorizontalMagnification,
  });

  final List<ExpenseHistoryTileValue> tileValueList;
  final double leftsidePadding;
  final double listSmallcategoryMemoOffset;
  final double screenHorizontalMagnification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseUsecase = ref.read(expenseUsecaseProvider);

    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: tileValueList.length,
      itemBuilder: (BuildContext context, int index) {
        final tileValue = tileValueList[index];

        final color = MyColors().getColorFromHex(tileValue.colorCode);

        // アイコン
        final icon = FittedBox(
          fit: BoxFit.scaleDown,
          child: SvgPicture.asset(
            tileValue.iconPath,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            semanticsLabel: 'categoryIcon',
            width: 25,
            height: 25,
          ),
        );
        // 値段ラベル
        final priceLabel = tileValue.price == 0
            ? '未確定'
            : yenmarkFormattedPriceGetter(tileValue.price);

        return GestureDetector(
          onTap: () async {
            showModalBottomSheet(
              //sccafoldの上に出すか
              useRootNavigator: true,
              isScrollControlled: true,
              useSafeArea: true,
              constraints: const BoxConstraints(
                maxWidth: 2000,
              ),
              context: context,
              // constで呼び出さないとリビルドがかかってtextfieldのも何度も作り直してしまう
              builder: (context) {
                ExpenseEntity expenseEntity = ExpenseEntity(
                    id: tileValue.id,
                    date: DateFormat('yyyyMMdd').format(tileValue.date),
                    price: tileValue.price,
                    paymentCategoryId: tileValue.paymentCategoryId,
                    memo: tileValue.memo,
                    incomeSourceBigCategory: tileValue.incomeSourceBigCategory,
                    fixedCostId: tileValue.fixedCostId ?? -1);

                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  theme: ThemeData.dark(),
                  themeMode: ThemeMode.dark,
                  darkTheme: ThemeData.dark(),
                  home: MediaQuery.withClampedTextScaling(
                    // テキストサイズの制御
                    minScaleFactor: 0.7,
                    maxScaleFactor: 0.95,
                    child: RegisterExpensePage(
                      expenseEntity: expenseEntity,
                      mode: RegisterScreenMode.edit,
                      isTabVisible: true,
                    ),
                  ),
                );
              },
            );
          },
          child: Dismissible(
            // 右から左
            direction: DismissDirection.endToStart,
            key: Key(tileValue.id.toString()),
            dragStartBehavior: DragStartBehavior.start,

            // 右スワイプ時の背景
            background: Container(color: MyColors.black),

            // 左スワイプ時の背景
            secondaryBackground: Container(
              color: MyColors.red,
              child: const Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    // 削除時背景のアイコンのpadding
                    padding: EdgeInsets.only(right: 18.0),
                    child: Icon(
                      Icons.delete,
                      color: MyColors.systemGray,
                    ),
                  )),
            ),
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
                                  tileValue.bigCategoryName,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: MyColors.label,
                                  ),
                                ),
                              ),

                              // 小カテゴリーとメモ
                              Row(
                                children: [
                                  // 小カテゴリー
                                  SizedBox(
                                    width: 56,
                                    child: Text(
                                      ' ${tileValue.smallCategoryName}',
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: MyColors.secondaryLabel),
                                    ),
                                  ),
                                  // メモ
                                  SizedBox(
                                    width: 90 + listSmallcategoryMemoOffset,
                                    child: Text(
                                      ' ${tileValue.memo}',
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
                              style: const TextStyle(
                                  fontSize: 19, color: MyColors.label),
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

            //タイルを横にスライドした時の処理
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                return await 
                showDeleteConfirmationDialog(context);
              }
              return null;
            },

            //ダイアログでOKを押したら処理
            onDismissed: (direction) {
              expenseUsecase.delete(id: tileValue.id);
            },
          ),
        );
      },
    );
  }
}
