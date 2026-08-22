import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/all_category_card_value/all_category_card_entity.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/summary_bar_graph.dart';
import 'package:kakeibo/view/monthly_page/skeleton/monthly_plan_skeleton.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_all_category_tile_entity_provider.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_monthly_budget_provider.dart';
import 'package:kakeibo/view_model/state/budget_edit_page/editing_budget_prices/editing_budget_prices.dart';

/// 予算ページ上部のサマリーエリア（見出しなしのインセットグループ。仕様 §8.5）
///
/// 「予算」行＝カテゴリー別予算額の構成比バー＋合計、
/// 「総収入」行＝収入カテゴリー別の構成比バー＋合計、「予定収支」行の3行で構成する。
/// denominator = max(予算合計, 収入合計) で両方の棒グラフを統一スケールにする。
/// 固定費の自動加算セグメントは廃止した（仕様 §7.3）。
class BudgetPageSummaryArea extends HookConsumerWidget {
  const BudgetPageSummaryArea({super.key});

  /// ラベル列の幅（「予算」「総収入」を揃える）
  static const double _labelWidth = 56;

  /// 金額列の幅
  static const double _amountWidth = 84;

  /// 外側余白でグループを包むヘルパー（空でない場合のみ使用）
  Widget _wrapTop(Widget child) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
            child: child,
          ),
          const SizedBox(height: AppSpacing.md),
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

            return _wrapTop(AppInsetGroup(
              children: [
                // 予算行
                if (allCategoryCardEntity.cardStatusType.hasBudget)
                  _barRow(
                    context,
                    label: '予算',
                    amounts: allCategoryCardEntity.budgetCategoryList,
                    colors: allCategoryCardEntity.budgetCategoryColorList,
                    denominator: budgetIncomeDenominator,
                    total: allCategoryCardEntity.allCategoryTotalBudget,
                  ),

                // 総収入行
                if (allCategoryCardEntity.cardStatusType.hasIncome)
                  _barRow(
                    context,
                    label: '総収入',
                    amounts: allCategoryCardEntity.incomeCategoryList,
                    colors: allCategoryCardEntity.incomeCategoryColorList,
                    denominator: budgetIncomeDenominator,
                    total: allCategoryCardEntity.allCategoryTotalIncome,
                  ),

                // 予定収支行
                _projectedSavingsRow(context, projectedSavings),
              ],
            ));
          },
          loading: () => _wrapTop(const MonthlyPlanSkeleton()),
          error: (error, stack) => _wrapTop(const AppErrorState()),
        );
  }

  /// 構成比バーつきの1行（ラベル／バー／合計）
  Widget _barRow(
    BuildContext context, {
    required String label,
    required List<int> amounts,
    required List<String> colors,
    required int denominator,
    required int total,
  }) {
    return SizedBox(
      height: kAppInsetRowHeight,
      child: Padding(
        padding: const EdgeInsets.only(left: kAppInsetRowIndent, right: 12),
        child: Row(
          children: [
            SizedBox(
              width: _labelWidth,
              child: Text(label, style: AppTextStyles.insetGroupLabel),
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => SummaryBarGraph(
                  amounts: amounts,
                  colors: colors,
                  denominator: denominator,
                  maxGraphWidth: constraints.maxWidth,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: _amountWidth,
              child: Text(
                yenmarkFormattedPriceGetter(total),
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.insetGroupHistoryPrice,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 予定収支の行（収入超過は income 色、予算超過は expense 色）
  Widget _projectedSavingsRow(BuildContext context, int projectedSavings) {
    final color = projectedSavings < 0
        ? context.colors.expense
        : context.colors.income;

    return SizedBox(
      height: kAppInsetRowHeight,
      child: Padding(
        padding: const EdgeInsets.only(left: kAppInsetRowIndent, right: 12),
        child: Row(
          children: [
            Text(
              '予定収支',
              style: AppTextStyles.insetGroupLabel
                  .copyWith(color: context.colors.textSecondary),
            ),
            const Spacer(),
            Text(
              signedYenmarkFormattedPriceGetter(projectedSavings, showPlusSign: true),
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.insetGroupHistoryPrice.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  /// 編集中の予算値でモデルの予算関連データを上書きする
  ///
  /// 固定費セグメントを廃止したため、予算リストは通常カテゴリーの入力値だけで構築する。
  MonthPlanCardModel _applyEditingOverrides(
    WidgetRef ref,
    MonthPlanCardModel originalModel,
    Map<int, int> editingPrices,
  ) {
    if (editingPrices.isEmpty) return originalModel;

    final budgetEditValues =
        ref.watch(resolvedBudgetEditValueProvider).valueOrNull;
    if (budgetEditValues == null) return originalModel;

    // 編集値を反映した予算リストを構築（予算合計＝カテゴリー予算の合計のみ。仕様 §7.3）
    final List<int> newBudgetAmounts = [];
    final List<String> newBudgetColors = [];
    int newTotalBudget = 0;

    for (var budgetEdit in budgetEditValues) {
      final price = editingPrices.containsKey(budgetEdit.expenseBigCategoryId)
          ? editingPrices[budgetEdit.expenseBigCategoryId]!
          : budgetEdit.price;
      newTotalBudget += price;
      if (price > 0) {
        newBudgetAmounts.add(price);
        newBudgetColors.add(budgetEdit.colorCode);
      }
    }

    // 予算が新たに設定された場合、cardStatusTypeを更新して予算行を表示
    AllCategoryCardStatusType cardStatusType = originalModel.cardStatusType;
    if (newTotalBudget > 0 && !originalModel.cardStatusType.hasBudget) {
      cardStatusType = originalModel.cardStatusType.hasIncome
          ? AllCategoryCardStatusType.hasBudgetAndIncomeNotOver
          : AllCategoryCardStatusType.hasOnlyBudget;
    }

    return originalModel.copyWith(
      cardStatusType: cardStatusType,
      allCategoryTotalBudget: newTotalBudget,
      budgetCategoryList: newBudgetAmounts,
      budgetCategoryColorList: newBudgetColors,
    );
  }
}
