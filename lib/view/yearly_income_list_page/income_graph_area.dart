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
import 'package:kakeibo/view/component/category_ratio_row.dart';
import 'package:kakeibo/view/component/summary_band_card.dart';
import 'package:kakeibo/view/yearly_income_list_page/yearly_category_income_list_page.dart';

/// 収入一覧のサマリーヘッダー
///
/// 帯に総収入、その下に大カテゴリー別の内訳（構成比バー・金額・比率）を
/// 1枚のカードで示す。行のタップでカテゴリー明細へ。
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

            return SummaryBandCard(
              tintColor: context.colors.income,
              band: SummaryBandRow(
                label: '総収入',
                priceLabel: yenmarkFormattedPriceGetter(
                  incomeDatas.totalIncome,
                ),
              ),
              children: [
                const SizedBox(height: AppSpacing.xs),
                for (var i = 0; i < incomeDatas.categorySummaries.length; i++) ...[
                  if (i != 0) const CategoryRowDivider(),
                  _IncomeCategoryRow(
                    category: incomeDatas.categorySummaries[i],
                    totalIncome: incomeDatas.totalIncome,
                    period: widget.period,
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
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

/// 大カテゴリー1行。タップでカテゴリー明細へ
class _IncomeCategoryRow extends StatelessWidget {
  const _IncomeCategoryRow({
    required this.category,
    required this.totalIncome,
    required this.period,
  });

  final IncomeCategorySummaryValue category;
  final int totalIncome;
  final PeriodValue period;

  @override
  Widget build(BuildContext context) {
    final ratio = totalIncome == 0
        ? 0.0
        : category.totalAmount / totalIncome;

    return CategoryRatioRow(
      icon: SvgPicture.asset(
        category.iconPath,
        colorFilter: ColorFilter.mode(
          ColorCode.toColor(category.colorCode),
          BlendMode.srcIn,
        ),
        semanticsLabel: 'categoryIcon',
        width: 25,
        height: 25,
      ),
      name: category.categoryName,
      priceLabel: yenmarkFormattedPriceGetter(category.totalAmount),
      ratio: ratio,
      colorCode: category.colorCode,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => YearlyCategoryIncomeListPage(
              period: period,
              bigCategoryId: category.bigCategoryId,
              categoryName: category.categoryName,
            ),
          ),
        );
      },
    );
  }
}
