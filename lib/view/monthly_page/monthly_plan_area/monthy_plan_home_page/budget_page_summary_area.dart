import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/all_category_card_value/all_category_card_entity.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/summary_bar_graph.dart';
import 'package:kakeibo/view/monthly_page/skeleton/monthly_plan_skeleton.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_all_category_tile_entity_provider.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_monthly_budget_provider.dart';
import 'package:kakeibo/view_model/state/budget_edit_page/editing_budget_prices/editing_budget_prices.dart';

/// 予算ページ上部のサマリーエリア
/// 予算合計と収入合計のみを表示する（支出のテキスト情報は含まない）
/// 棒グラフは予算カテゴリー別と収入カテゴリー別でそれぞれ表示する
/// denominator = max(予算合計, 収入合計) で両方の棒グラフを統一スケールにする
class BudgetPageSummaryArea extends HookConsumerWidget {
  const BudgetPageSummaryArea({super.key});

  /// 外側余白とカードを包むヘルパー（空でない場合のみ使用）
  Widget _wrapTop(Widget child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: child,
          ),
          const SizedBox(height: 8),
        ],
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 編集中の予算金額を常にwatchする（autoDisposeの生存を保証するため）
    final editingPrices = ref.watch(editingBudgetPricesNotifierProvider);

    return ref.watch(resolvedAllCategoryCardModelProvider).when(
          data: (originalModel) {
            // 編集中の値がある場合、予算関連の表示を上書きする
            final allCategoryCardEntity =
                _applyEditingOverrides(ref, originalModel, editingPrices);

            // 予算も収入も無い場合はサマリーを非表示にして上に詰める
            if (!allCategoryCardEntity.cardStatusType.hasBudget &&
                !allCategoryCardEntity.cardStatusType.hasIncome) {
              return const SizedBox.shrink();
            }

            // 予算と収入の大きい方を棒グラフの基準にする
            final budgetIncomeDenominator = max(
                allCategoryCardEntity.allCategoryTotalBudget,
                allCategoryCardEntity.allCategoryTotalIncome);

            // 予定収支 = 収入 - 予算
            final projectedSavings =
                allCategoryCardEntity.allCategoryTotalIncome -
                    allCategoryCardEntity.allCategoryTotalBudget;

            return _wrapTop(CardContainer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 予算エリア
                  if (allCategoryCardEntity.cardStatusType.hasBudget)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '予算',
                                style: AppTextStyles.appCardTitleLabel,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                yenmarkFormattedPriceGetter(
                                    allCategoryCardEntity
                                        .allCategoryTotalBudget),
                                textAlign: TextAlign.end,
                                overflow: TextOverflow.ellipsis,
                                style: AppTextStyles
                                    .appCardOptionalSecondaryPriceLabel,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: LayoutBuilder(
                              builder: (context, constraints) =>
                                  SummaryBarGraph(
                                amounts:
                                    allCategoryCardEntity.budgetCategoryList,
                                colors:
                                    allCategoryCardEntity.budgetCategoryColorList,
                                denominator: budgetIncomeDenominator,
                                maxGraphWidth: constraints.maxWidth,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // 収入エリア
                  if (allCategoryCardEntity.cardStatusType.hasIncome)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    '総収入',
                                    style: AppTextStyles.appCardTitleLabel,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    yenmarkFormattedPriceGetter(
                                        allCategoryCardEntity
                                            .allCategoryTotalIncome),
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyles
                                        .appCardOptionalSecondaryPriceLabel,
                                  ),
                                ],
                              ),
                              // 予定収支
                              if (projectedSavings != 0)
                                Flexible(
                                  child: RichText(
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: '予定収支 ',
                                        style: AppTextStyles
                                            .appCardTertiaryTitleLabel,
                                      ),
                                      TextSpan(
                                        text: signedYenmarkFormattedPriceGetter(
                                            projectedSavings),
                                        style: AppTextStyles
                                            .appCardTertiaryPriceLabel,
                                      ),
                                    ]),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            alignment: Alignment.centerLeft,
                            child: LayoutBuilder(
                              builder: (context, constraints) =>
                                  SummaryBarGraph(
                                amounts:
                                    allCategoryCardEntity.incomeCategoryList,
                                colors:
                                    allCategoryCardEntity.incomeCategoryColorList,
                                denominator: budgetIncomeDenominator,
                                maxGraphWidth: constraints.maxWidth,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),
                ],
              ),
            ));
          },
          loading: () => _wrapTop(const MonthlyPlanSkeleton()),
          error: (error, stack) => _wrapTop(Center(child: Text('$error'))),
        );
  }

  /// 編集中の予算値でモデルの予算関連データを上書きする
  MonthPlanCardModel _applyEditingOverrides(
    WidgetRef ref,
    MonthPlanCardModel originalModel,
    Map<int, int> editingPrices,
  ) {
    if (editingPrices.isEmpty) return originalModel;

    final budgetEditValues =
        ref.watch(resolvedBudgetEditValueProvider).valueOrNull;
    if (budgetEditValues == null) return originalModel;

    // 元の通常カテゴリー予算のうち price > 0 の件数を取得
    // モデルの budgetCategoryList は [通常カテゴリー(price>0)] + [固定費カテゴリー] の順
    final originalNormalBudgetCount =
        budgetEditValues.where((e) => e.price > 0).length;

    // 固定費カテゴリー部分を元のモデルから取り出す
    final fixedCostBudgetAmounts =
        originalModel.budgetCategoryList.length > originalNormalBudgetCount
            ? originalModel.budgetCategoryList
                .sublist(originalNormalBudgetCount)
            : <int>[];
    final fixedCostBudgetColors =
        originalModel.budgetCategoryColorList.length > originalNormalBudgetCount
            ? originalModel.budgetCategoryColorList
                .sublist(originalNormalBudgetCount)
            : <String>[];

    // 編集値を反映した通常カテゴリーの予算リストを構築
    List<int> newNormalBudgetAmounts = [];
    List<String> newNormalBudgetColors = [];
    int newNormalBudgetTotal = 0;

    for (var budgetEdit in budgetEditValues) {
      final price =
          editingPrices.containsKey(budgetEdit.expenseBigCategoryId)
              ? editingPrices[budgetEdit.expenseBigCategoryId]!
              : budgetEdit.price;
      newNormalBudgetTotal += price;
      if (price > 0) {
        newNormalBudgetAmounts.add(price);
        newNormalBudgetColors.add(budgetEdit.colorCode);
      }
    }

    // 通常カテゴリー + 固定費カテゴリーを結合
    final newBudgetCategoryList = [
      ...newNormalBudgetAmounts,
      ...fixedCostBudgetAmounts,
    ];
    final newBudgetCategoryColorList = [
      ...newNormalBudgetColors,
      ...fixedCostBudgetColors,
    ];

    // 予算合計 = 通常カテゴリー合計 + 固定費（通常カテゴリーが0なら0）
    final newTotalBudget = newNormalBudgetTotal > 0
        ? newNormalBudgetTotal + originalModel.allFixedCostExpense
        : 0;

    // 予算が新たに設定された場合、cardStatusTypeを更新して予算セクションを表示
    AllCategoryCardStatusType cardStatusType = originalModel.cardStatusType;
    if (newTotalBudget > 0 && !originalModel.cardStatusType.hasBudget) {
      cardStatusType = originalModel.cardStatusType.hasIncome
          ? AllCategoryCardStatusType.hasBudgetAndIncomeNotOver
          : AllCategoryCardStatusType.hasOnlyBudget;
    }

    return originalModel.copyWith(
      cardStatusType: cardStatusType,
      allCategoryTotalBudget: newTotalBudget,
      budgetCategoryList: newBudgetCategoryList,
      budgetCategoryColorList: newBudgetCategoryColorList,
    );
  }
}
