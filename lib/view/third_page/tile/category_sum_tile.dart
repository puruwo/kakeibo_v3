import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_entity.dart';
import 'package:kakeibo/model/assets_conecter/category_handler.dart';

import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/util/screen_size_func.dart';

import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/category_card_entity.dart';

class CategoryTile extends HookConsumerWidget {
  const CategoryTile({required this.categoryTile, super.key});
  final CategoryCardEntity categoryTile;

  CategoryAccountingEntity get monthlyExpenseByCategoryEntity => categoryTile.monthlyExpenseByCategoryEntity;
  List<SmallCategoryTileEntity> get smallCategoryEntity => categoryTile.smallCategoryList;

  final double barFrameWidth = 280.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  // 予算を超えているか
  bool isOverBudget = false;

  // 予算が設定されているか
  bool isSetBudget = true;

    //横棒グラフの初期値
  double barWidth = 0;
  final isBuilt = useState(false);

    // 画面の横幅を取得
    final screenWidthSize = MediaQuery.of(context).size.width;

    // 画面の倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(screenWidthSize);

    // 横棒グラフの幅を計算
    double degrees = (monthlyExpenseByCategoryEntity.totalExpenseByBigCategory / monthlyExpenseByCategoryEntity.budget);
    barWidth =
        degrees <= 1.0 ? barFrameWidth * degrees : barFrameWidth;

    if (monthlyExpenseByCategoryEntity.totalExpenseByBigCategory > monthlyExpenseByCategoryEntity.budget) {
      isOverBudget = true;
    }

    //ビルドが完了したら横棒グラフのサイズを変更しアニメーションが動く
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isBuilt.value = true;
    });

    // 支出合計のLabel
    final String paymentSumLabel = formattedPriceGetter(monthlyExpenseByCategoryEntity.totalExpenseByBigCategory);

    // 予算のLabel
    final String budgetLabel = formattedPriceGetter(monthlyExpenseByCategoryEntity.budget);

    isSetBudget = monthlyExpenseByCategoryEntity.budget == 0 ? false : true;

    return Container(
      width: 343 * screenHorizontalMagnification,
      decoration: BoxDecoration(
        color: MyColors.quarternarySystemfill,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Theme(
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
          tilePadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          // 開いた後の要素のpadding
          childrenPadding: const EdgeInsets.only(bottom: 10.0),

          title: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                // バーの上下の余白を調整
                padding: const EdgeInsets.only(top: 8, bottom: 3),
                child: isSetBudget == true
                    ? isOverBudget
                        // 予算を超えている場合
                        ? Stack(children: [
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
                            // バーの中身
                            AnimatedContainer(
                              height: 10,
                              width: isBuilt.value
                                  ? barWidth * screenHorizontalMagnification
                                  : 0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: MyColors()
                                    .getColorFromHex(monthlyExpenseByCategoryEntity.categoryColor),
                              ),
                              duration: const Duration(milliseconds: 500),
                            ),
                            // バーの超過分マスク
                            SizedBox(
                              width: barFrameWidth *
                                  screenHorizontalMagnification,
                              child: AnimatedOpacity(
                                opacity: isBuilt.value ? 1.0 : 0.0,
                                curve: Curves.easeInExpo,
                                duration: const Duration(milliseconds: 700),
                                child: Container(
                                  width: barFrameWidth,
                                  alignment: Alignment.centerRight,
                                  child: ClipRRect(
                                      borderRadius:
                                          const BorderRadius.horizontal(
                                              right: Radius.circular(10)),
                                      child: ClipRect(
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          widthFactor: (barFrameWidth *
                                                  (degrees - 1) /
                                                  degrees) /
                                              280, // widthFactor = target width / original width
                                          child: Image.asset(
                                            'assets/images/over_fill.png',
                                            width: 280,
                                            height: 10,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )),
                                ),
                              ),
                            )
                          ])

                        // 予算を超えていない場合
                        : Stack(
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
                              // バーの中身
                              AnimatedContainer(
                                height: 10,
                                width: isBuilt.value
                                    ? barWidth * screenHorizontalMagnification
                                    : 0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: MyColors()
                                      .getColorFromHex(monthlyExpenseByCategoryEntity.categoryColor),
                                ),
                                duration: const Duration(milliseconds: 500),
                              ),
                            ],
                          )
                    // 予算が0円の場合
                    : const Text(
                        '予算が設定されていません',
                        style: TextStyle(
                            color: MyColors.secondaryLabel, fontSize: 16),
                      ),
              ),
              // バー下ラベル
              Container(
                width: barFrameWidth * screenHorizontalMagnification,
                // 最小の制約を設定することで子widgetのRowが最大まで拡大する
                constraints: BoxConstraints(
                  minWidth:
                      barFrameWidth * screenHorizontalMagnification,
                  minHeight: 30,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 2.0),
                      child: CategoryHandler().sisytIconGetterFromBigCategoryKey(
                        monthlyExpenseByCategoryEntity.id,
                        height: 25,
                        width: 25),
                    ),
                    // カテゴリー名
                    Expanded(
                      child: Text(
                        monthlyExpenseByCategoryEntity.bigCategoryName,
                        style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: MyColors.white,
                          fontWeight: FontWeight.w300,
                        ),
                        overflow: TextOverflow.ellipsis,
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
                    )
                  ],
                ),
              ),
            ],
          ),

          // expansionArea
          children: [
            ...List.generate(smallCategoryEntity.length, (index) {
              // 支出合計のLabel
              final String totalExpenseBySmallCategory = formattedPriceGetter(
                  smallCategoryEntity[index].totalExpenseBySmallCategory);

              return Padding(
                // 子一列の両サイドのパディング
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 52.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // 小カテゴリー名
                    Padding(
                      // 子の中でのパディング
                      padding: const EdgeInsets.only(left: 26.0),
                      child: Text(
                        smallCategoryEntity[index].smallCategoryName,
                        style: GoogleFonts.notoSans(
                            fontSize: 16,
                            color: MyColors.label,
                            fontWeight: FontWeight.w400),
                        textAlign: TextAlign.start,
                      ),
                    ),

                    // 小カテゴリーの支払い合計
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          totalExpenseBySmallCategory,
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
      ),
    );
  }
}

class MyClipper extends CustomClipper<Rect> {
  final double frameWidth;
  final double degrees;

  MyClipper({required this.frameWidth, required this.degrees});

  @override
  Rect getClip(Size size) {
    double maskWidth = frameWidth * (degrees - 1);
    return Rect.fromLTWH(0, 0, maskWidth, 10);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}
