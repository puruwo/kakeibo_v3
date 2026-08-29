import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/expense_history/yearly_expense_list_usecase.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/expense_category_icon.dart';
import 'package:kakeibo/view/yearly_expense_list_page/expense_month_group.dart';
import 'package:kakeibo/view/yearly_expense_list_page/yearly_category_expense_list_page.dart';

/// 支出一覧画面（案件 UIデザイン改修 §6・本実装）
///
/// トップ「年間収支」カードの総支出から遷移する、年度の支出を俯瞰する画面。
/// カテゴリー別集計（使い道の俯瞰）のみを表示する。
/// カテゴリー行のタップで月毎アコーディオンの明細（YearlyCategoryExpenseListPage）へ。
class YearlyExpenseListPage extends ConsumerWidget {
  const YearlyExpenseListPage({super.key, required this.period});

  final PeriodValue period;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;
    final monthCount = expensePeriodMonthCount(period);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassAppBarBackground(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('支出一覧', style: AppTextStyles.pageHeaderText),
      ),
      body: ref
          .watch(yearlyExpenseListNotifierProvider(period))
          .when(
            data: (value) {
              if (value.allRows.isEmpty) {
                return Center(
                  child: Text(
                    '記録がまだありません',
                    style: AppTextStyles.listEmptyMessage,
                  ),
                );
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    topInset + AppSpacing.lg,
                    AppSpacing.lg,
                    // グロナビに隠れないよう、末尾はグロナビ分の余白を必ず確保する
                    context.bottomNavClearance + AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TotalHero(value: value, monthCount: monthCount),
                      const SizedBox(height: AppSpacing.lg),
                      _CategoryBreakdownCard(value: value, period: period),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Center(child: AppErrorState()),
          ),
    );
  }
}

/// 総支出のヒーロー（面なし・収入一覧と同じ1行＋生活/特別の内訳行）
class _TotalHero extends StatelessWidget {
  const _TotalHero({required this.value, required this.monthCount});

  final YearlyExpenseListValue value;
  final int monthCount;

  @override
  Widget build(BuildContext context) {
    final monthlyAverage = (value.totalExpense / monthCount).round();
    final breakdownLabel = livingSpecialBreakdownLabel(
      living: value.livingTotal,
      special: value.specialTotal,
      livingLabel: AccountTypeConstants.livingLabel,
      specialLabel: AccountTypeConstants.specialLabel,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('総支出', style: AppTextStyles.appCardTitleLabel),
              const Spacer(),
              Text(
                yenmarkFormattedPriceGetter(value.totalExpense),
                style: AppTextStyles.summaryHeroPriceLabel,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                '月平均 ${yenmarkFormattedPriceGetter(monthlyAverage)}',
                style: AppTextStyles.budgetFixedCostForecastLabel,
              ),
            ],
          ),
          if (breakdownLabel != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              breakdownLabel,
              style: AppTextStyles.budgetFixedCostForecastLabel,
            ),
          ],
        ],
      ),
    );
  }
}

/// カテゴリー別内訳カード（構成比バーつき・行タップで明細へ）
class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard({required this.value, required this.period});

  final YearlyExpenseListValue value;
  final PeriodValue period;

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (var i = 0; i < value.categories.length; i++) ...[
            if (i != 0)
              Padding(
                padding: const EdgeInsets.only(left: AppSpacing.lg),
                child: Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: context.colors.separator,
                ),
              ),
            _CategoryRow(
              category: value.categories[i],
              totalExpense: value.totalExpense,
              period: period,
            ),
          ],
        ],
      ),
    );
  }
}

/// カテゴリー1行（アイコン・名称・金額・構成比・バー）
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.totalExpense,
    required this.period,
  });

  final YearlyExpenseCategorySummary category;
  final int totalExpense;
  final PeriodValue period;

  @override
  Widget build(BuildContext context) {
    final ratio = category.ratioOf(totalExpense);
    final percentLabel = '${(ratio * 100).toStringAsFixed(1)}%';
    // バーは生活=実色・特別=半透明の2トーンで分割する
    final livingRatio = totalExpense <= 0
        ? 0.0
        : category.livingSum / totalExpense;
    final specialRatio = totalExpense <= 0
        ? 0.0
        : category.specialSum / totalExpense;
    final breakdownLabel = livingSpecialBreakdownLabel(
      living: category.livingSum,
      special: category.specialSum,
    );

    return AppInkWell(
      borderRadius: BorderRadius.zero,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => YearlyCategoryExpenseListPage(
              period: period,
              bigCategoryName: category.bigCategoryName,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          children: [
            ExpenseCategoryIcon(
              resourcePath: category.iconPath,
              colorCode: category.colorCode,
              size: 22,
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
                          category.bigCategoryName,
                          style: AppTextStyles.listTilePrimaryTitle,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        yenmarkFormattedPriceGetter(category.sum),
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
                  ExpenseRatioBar(
                    ratio: livingRatio,
                    colorCode: category.colorCode,
                    secondaryRatio: specialRatio,
                  ),
                  if (breakdownLabel != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        breakdownLabel,
                        style: AppTextStyles.budgetFixedCostForecastLabel,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            // タップ可能であることを示すシェブロン（収入一覧のカテゴリー行と共通の語彙）
            const SizedBox(width: AppSpacing.sm),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: context.colors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

/// 構成比バー（高さ6・カテゴリー色）。収入一覧のカテゴリー行でも使う
///
/// [secondaryRatio] を渡すと、実色の右に同色40%の半透明セグメントを重ねて
/// 生活収支/特別枠の2トーン分割を表現する（支出一覧のカテゴリー行）。
class ExpenseRatioBar extends StatelessWidget {
  const ExpenseRatioBar({
    super.key,
    required this.ratio,
    required this.colorCode,
    this.secondaryRatio = 0,
  });

  final double ratio;
  final String colorCode;

  /// 半透明セグメント（特別枠）の構成比。0なら実色のみ
  final double secondaryRatio;

  @override
  Widget build(BuildContext context) {
    final color = ColorCode.toColor(colorCode);
    final primary = ratio.clamp(0.0, 1.0);
    final total = (ratio + secondaryRatio).clamp(0.0, 1.0);

    return SizedBox(
      height: 6,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            Container(color: context.colors.fillSecondary),
            // 半透明（特別枠）は実色の下に全長で敷き、上に実色（生活）を重ねる
            if (secondaryRatio > 0)
              FractionallySizedBox(
                widthFactor: total,
                // heightFactor未指定だと子の高さが0になり塗りが見えない
                heightFactor: 1,
                child: ColoredBox(color: color.withValues(alpha: 0.4)),
              ),
            FractionallySizedBox(
              widthFactor: primary,
              heightFactor: 1,
              child: ColoredBox(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
