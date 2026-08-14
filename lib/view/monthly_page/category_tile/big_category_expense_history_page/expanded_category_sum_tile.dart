import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_entity.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/monthly_page/category_tile/big_category_expense_history_page/small_category_expanded_history_page/small_category_expanded_history_page.dart';
import 'package:kakeibo/view/monthly_page/category_tile/budget_label.dart';
import 'package:kakeibo/view/monthly_page/category_tile/category_sum_graph.dart';
import 'package:kakeibo/view/monthly_page/category_tile/category_sum_text.dart';
import 'package:kakeibo/view/monthly_page/category_tile/price_label.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_category_tile_entity_provider.dart';

class ExpandedCategoryTile extends ConsumerWidget {
  const ExpandedCategoryTile({required this.bigId, super.key});
  final int bigId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedCategoryTileEntityProvider(bigId)).when(
      data: (categoryTileEntity) {
        // カテゴリーのカラーコード（小カテゴリーアイコンに使用）
        final colorCode =
            categoryTileEntity.monthlyExpenseByCategoryEntity.categoryColor;

        // 小カテゴリーのリスト
        final List<SmallCategoryTileEntity> smallCategoryList =
            categoryTileEntity.smallCategoryList;

        return CardContainer(
          alignment: Alignment.center,
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // 小カテゴリーリスト部分の width 配分計算用
                  // 画面幅からの逆算だと実際の行幅と食い違って必ず溢れるため、
                  // 行に与えられる制約そのものを按分の基準にする
                  final double barFrameWidth = constraints.maxWidth;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 1行目: アイコン+カテゴリー名 | 金額
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CategorySumText(categoryTile: categoryTileEntity),
                          PriceLabel(categoryTile: categoryTileEntity),
                        ],
                      ),
                      // 2行目: 進捗バー | 予算金額
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // バー
                          Expanded(
                            child: LayoutBuilder(
                              builder: (context, constraints) =>
                                  CategorySumGraph(
                                barFrameMaxWidth: constraints.maxWidth,
                                categoryTile: categoryTileEntity,
                              ),
                            ),
                          ),
                          // 予算
                          BudgetLabel(categoryTile: categoryTileEntity),
                        ],
                      ),

                      // 区切り線
                      Divider(
                        // ウィジェット自体の高さ
                        height: 16,
                        // 線の太さ
                        thickness: 1,
                        indent: 0,
                        endIndent: 0,
                        color: context.colors.separator,
                      ),

                      // 小カテゴリーのリスト
                      ...List.generate(smallCategoryList.length, (index) {
                        // 支出合計のLabel
                        final String totalExpenseBySmallCategory =
                            yenmarkFormattedPriceGetter(smallCategoryList[index]
                                .totalExpenseBySmallCategory);

                        // 小カテゴリーのID
                        final int smallCategoryId = smallCategoryList[index].id;

                        return GestureDetector(
                          // タップ時の挙動: 透明部分もタップ可能にする
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    SmallCategoryExpenseHistoryPage(
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
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              color:
                                                  ColorCode.toColor(colorCode),
                                            )),
                                      ),
                                    ),

                                    // 小カテゴリー名
                                    Text(
                                      smallCategoryList[index]
                                          .smallCategoryName,
                                      style: AppTextStyles
                                          .listTilePrimaryTitle,
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
                                    style: AppTextStyles.appCardTitleLabel,
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                  )),

                              // 小カテゴリーの支払い合計
                              SizedBox(
                                // 左の項目名エリア:0.45 真ん中の件数エリア: 0.1 右の支払い合計エリア:0.45
                                width: barFrameWidth * 0.4,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      totalExpenseBySmallCategory,
                                      style: AppTextStyles
                                          .appCardSecondaryPriceLabel,
                                      textAlign: TextAlign.end,
                                      overflow: TextOverflow.ellipsis,
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
                  );
                },
              ),
            ),
          ),
        );
      },
      error: (error, stackTrace) {
        return const Center(
          child: Text('データの取得に失敗しました'),
        );
      },
      loading: () {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}
