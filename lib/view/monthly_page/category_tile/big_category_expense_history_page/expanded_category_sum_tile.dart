import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/category_card_entity.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_entity.dart';
import 'package:kakeibo/domain_service/month_period_service/period_status_service.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/budget_setting_page/single_category_budget_sheet.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/component/failure_snackbar.dart';
import 'package:kakeibo/view/monthly_page/category_tile/big_category_expense_history_page/small_category_expanded_history_page/small_category_expanded_history_page.dart';
import 'package:kakeibo/view/monthly_page/category_tile/budget_label.dart';
import 'package:kakeibo/view/monthly_page/category_tile/category_sum_graph.dart';
import 'package:kakeibo/view/monthly_page/category_tile/price_label.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_category_tile_entity_provider.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_fixed_cost_value_provider.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_monthly_budget_provider.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';

class ExpandedCategoryTile extends ConsumerWidget {
  const ExpandedCategoryTile({required this.bigId, super.key});
  final int bigId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(resolvedCategoryTileEntityProvider(bigId))
        .when(
          data: (categoryTileEntity) {
            // カテゴリーのカラーコード（小カテゴリーアイコンに使用）
            final colorCode =
                categoryTileEntity.monthlyExpenseByCategoryEntity.categoryColor;

            // 小カテゴリーのリスト
            final List<SmallCategoryTileEntity> smallCategoryList =
                categoryTileEntity.smallCategoryList;

            return CardContainer(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // 小カテゴリーリスト部分の width 配分計算用
                    // 画面幅からの逆算だと実際の行幅と食い違って必ず溢れるため、
                    // 行に与えられる制約そのものを按分の基準にする
                    final double barFrameWidth = constraints.maxWidth;

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 1行目: 「支出合計」 | 金額
                        // カテゴリー名とアイコンは AppBar のタイトルに移した（KP-027）
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '支出合計',
                              style: context.textStyles.listTilePrimaryTitle,
                            ),
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
                        // 3行目: 残り／超過 | 「予算を設定」（KP-027）
                        _BudgetActionRow(
                          bigId: bigId,
                          categoryTile: categoryTileEntity,
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
                              yenmarkFormattedPriceGetter(
                                smallCategoryList[index]
                                    .totalExpenseBySmallCategory,
                              );

                          // 小カテゴリーのID
                          final int smallCategoryId =
                              smallCategoryList[index].id;

                          return GestureDetector(
                            // タップ時の挙動: 透明部分もタップ可能にする
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      SmallCategoryExpenseHistoryPage(
                                        smallId: smallCategoryId,
                                      ),
                                ),
                              );
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
                                              color: ColorCode.toColor(
                                                colorCode,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // 小カテゴリー名
                                      Text(
                                        smallCategoryList[index]
                                            .smallCategoryName,
                                        style: context
                                            .textStyles
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
                                    style: context
                                        .textStyles
                                        .appCardTertiaryPriceLabel,
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

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
                                        style: context
                                            .textStyles
                                            .appCardSecondaryPriceLabel,
                                        textAlign: TextAlign.end,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      MyIcon.next(context),
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
            );
          },
          error: (error, stackTrace) {
            return const AppErrorState(message: 'データの取得に失敗しました');
          },
          loading: () {
            return const Center(child: CircularProgressIndicator());
          },
        );
  }
}

/// 集計タイルの3行目: 予算の残り（超過）と「予算を設定」リンク（KP-027）
class _BudgetActionRow extends ConsumerWidget {
  const _BudgetActionRow({required this.bigId, required this.categoryTile});

  final int bigId;
  final CategoryCardEntity categoryTile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool hasBudget =
        categoryTile.graphType == GraphType.hasBudget ||
        categoryTile.graphType == GraphType.hasBudgetButOver;

    // 残りは 予算 − 支出。マイナスなら超過として danger 色で出す
    final remaining = categoryTile.monthlyBudget - categoryTile.monthlyExpense;
    final isOver = remaining < 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (hasBudget)
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: isOver ? '超過 ' : '残り ',
                      style: isOver
                          ? context.textStyles.appCardTertiaryPriceUnit
                                .copyWith(color: context.colors.danger)
                          : context.textStyles.appCardTertiaryPriceUnit,
                    ),
                    TextSpan(
                      text: yenmarkFormattedPriceGetter(remaining.abs()),
                      style: isOver
                          ? context.textStyles.appCardTertiaryPriceLabel
                                .copyWith(color: context.colors.danger)
                          : context.textStyles.appCardTertiaryPriceLabel,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          Text('予算は未設定です', style: context.textStyles.insetGroupNote),
        AppInkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _openBudgetSheet(context, ref),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(AppIcons.edit, size: 14, color: context.colors.primary),
                const SizedBox(width: 4),
                Text(
                  '予算を設定',
                  style: context.textStyles.textButtonTextStyle,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 表示中の月度・この大カテゴリーの予算入力シートを開く
  Future<void> _openBudgetSheet(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final dateScope = await ref.read(analyzePageDateScopeEntityProvider.future);

    // 過去の月度の予算は編集できない（「毎月の予算」と同じ扱い）
    if (dateScope.periodStatus == PeriodStatus.past) {
      FailureSnackBar.show(messenger, message: '過去の予算は編集できません');
      return;
    }

    final budgetEditValues = await ref.read(
      resolvedBudgetEditValueProvider.future,
    );
    final budgetEditValue = budgetEditValues
        .where((v) => v.expenseBigCategoryId == bigId)
        .firstOrNull;
    if (budgetEditValue == null) {
      FailureSnackBar.show(messenger, message: '予算を取得できませんでした');
      return;
    }

    final forecast = await ref.read(
      resolvedFixedCostForecastValueProvider.future,
    );
    if (!context.mounted) return;

    await showSingleCategoryBudgetSheet(
      context,
      budgetEditValue: budgetEditValue,
      periodLabel: yyyyMMtoMMGetter(dateScope.aggregationMonthPeriod),
      isCurrentPeriod: dateScope.periodStatus == PeriodStatus.current,
      fixedCostForecast: forecast.amountOf(bigId),
    );
  }
}
