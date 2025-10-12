import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/expense/expense_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/register_page/expense_tab/register_expense_page.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

class ExpenseHistoryDigestTile extends ConsumerWidget {
  const ExpenseHistoryDigestTile({
    super.key,
    required this.tileValue,
  });

  final ExpenseHistoryTileValue tileValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenseUsecase = ref.read(expenseUsecaseProvider);
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
                fixedCostId:tileValue.fixedCostId,
                isConfirmed: tileValue.isConfirmed, 
                );

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
            SizedBox(
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
                          width: 153 * context.screenHorizontalMagnification,
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
                              width: 90 + context.listSmallcategoryMemoOffset,
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
            const Divider(
              thickness: 0.25,
              height: 0.25,
              color: MyColors.separater,
            )
          ],
        ),

        //タイルを横にスライドした時の処理
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("登録履歴の削除"), // ダイアログのタイトル
                  content:
                      const Text("削除したデータは戻せません。\n本当に削除しますか？"), // ダイアログのメッセージ
                  actions: <Widget>[
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(false), // キャンセルボタンを押したときの処理
                      child: Text("戻る"),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(true), // 削除ボタンを押したときの処理
                      child: Text("OK"),
                    ),
                  ],
                );
              },
            );
          }
          return null;
        },

        //ダイアログでOKを押したら処理
        onDismissed: (direction) {
          expenseUsecase.delete(id: tileValue.id);
        },
      ),
    );
  }
}
