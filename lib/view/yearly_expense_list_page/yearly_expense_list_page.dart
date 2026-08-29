import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/expense_history/yearly_expense_list_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/category_ratio_row.dart';
import 'package:kakeibo/view/component/expense_category_icon.dart';
import 'package:kakeibo/view/component/filter_chip_row.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/summary_band_card.dart';
import 'package:kakeibo/view/yearly_expense_list_page/yearly_category_expense_list_page.dart';

/// 支出一覧画面（案件 UIデザイン改修 §6・本実装）
///
/// トップ「年間収支」カードの総支出から遷移する、年度の支出を俯瞰する画面。
/// 帯付きカード1枚に総支出・会計種別の絞り込みチップ（全体/生活収支/特別枠）・
/// カテゴリー別内訳を収める。絞り込みは総支出と構成比の分母にも効き、
/// カテゴリー行のタップ先（YearlyCategoryExpenseListPage）にも引き継ぐ。
class YearlyExpenseListPage extends ConsumerStatefulWidget {
  const YearlyExpenseListPage({super.key, required this.period});

  final PeriodValue period;

  @override
  ConsumerState<YearlyExpenseListPage> createState() =>
      _YearlyExpenseListPageState();
}

class _YearlyExpenseListPageState extends ConsumerState<YearlyExpenseListPage> {
  ExpenseAccountFilter _filter = ExpenseAccountFilter.all;

  // 絞り込み結果のメモ。ユースケースの値か絞り込みが変わったときだけ再集計する
  YearlyExpenseListValue? _memoSource;
  ExpenseAccountFilter? _memoFilter;
  YearlyExpenseListValue? _memoFiltered;

  YearlyExpenseListValue _filtered(YearlyExpenseListValue value) {
    if (!identical(_memoSource, value) || _memoFilter != _filter) {
      _memoSource = value;
      _memoFilter = _filter;
      _memoFiltered = value.filteredBy(_filter);
    }
    return _memoFiltered!;
  }

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

              final filtered = _filtered(value);

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    topInset + AppSpacing.lg,
                    AppSpacing.lg,
                    // グロナビに隠れないよう、末尾はグロナビ分の余白を必ず確保する
                    context.bottomNavClearance + AppSpacing.xl,
                  ),
                  child: SummaryBandCard(
                    tintColor: context.colors.expense,
                    band: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SummaryBandRow(
                          label: _totalLabelOf(_filter),
                          priceLabel: yenmarkFormattedPriceGetter(
                            filtered.totalExpense,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm + 2),
                        FilterChipRow<ExpenseAccountFilter>(
                          options: ExpenseAccountFilter.values,
                          selected: _filter,
                          labelOf: (filter) => filter.label,
                          onSelected: (filter) =>
                              setState(() => _filter = filter),
                        ),
                      ],
                    ),
                    children: [
                      if (filtered.categories.isEmpty)
                        // 絞り込み先に記録が無い（チップを残して切り替えられるようにする）
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Center(
                            child: Text(
                              '${_filter.label}の記録はありません',
                              style: AppTextStyles.listEmptyMessage,
                            ),
                          ),
                        )
                      else ...[
                        const SizedBox(height: AppSpacing.xs),
                        for (var i = 0; i < filtered.categories.length; i++) ...[
                          if (i != 0) const CategoryRowDivider(),
                          _CategoryRow(
                            category: filtered.categories[i],
                            totalExpense: filtered.totalExpense,
                            period: widget.period,
                            filter: _filter,
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xs),
                      ],
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

  /// 帯のラベル。絞り込み中はどの枠の合計かを示す
  static String _totalLabelOf(ExpenseAccountFilter filter) {
    switch (filter) {
      case ExpenseAccountFilter.all:
        return '総支出';
      case ExpenseAccountFilter.living:
      case ExpenseAccountFilter.special:
        return '${filter.label}の支出';
    }
  }
}

/// カテゴリー1行。タップで明細へ（絞り込みを引き継ぐ）
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.category,
    required this.totalExpense,
    required this.period,
    required this.filter,
  });

  final YearlyExpenseCategorySummary category;
  final int totalExpense;
  final PeriodValue period;
  final ExpenseAccountFilter filter;

  @override
  Widget build(BuildContext context) {
    return CategoryRatioRow(
      icon: ExpenseCategoryIcon(
        resourcePath: category.iconPath,
        colorCode: category.colorCode,
        size: 25,
      ),
      name: category.bigCategoryName,
      priceLabel: yenmarkFormattedPriceGetter(category.sum),
      ratio: category.ratioOf(totalExpense),
      colorCode: category.colorCode,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => YearlyCategoryExpenseListPage(
              period: period,
              bigCategoryId: category.bigCategoryId,
              bigCategoryName: category.bigCategoryName,
              filter: filter,
            ),
          ),
        );
      },
    );
  }
}
