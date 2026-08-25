import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/expense_history/yearly_expense_list_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/expense_category_icon.dart';
import 'package:kakeibo/view/component/expense_history_list_tile.dart';
import 'package:kakeibo/view/yearly_expense_list_page/expense_month_group.dart';
import 'package:kakeibo/view/yearly_expense_list_page/yearly_expense_list_page.dart';

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
          final ratio = category.ratioOf(value.totalExpense);

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
                    ratio: ratio,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (final group in groups)
                    _MonthAccordionSection(
                      group: group,
                      isExpanded: _expandedLabels.contains(group.label),
                      onToggle: () {
                        setState(() {
                          if (!_expandedLabels.remove(group.label)) {
                            _expandedLabels.add(group.label);
                          }
                        });
                      },
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

/// カテゴリーの合計サマリー（合計・総支出比・月平均・構成比バー）
///
/// カード面にすると展開後の明細タイルと区別がつかないため、
/// 面を持たないヘッダーとして地の上に直接置く（レビュー指摘 2026-08-25）
class _CategorySummaryHeader extends StatelessWidget {
  const _CategorySummaryHeader({
    required this.category,
    required this.monthlyAverage,
    required this.ratio,
  });

  final YearlyExpenseCategorySummary category;
  final int monthlyAverage;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text('合計', style: AppTextStyles.appCardTitleLabel),
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
                  style: AppTextStyles.budgetFixedCostForecastLabel,
                ),
              ),
              Text(
                '月平均 ${yenmarkFormattedPriceGetter(monthlyAverage)}',
                style: AppTextStyles.budgetFixedCostForecastLabel,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ExpenseRatioBar(ratio: ratio, colorCode: category.colorCode),
        ],
      ),
    );
  }
}

/// 月ごとのアコーディオンセクション
///
/// ヘッダー行に月ラベル・件数・月計を表示し、タップで明細タイルを開閉する。
class _MonthAccordionSection extends StatelessWidget {
  const _MonthAccordionSection({
    required this.group,
    required this.isExpanded,
    required this.onToggle,
  });

  final ExpenseMonthGroup group;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        children: [
          // 月ヘッダー行（タイルと同じ面の語彙で、タップで開閉）
          AppInkWell(
            borderRadius: appCardRadius,
            color: context.colors.fillQuaternary,
            border: Border.all(color: context.colors.surfaceBorder, width: 1),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Text(group.label, style: AppTextStyles.listTilePrimaryTitle),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      '${group.rows.length}件',
                      style: AppTextStyles.listCardSecondaryTitle,
                    ),
                  ),
                  Text(
                    yenmarkFormattedPriceGetter(group.total),
                    style: AppTextStyles.appCardSecondaryPriceLabel,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.expand_more_rounded,
                      size: 20,
                      color: context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 明細タイル（開閉アニメーション付き）
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: isExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.sm),
                    child: Column(
                      children: [
                        for (final row in group.rows)
                          ExpenseHistoryListTile(value: row),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
