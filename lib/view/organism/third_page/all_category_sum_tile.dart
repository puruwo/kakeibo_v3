import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/all_category_tile_entity/all_category_tile_entity.dart';

import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/util/screen_size_func.dart';

import 'package:kakeibo/model/assets_conecter/category_handler.dart';

class AllCategorySumTile extends HookConsumerWidget {
  const AllCategorySumTile(
      {required this.allCategoryTileEntity,super.key});

  final AllCategoryTileEntity allCategoryTileEntity;

  // 横棒グラフのフレームサイズ
  final double barFrameWidth = 280.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<double> barWidthList =
        List.generate(allCategoryTileEntity.categoryCount, (index) => 0.0);

    // 予算が設定されているか
    bool isSetBudget = true;

    // ビルドが完了したかどうか
    final isBuilt = useState(false);

    // 画面の横幅を取得
    final screenWidthSize = MediaQuery.of(context).size.width;

    // 画面の倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(screenWidthSize);

    isSetBudget = allCategoryTileEntity.allCategoryTotalBudget == 0 ? false : true;

    // 各カテゴリーのグラフ幅を計算
    for (int i = 0; i < barWidthList.length; i++) {
      if (allCategoryTileEntity.allCategoryTotalExpense < allCategoryTileEntity.allCategoryTotalBudget) {
        double degrees = (allCategoryTileEntity.categoryExpenseList[i] / allCategoryTileEntity.allCategoryTotalBudget);
        barWidthList[i] = degrees = barFrameWidth * degrees;
      } else {
        double degrees = (allCategoryTileEntity.categoryExpenseList[i] / allCategoryTileEntity.allCategoryTotalExpense);
        barWidthList[i] = degrees = barFrameWidth * degrees;
      }
    }

    //ビルドが完了したら横棒グラフのサイズを変更しアニメーションが動く
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isBuilt.value = true;
    });

    // 支出合計のLabel
    final String paymentSumLabel = formattedPriceGetter(allCategoryTileEntity.allCategoryTotalExpense);

    // 予算のLabel
    final String budgetLabel = formattedPriceGetter(allCategoryTileEntity.allCategoryTotalBudget);

    return Container(
      width: 343 * screenHorizontalMagnification,
      decoration: BoxDecoration(
        color: MyColors.quarternarySystemfill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          //themeでwrapするExpansionTileの線が消える
          Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              splashColor: Colors.transparent,
              listTileTheme: ListTileTheme.of(context).copyWith(
                titleAlignment: ListTileTitleAlignment.center,
                horizontalTitleGap: 0,
                minVerticalPadding: 0,
                dense: true,
              ),
            ),
            child: ExpansionTile(
              // アイコンのカラー
              iconColor: MyColors.white,
              collapsedIconColor: MyColors.white,
              // 右のアイコンのpaddingの設定はここ
              tilePadding:
                  const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
              // 開いた後の要素のpadding
              childrenPadding: const EdgeInsets.only(bottom: 10.0),
              title: Column(
                children: [
                  // バーグラフ
                  Padding(
                    // バーの上下の余白を調整
                    padding: const EdgeInsets.only(top: 8, bottom: 3),
                    child: isSetBudget
                        ? Stack(
                            children: [
                              // バーの背景枠
                              Container(
                                height: 10,
                                width: barFrameWidth *
                                    screenHorizontalMagnification,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: MyColors.secondarySystemfill,
                                ),
                              ),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 0,
                                  ),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ...List.generate(
                                            allCategoryTileEntity.categoryCount,
                                            (index) {
                                          return AnimatedContainer(
                                            height: 10,
                                            width: isBuilt.value
                                                ? barWidthList[index] *
                                                    screenHorizontalMagnification
                                                : 0,
                                            color: MyColors().getColorFromHex(allCategoryTileEntity.categoryColorList[index]),
                                            duration: const Duration(
                                                milliseconds: 500),
                                          );
                                        }),
                                      ]),
                                ),
                              )
                            ],
                          )
                        : const Text(
                            '予算が設定されていません',
                            style: TextStyle(
                                color: MyColors.secondaryLabel, fontSize: 16),
                          ),
                  ),

                  // バー下ラベル
                  Container(
                    width: barFrameWidth * screenHorizontalMagnification,
                    constraints:
                        BoxConstraints(minWidth: barFrameWidth, minHeight: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 2),
                            child: Text(
                              '全体支出',
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.notoSans(
                                  fontSize: 16,
                                  color: MyColors.white,
                                  fontWeight: FontWeight.w300),
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // カテゴリー総支出
                            Text(
                              paymentSumLabel,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.notoSans(
                                  fontSize: 18,
                                  color: MyColors.white,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              ' 円',
                              style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  color: MyColors.white,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              ' /',
                              style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  color: MyColors.secondaryLabel,
                                  fontWeight: FontWeight.w400),
                            ),
                            Text(
                              '予算 ',
                              style: GoogleFonts.notoSans(
                                  fontSize: 13,
                                  color: MyColors.secondaryLabel,
                                  fontWeight: FontWeight.w400),
                            ),
                            // カテゴリー予算
                            Text(
                              budgetLabel,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.notoSans(
                                  fontSize: 14,
                                  color: MyColors.secondaryLabel,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.end,
                            ),
                            Padding(
                              // 円の右のスペース
                              padding: const EdgeInsets.only(right: 2.0),
                              child: Text(
                                ' 円',
                                style: GoogleFonts.notoSans(
                                  fontSize: 11,
                                  color: MyColors.secondaryLabel,
                                  fontWeight: FontWeight.w400,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // expansionArea
              children: [
                ...List.generate(allCategoryTileEntity.categoryCount, (index) {
                  // 支出合計のLabel
                  final String categoryPaymentSumLabel =
                      formattedPriceGetter(allCategoryTileEntity.categoryExpenseList[index]);
                  return Padding(
                    // 子一列の両サイドのパディング
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 52.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // アイコン
                            CategoryHandler().sisytIconGetterFromBigCategoryKey(
                                allCategoryTileEntity.categoryIdList[index],
                                height: 25,
                                width: 25),
                            // カテゴリー名
                            SizedBox(
                              width: 150,
                              child: Text(
                                ' ${allCategoryTileEntity.categoryNameList[index]}',
                                style: GoogleFonts.notoSans(
                                    fontSize: 16,
                                    color: MyColors.label,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        // 小カテゴリーの支払い合計
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              categoryPaymentSumLabel,
                              style: GoogleFonts.notoSans(
                                  fontSize: 18,
                                  color: MyColors.label,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.end,
                            ),
                            Text(
                              ' 円',
                              style: GoogleFonts.notoSans(
                                fontSize: 11,
                                color: MyColors.secondaryLabel,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          )
        ],
      ),
    );
  }
}
