import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/expense_history/yearly_expense_list_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/expense_category_icon.dart';
import 'package:kakeibo/view/yearly_expense_list_page/expense_month_group.dart';
import 'package:kakeibo/view/yearly_expense_list_page/yearly_expense_list_page.dart';

/// カテゴリー別の支出明細画面（案件 UIデザイン改修 §6）
///
/// 支出一覧のカテゴリー行タップで開く。ヘッダーにカテゴリーアイコン＋名称、
/// 上部にそのカテゴリーの合計カード、明細は月毎にグルーピングして
/// 共通の支出履歴タイル（ExpenseHistoryListTile）で表示する。
class YearlyCategoryExpenseListPage extends ConsumerWidget {
  const YearlyCategoryExpenseListPage({
    super.key,
    required this.period,
    required this.bigCategoryName,
  });

  final PeriodValue period;
  final String bigCategoryName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;
    final valueAsync = ref.watch(yearlyExpenseListNotifierProvider(period));

    // 編集・削除で再集計された最新の内訳から自カテゴリーを引き直す
    final category = valueAsync.valueOrNull?.categories
        .where((c) => c.bigCategoryName == bigCategoryName)
        .firstOrNull;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        flexibleSpace: const GlassAppBarBackground(),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.colors.text),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category != null) ...[
              ExpenseCategoryIcon(
                resourcePath: category.iconPath,
                colorCode: category.colorCode,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(bigCategoryName, style: AppTextStyles.pageHeaderText),
          ],
        ),
      ),
      body: valueAsync.when(
        data: (value) {
          if (category == null || category.rows.isEmpty) {
            // 全件削除された等でこのカテゴリーの記録が無くなった場合
            return Center(
              child: Text('記録がまだありません', style: AppTextStyles.listEmptyMessage),
            );
          }

          final groups = ExpenseMonthGroup.groupByMonth(
            category.rows,
            periodStartYear: period.startDatetime.year,
          );
          final monthCount = expensePeriodMonthCount(period);
          final monthlyAverage = (category.sum / monthCount).round();
          final ratio = category.ratioOf(value.totalExpense);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    topInset + AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: CardContainer(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '合計',
                                style: AppTextStyles.appCardTitleLabel,
                              ),
                            ),
                            Text(
                              yenmarkFormattedPriceGetter(category.sum),
                              style: AppTextStyles.appCardPriceLabel,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '総支出の ${(ratio * 100).toStringAsFixed(1)}%',
                                style:
                                    AppTextStyles.budgetFixedCostForecastLabel,
                              ),
                            ),
                            Text(
                              '月平均 ${yenmarkFormattedPriceGetter(monthlyAverage)}',
                              style: AppTextStyles.budgetFixedCostForecastLabel,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ExpenseRatioBar(
                          ratio: ratio,
                          colorCode: category.colorCode,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ...buildExpenseMonthSlivers(
                groups,
                monthHeaderBuilder: (group) => ExpenseMonthHeader(group: group),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: AppErrorState()),
      ),
    );
  }
}
