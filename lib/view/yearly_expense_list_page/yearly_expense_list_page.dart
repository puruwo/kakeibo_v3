import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/expense_history/yearly_expense_list_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/app_segmented_control.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/expense_category_icon.dart';
import 'package:kakeibo/view/yearly_expense_list_page/expense_month_group.dart';
import 'package:kakeibo/view/yearly_expense_list_page/yearly_category_expense_list_page.dart';

/// 支出一覧画面（案件 UIデザイン改修 §6・本実装）
///
/// トップ「年間収支」カードの総支出から遷移する、年度の支出を俯瞰する画面。
/// 初期表示はカテゴリー別集計（使い道の俯瞰）。セグメントで月別の明細にも切り替えられる。
/// カテゴリー行のタップで月毎グルーピングの明細（YearlyCategoryExpenseListPage）へ。
class YearlyExpenseListPage extends ConsumerStatefulWidget {
  const YearlyExpenseListPage({super.key, required this.period});

  final PeriodValue period;

  @override
  ConsumerState<YearlyExpenseListPage> createState() =>
      _YearlyExpenseListPageState();
}

class _YearlyExpenseListPageState extends ConsumerState<YearlyExpenseListPage> {
  /// 0=カテゴリー別 / 1=月別
  int _segmentIndex = 0;

  /// 期間の月数（月平均の分母）
  int get _monthCount => expensePeriodMonthCount(widget.period);

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;

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
          .watch(yearlyExpenseListNotifierProvider(widget.period))
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

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        topInset + AppSpacing.lg,
                        AppSpacing.lg,
                        0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _TotalCard(
                            totalExpense: value.totalExpense,
                            monthCount: _monthCount,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppSegmentedControl(
                            labels: const ['カテゴリー別', '月別'],
                            selectedIndex: _segmentIndex,
                            onChanged: (index) =>
                                setState(() => _segmentIndex = index),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
                  if (_segmentIndex == 0)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: _CategoryBreakdownCard(
                          value: value,
                          period: widget.period,
                        ),
                      ),
                    )
                  else
                    ..._buildMonthlySlivers(value),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSpacing.xxl),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => const Center(child: AppErrorState()),
          ),
    );
  }

  /// 月別タブ: 月見出し（右端に月計）＋共通の支出履歴タイル
  List<Widget> _buildMonthlySlivers(YearlyExpenseListValue value) {
    final groups = ExpenseMonthGroup.groupByMonth(
      value.allRows,
      periodStartYear: widget.period.startDatetime.year,
    );
    return buildExpenseMonthSlivers(
      groups,
      monthHeaderBuilder: (group) => ExpenseMonthHeader(group: group),
    );
  }
}

/// 総支出の合計カード
class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.totalExpense, required this.monthCount});

  final int totalExpense;
  final int monthCount;

  @override
  Widget build(BuildContext context) {
    final monthlyAverage = (totalExpense / monthCount).round();

    return CardContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text('総支出', style: AppTextStyles.appCardTitleLabel),
              ),
              Text(
                yenmarkFormattedPriceGetter(totalExpense),
                style: AppTextStyles.appCardPriceLabel,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '月平均 ${yenmarkFormattedPriceGetter(monthlyAverage)}',
              style: AppTextStyles.budgetFixedCostForecastLabel,
            ),
          ),
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
                  ExpenseRatioBar(ratio: ratio, colorCode: category.colorCode),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 構成比バー（高さ6・カテゴリー色）。カテゴリー明細の合計カードでも使う
class ExpenseRatioBar extends StatelessWidget {
  const ExpenseRatioBar({
    super.key,
    required this.ratio,
    required this.colorCode,
  });

  final double ratio;
  final String colorCode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Stack(
          children: [
            Container(color: context.colors.fillSecondary),
            FractionallySizedBox(
              widthFactor: ratio.clamp(0.0, 1.0),
              // heightFactor未指定だと子の高さが0になり塗りが見えない
              heightFactor: 1,
              child: ColoredBox(color: ColorCode.toColor(colorCode)),
            ),
          ],
        ),
      ),
    );
  }
}

/// 月見出し（左: 月ラベル / 右: 月計）。カテゴリー明細でも使う
class ExpenseMonthHeader extends StatelessWidget {
  const ExpenseMonthHeader({super.key, required this.group});

  final ExpenseMonthGroup group;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(group.label, style: AppTextStyles.listCardSectionTitle),
        ),
        Text(
          yenmarkFormattedPriceGetter(group.total),
          style: AppTextStyles.listCardSectionTitle,
        ),
      ],
    );
  }
}
