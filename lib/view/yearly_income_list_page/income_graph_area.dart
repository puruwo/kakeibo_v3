import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/application/yearly_income_list/yearly_income_list_usecase.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/yearly_income_list_value/income_category_summary_value.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/yearly_expense_list_page/expense_month_group.dart';
import 'package:kakeibo/view/yearly_expense_list_page/yearly_expense_list_page.dart';

/// 収入一覧のサマリーヘッダー
///
/// 総収入は面を持たないヒーロー表示（大きな金額＋月平均）、
/// カテゴリー別内訳は支出一覧と同じ構成比バーのランキングカードで示す。
class IncomeGraphArea extends ConsumerStatefulWidget {
  const IncomeGraphArea({super.key, required this.period});

  final PeriodValue period;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomeGraphAreaState();
}

class _IncomeGraphAreaState extends ConsumerState<IncomeGraphArea> {
  @override
  Widget build(BuildContext context) {
    return ref
        .watch(yearlyIncomeListNotifierProvider(widget.period))
        .when(
          data: (incomeDatas) {
            if (incomeDatas.monthlyGroups.isEmpty) {
              return CardContainer(
                height: 120,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Center(
                  child: Text(
                    '収入データがありません',
                    style: AppTextStyles.listEmptyMessage,
                  ),
                ),
              );
            }

            final monthCount = expensePeriodMonthCount(widget.period);
            final monthlyAverage = (incomeDatas.totalIncome / monthCount)
                .round();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 総収入ヒーロー（面なし）
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('総収入', style: AppTextStyles.appCardTitleLabel),
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            yenmarkFormattedPriceGetter(
                              incomeDatas.totalIncome,
                            ),
                            style: AppTextStyles.summaryHeroPriceLabel,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          // 桁が大きい場合に行がオーバーフローしないよう可変幅にする
                          Flexible(
                            child: Text(
                              '月平均 ${yenmarkFormattedPriceGetter(monthlyAverage)}',
                              style: AppTextStyles.budgetFixedCostForecastLabel,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                // カテゴリー別内訳（支出一覧と同じ構成比バーのランキング）
                CardContainer(
                  width: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Column(
                    children: [
                      for (
                        var i = 0;
                        i < incomeDatas.categorySummaries.length;
                        i++
                      ) ...[
                        if (i != 0)
                          Padding(
                            padding: const EdgeInsets.only(left: AppSpacing.lg),
                            child: Divider(
                              height: 0.5,
                              thickness: 0.5,
                              color: context.colors.separator,
                            ),
                          ),
                        _IncomeCategoryRow(
                          category: incomeDatas.categorySummaries[i],
                          totalIncome: incomeDatas.totalIncome,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => Container(
            height: 200,
            decoration: BoxDecoration(
              color: context.colors.surfaceElevated2,
              border: Border.all(color: context.colors.surfaceBorder, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Container(
            height: 200,
            decoration: BoxDecoration(
              color: context.colors.surfaceElevated2,
              border: Border.all(color: context.colors.surfaceBorder, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const AppErrorState(),
          ),
        );
  }
}

/// カテゴリー1行（アイコン・名称・金額・構成比・バー）
class _IncomeCategoryRow extends StatelessWidget {
  const _IncomeCategoryRow({required this.category, required this.totalIncome});

  final IncomeCategorySummaryValue category;
  final int totalIncome;

  @override
  Widget build(BuildContext context) {
    final ratio = totalIncome == 0
        ? 0.0
        : category.totalAmount / totalIncome;
    final percentLabel = '${(ratio * 100).toStringAsFixed(1)}%';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          SvgPicture.asset(
            category.iconPath,
            colorFilter: ColorFilter.mode(
              ColorCode.toColor(category.colorCode),
              BlendMode.srcIn,
            ),
            semanticsLabel: 'categoryIcon',
            width: 22,
            height: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        category.categoryName,
                        style: AppTextStyles.listTilePrimaryTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      yenmarkFormattedPriceGetter(category.totalAmount),
                      style: AppTextStyles.appCardSecondaryPriceLabel,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      percentLabel,
                      style: AppTextStyles.budgetFixedCostForecastLabel,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ExpenseRatioBar(ratio: ratio, colorCode: category.colorCode),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
