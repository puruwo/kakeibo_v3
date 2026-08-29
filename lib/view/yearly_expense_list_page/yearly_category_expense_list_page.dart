import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/expense_history/yearly_expense_list_usecase.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/expense_category_icon.dart';
import 'package:kakeibo/view/component/expense_history_list_tile.dart';
import 'package:kakeibo/view/component/month_accordion_section.dart';
import 'package:kakeibo/view/yearly_expense_list_page/expense_month_group.dart';

/// カテゴリー別の支出明細画面（案件 UIデザイン改修 §6）
///
/// 支出一覧のカテゴリー行タップで開く。ヘッダーにカテゴリーアイコン＋名称、
/// 上部にそのカテゴリーの合計サマリー、明細は月毎のアコーディオン
/// （月ラベル・件数・月計のヘッダー行をタップで開閉。初期は全月閉じた状態）で表示する。
class YearlyCategoryExpenseListPage extends ConsumerStatefulWidget {
  const YearlyCategoryExpenseListPage({
    super.key,
    required this.period,
    required this.bigCategoryName,
  });

  final PeriodValue period;
  final String bigCategoryName;

  @override
  ConsumerState<YearlyCategoryExpenseListPage> createState() =>
      _YearlyCategoryExpenseListPageState();
}

class _YearlyCategoryExpenseListPageState
    extends ConsumerState<YearlyCategoryExpenseListPage> {
  /// 開いている月のラベル集合。初期表示は全月閉じた状態
  final Set<String> _expandedLabels = {};

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;
    final valueAsync = ref.watch(
      yearlyExpenseListNotifierProvider(widget.period),
    );

    // 編集・削除で再集計された最新の内訳から自カテゴリーを引き直す
    final category = valueAsync.valueOrNull?.categories
        .where((c) => c.bigCategoryName == widget.bigCategoryName)
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
            Text(widget.bigCategoryName, style: AppTextStyles.pageHeaderText),
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
            periodStartYear: widget.period.startDatetime.year,
          );
          // 編集・削除の再集計で消えた月のラベルを掃除する
          final labels = {for (final g in groups) g.label};
          _expandedLabels.removeWhere((label) => !labels.contains(label));

          final monthCount = expensePeriodMonthCount(widget.period);
          final monthlyAverage = (category.sum / monthCount).round();

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
                  _CategorySummaryHeader(
                    category: category,
                    monthlyAverage: monthlyAverage,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (final group in groups)
                    MonthAccordionSection(
                      label: group.label,
                      itemCount: group.rows.length,
                      totalLabel: yenmarkFormattedPriceGetter(group.total),
                      breakdownLabel: livingSpecialBreakdownLabel(
                        living: group.livingTotal,
                        special: group.specialTotal,
                      ),
                      isExpanded: _expandedLabels.contains(group.label),
                      onToggle: () {
                        setState(() {
                          if (!_expandedLabels.remove(group.label)) {
                            _expandedLabels.add(group.label);
                          }
                        });
                      },
                      children: [
                        for (final row in group.rows)
                          ExpenseHistoryListTile(
                            value: row,
                            showsSpecialChip: true,
                          ),
                      ],
                    ),
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

/// カテゴリーの合計サマリー（合計・月平均・生活/特別の内訳）
///
/// カード面にすると展開後の明細タイルと区別がつかないため、
/// 面を持たないヘッダーとして地の上に直接置く（レビュー指摘 2026-08-25）。
/// 収入カテゴリー明細と同じ1行構成に揃え、構成比バー・総支出比は置かない
/// （ユーザー指定 2026-08-29）
class _CategorySummaryHeader extends StatelessWidget {
  const _CategorySummaryHeader({
    required this.category,
    required this.monthlyAverage,
  });

  final YearlyExpenseCategorySummary category;
  final int monthlyAverage;

  @override
  Widget build(BuildContext context) {
    final breakdownLabel = livingSpecialBreakdownLabel(
      living: category.livingSum,
      special: category.specialSum,
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
              Text('合計', style: AppTextStyles.appCardTitleLabel),
              const Spacer(),
              Text(
                yenmarkFormattedPriceGetter(category.sum),
                style: AppTextStyles.appCardPriceLabel,
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

