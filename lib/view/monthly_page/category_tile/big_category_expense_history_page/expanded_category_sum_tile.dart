import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_entity.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/view/monthly_page/category_tile/big_category_expense_history_page/small_category_expanded_history_page/small_category_expanded_history_page.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_category_tile_entity_provider.dart';

class ExpandedCategoryTile extends HookConsumerWidget {
  const ExpandedCategoryTile({required this.bigId, super.key});
  final int bigId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // バーの幅を計算
    final double barFrameWidth = context.screenWidth - 64;

    // ビルドが完了したか
    // このフラグがtrueになったらアニメーションが動く
    final isBuilt = useState(false);

    //ビルドが完了したら横棒グラフのサイズを変更しアニメーションが動く
    WidgetsBinding.instance.addPostFrameCallback((_) {
      isBuilt.value = true;
    });

    return ref.watch(resolvedCategoryTileEntityProvider(bigId)).when(
        data: (categoryTileEntity) {
      //　総支出
      final totalExpense = categoryTileEntity
          .monthlyExpenseByCategoryEntity.totalExpenseByBigCategory;

      // 月の予算
      final budget = categoryTileEntity.monthlyBudget;

      // カテゴリーの名前
      final categoryName =
          categoryTileEntity.monthlyExpenseByCategoryEntity.bigCategoryName;

      // カテゴリーのカラーコード
      final colorCode =
          categoryTileEntity.monthlyExpenseByCategoryEntity.categoryColor;

      // カテゴリーのカラー
      final color = MyColors().getColorFromHex(colorCode);

      // カテゴリーのアイコンパス
      final categoryIconPath =
          categoryTileEntity.monthlyExpenseByCategoryEntity.categoryIconPath;

      // 項目のリスト
      final List<SmallCategoryTileEntity> smallCategoryList =
          categoryTileEntity.smallCategoryList;

      // 予算を超えているか
      bool isOverBudget = false;

      if (totalExpense > budget) {
        isOverBudget = true;
      }

      // 予算が設定されているか
      bool isSetBudget = true;

      //横棒グラフの初期値
      double barWidth = 0;

      // 画面の横幅を取得
      final screenWidthSize = MediaQuery.of(context).size.width;

      // 画面の倍率を計算
      // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
      final screenHorizontalMagnification =
          screenHorizontalMagnificationGetter(screenWidthSize);

      // 横棒グラフの幅を計算
      double degrees = (totalExpense / budget);
      barWidth = degrees <= 1.0 ? barFrameWidth * degrees : barFrameWidth;

      // 支出合計のLabel
      final String paymentSumLabel = formattedPriceGetter(totalExpense);

      // 予算のLabel
      final String budgetLabel = formattedPriceGetter(budget);

      isSetBudget = budget == 0 ? false : true;
      return Container(
        alignment: Alignment.center,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                                  color: MyColors().getColorFromHex(colorCode),
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
                                    color:
                                        MyColors().getColorFromHex(colorCode),
                                  ),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              ],
                            )
                      // 予算が0円の場合
                      : const SizedBox(),
                ),

                /// バー下ラベル
                Container(
                  width: barFrameWidth * screenHorizontalMagnification,
                  // 最小の制約を設定することで子widgetのRowが最大まで拡大する
                  constraints: BoxConstraints(
                    minWidth: barFrameWidth * screenHorizontalMagnification,
                    minHeight: 30,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 2.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SvgPicture.asset(
                            categoryIconPath,
                            colorFilter:
                                ColorFilter.mode(color, BlendMode.srcIn),
                            semanticsLabel: 'categoryIcon',
                            width: 25,
                            height: 25,
                          ),
                        ),
                      ),
                      // カテゴリー名
                      Expanded(
                        child: Text(
                          categoryName,
                          style: MyFonts.categoryExpenseHistoryPageCategoryName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          // カテゴリー総支出
                          Text(
                            paymentSumLabel,
                            overflow: TextOverflow.ellipsis,
                            style: MyFonts.categoryExpenseHistoryPagePrice,
                            textAlign: TextAlign.end,
                          ),
                          Text(
                            ' 円',
                            style: MyFonts.categoryExpenseHistoryPageYen,
                          ),

                          // 予算が設定されているかどうか
                          isSetBudget
                              // 予算が設定されている場合
                              ? Row(
                                  children: [
                                    Text(
                                      '  /予算 ',
                                      style: MyFonts
                                          .categoryExpenseHistoryPageSubText,
                                    ),
                                    // カテゴリー予算
                                    Text(
                                      budgetLabel,
                                      overflow: TextOverflow.ellipsis,
                                      style: MyFonts
                                          .categoryExpenseHistoryPageBudgetPrice,
                                      textAlign: TextAlign.end,
                                    ),
                                    Padding(
                                      // 円の右のスペース
                                      padding:
                                          const EdgeInsets.only(right: 2.0),
                                      child: Text(
                                        ' 円',
                                        style: MyFonts
                                            .categoryExpenseHistoryPageYen,
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                )
                              // 予算が設定されていない場合、なにも表示しない
                              : const SizedBox(),
                        ],
                      )
                    ],
                  ),
                ),

                // 区切り線
                const Divider(
                  // ウィジェット自体の高さ
                  height: 16,
                  // 線の太さ
                  thickness: 1,
                  indent: 0,
                  endIndent: 0,
                  color: MyColors.separater,
                ),

                // 小カテゴリーのリスト
                ...List.generate(smallCategoryList.length, (index) {
                  // 支出合計のLabel
                  final String totalExpenseBySmallCategory =
                      formattedPriceGetter(
                          smallCategoryList[index].totalExpenseBySmallCategory);

                  // 小カテゴリーのID
                  final int smallCategoryId = smallCategoryList[index].id;

                  return GestureDetector(
                    // タップ時の挙動: 透明部分もタップ可能にする
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => SmallCategoryExpenseHistoryPage(
                                smallId: smallCategoryId,
                              )));
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // 小カテゴリーのカテゴリーカラーアイコン
                        SizedBox(
                          // 左の項目名エリア:0.45 真ん中の件数エリア: 0.1 右の支払い合計エリア:0.45
                          width: barFrameWidth * 0.45,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 25,
                                height: 25,
                                child: Center(
                                  child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: MyColors()
                                            .getColorFromHex(colorCode),
                                      )),
                                ),
                              ),

                              // 小カテゴリー名
                              Text(
                                smallCategoryList[index].smallCategoryName,
                                style: MyFonts
                                    .categoryExpenseHistoryPageCategoryName,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                            // 左の項目名エリア:0.45 真ん中の件数エリア: 0.1 右の支払い合計エリア:0.45
                            width: barFrameWidth * 0.15,
                            child: Text(
                              '${smallCategoryList[index].recordCount}件',
                              style:
                                  MyFonts.categoryExpenseHistoryPageRecordCount,
                              textAlign: TextAlign.right,
                              overflow: TextOverflow.ellipsis,
                            )),

                        // 小カテゴリーの支払い合計
                        SizedBox(
                          // 左の項目名エリア:0.45 真ん中の件数エリア: 0.1 右の支払い合計エリア:0.45
                          width: barFrameWidth * 0.4,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                totalExpenseBySmallCategory,
                                style: MyFonts.categoryExpenseHistoryPagePrice,
                                textAlign: TextAlign.end,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                ' 円',
                                style: MyFonts.categoryExpenseHistoryPageYen,
                                textAlign: TextAlign.end,
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              MyIcon.next,
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      );
    }, error: (error, stackTrace) {
      return const Center(
        child: Text('データの取得に失敗しました'),
      );
    }, loading: () {
      return const Center(
        child: CircularProgressIndicator(),
      );
    });
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
