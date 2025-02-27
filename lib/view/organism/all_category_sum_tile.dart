import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:kakeibo/constant/colors.dart';

import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/util/screen_size_func.dart';

import 'package:kakeibo/model/assets_conecter/category_handler.dart';
import 'package:kakeibo/model/tableNameKey.dart';

class AllCategorySumTile extends StatefulWidget {
  const AllCategorySumTile(
      {required this.bigCategoryInformationMaps,
      required this.allCategorySum,
      required this.allCategoryBudgetSum,
      super.key});

  // ['big_category_key']['big_category_name'] ['payment_price_sum'] ['icon'] ['color']
  final List<Map<String, dynamic>> bigCategoryInformationMaps;
  // 全カテゴリーの合計支出
  final int allCategorySum;
  // 全カテゴリーの合計予算
  final int allCategoryBudgetSum;

  @override
  State<AllCategorySumTile> createState() => _CategorySumTileState();
}

class _CategorySumTileState extends State<AllCategorySumTile>
    with SingleTickerProviderStateMixin {
  // ビルドが完了したかどうか
  bool _isBuilt = false;

  // 横棒グラフのフレームサイズ
  final double barFrameWidth = 280.0;

  late List<double> barWidthList;

  // 予算が設定されているか
  bool isSetBudget = true;

  @override
  void initState() {
    // アニメーションのため各カテゴリーの棒グラフの幅リストを初期化
    barWidthList =
        List.generate(widget.bigCategoryInformationMaps.length, (index) => 0);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // 画面の横幅を取得
    final screenWidthSize = MediaQuery.of(context).size.width;

    // 画面の倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(screenWidthSize);

    isSetBudget = widget.allCategoryBudgetSum == 0 ? false : true;

    // 各大カテゴリーの名前
    List<String> bigCategoryNameList = [];
    // 各大カテゴリー支出合計のリスト
    List<int> paymentPriceSumList = [];
    // 各大カテゴリーのアイコン
    List<Widget> iconList = [];
    // 各大カテゴリーのカラー
    List<Color> colorList = [];
    // 情報を展開
    for (var value in widget.bigCategoryInformationMaps) {
      bigCategoryNameList.add(value[TBL202RecordKey().bigCategoryName]);
      paymentPriceSumList.add(value['payment_price_sum']);
      iconList.add(CategoryHandler().sisytIconGetterFromBigCategoryKey(
          value[TBL201RecordKey().bigCategoryKey],
          height: 25,
          width: 25));
      colorList
          .add(MyColors().getColorFromHex(value[TBL202RecordKey().colorCode]));
    }

    // 各カテゴリーのグラフ幅を計算
    for (int i = 0; i < barWidthList.length; i++) {
      if (widget.allCategorySum < widget.allCategoryBudgetSum) {
        double degrees = (paymentPriceSumList[i] / widget.allCategoryBudgetSum);
        barWidthList[i] = degrees = barFrameWidth * degrees;
      } else {
        double degrees = (paymentPriceSumList[i] / widget.allCategorySum);
        barWidthList[i] = degrees = barFrameWidth * degrees;
      }
    }

    //ビルドが完了したら横棒グラフのサイズを変更しアニメーションが動く
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isBuilt = true;
      });
    });

    // 支出合計のLabel
    final String paymentSumLabel = formattedPriceGetter(widget.allCategorySum);

    // 予算のLabel
    final String budgetLabel =
        formattedPriceGetter(widget.allCategoryBudgetSum);

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
                    child:isSetBudget ? Stack(
                      children: [
                        // バーの背景枠
                        Container(
                          height: 10,
                          width: barFrameWidth * screenHorizontalMagnification,
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
                            child:
                                Row(mainAxisSize: MainAxisSize.min, children: [
                              ...List.generate(
                                  widget.bigCategoryInformationMaps.length,
                                  (index) {
                                return AnimatedContainer(
                                  height: 10,
                                  width: _isBuilt ? barWidthList[index]*screenHorizontalMagnification : 0,
                                  color: colorList[index],
                                  duration: const Duration(milliseconds: 500),
                                );
                              }),
                            ]),
                          ),
                        )
                      ],
                    ):const Text(
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
                ...List.generate(widget.bigCategoryInformationMaps.length,
                    (index) {
                  // 支出合計のLabel
                  final String categoryPaymentSumLabel =
                      formattedPriceGetter(paymentPriceSumList[index]);
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
                            iconList[index],
                            // カテゴリー名
                            SizedBox(
                              width: 150,
                              child: Text(
                                ' ${bigCategoryNameList[index]}',
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
