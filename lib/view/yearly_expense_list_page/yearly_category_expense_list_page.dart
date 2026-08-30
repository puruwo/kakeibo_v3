import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/expense_history/yearly_expense_list_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/period_month_count.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/expense_category_icon.dart';
import 'package:kakeibo/view/component/expense_history_list_tile.dart';
import 'package:kakeibo/view/component/month_accordion_section.dart';
import 'package:kakeibo/view/component/summary_band_card.dart';
import 'package:kakeibo/view/yearly_expense_list_page/expense_month_group.dart';

/// カテゴリー別の支出明細画面（案件 UIデザイン改修 §6）
///
/// 支出一覧のカテゴリー行タップで開く。ヘッダーにカテゴリーアイコン＋名称、
/// 上部に帯付きカード（帯=合計、本文=月平均）、明細は月毎のアコーディオン
/// （初期は全月閉じた状態）で表示する。
///
/// 支出一覧の絞り込み（[filter]）を引き継ぐ:
/// - 全体: 月内に生活収支と特別枠の両方があれば小見出しで分けて並べる
/// - 生活収支/特別枠: その枠の明細だけを表示し、帯の右端に状態ピルを出す
class YearlyCategoryExpenseListPage extends ConsumerStatefulWidget {
  const YearlyCategoryExpenseListPage({
    super.key,
    required this.period,
    required this.bigCategoryId,
    required this.bigCategoryName,
    this.filter = ExpenseAccountFilter.all,
  });

  final PeriodValue period;

  /// 大カテゴリーID（集計・絞り込みのキー）
  final int bigCategoryId;

  /// 大カテゴリー名（AppBarの表示用。記録が消えた後も名前を出せるよう別に持つ）
  final String bigCategoryName;
  final ExpenseAccountFilter filter;

  @override
  ConsumerState<YearlyCategoryExpenseListPage> createState() =>
      _YearlyCategoryExpenseListPageState();
}

class _YearlyCategoryExpenseListPageState
    extends ConsumerState<YearlyCategoryExpenseListPage> {
  /// 開いている月のラベル集合。初期表示は全月閉じた状態
  final Set<String> _expandedLabels = {};

  // 絞り込み結果のメモ。アコーディオン開閉の再buildで年間全件を再集計しないよう、
  // ユースケースの値が差し替わったときだけ引き直す
  YearlyExpenseListValue? _memoSource;
  YearlyExpenseListValue? _memoFiltered;

  YearlyExpenseListValue _filtered(YearlyExpenseListValue value) {
    if (!identical(_memoSource, value)) {
      _memoSource = value;
      _memoFiltered = value.filteredBy(widget.filter);
    }
    return _memoFiltered!;
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;
    final valueAsync = ref.watch(
      yearlyExpenseListNotifierProvider(widget.period),
    );

    // 編集・削除で再集計された最新の内訳から自カテゴリーを引き直す
    // （絞り込み後の値から引くので、合計・明細とも選択中の枠に揃う）
    final value = valueAsync.valueOrNull;
    final category = value == null
        ? null
        : _filtered(value).categories
              .where((c) => c.bigCategoryId == widget.bigCategoryId)
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
            // 全件削除された等でこのカテゴリーの記録が無くなった場合。
            // 絞り込み中は「他の枠には記録が残っているかもしれない」ことが伝わる文言にする
            final message = widget.filter == ExpenseAccountFilter.all
                ? '記録がまだありません'
                : '${widget.filter.label}の記録はありません';
            return Center(
              child: Text(message, style: AppTextStyles.listEmptyMessage),
            );
          }

          final groups = ExpenseMonthGroup.groupByMonth(
            category.rows,
            periodStartYear: widget.period.startDatetime.year,
          );
          // 編集・削除の再集計で消えた月のラベルを掃除する
          final labels = {for (final g in groups) g.label};
          _expandedLabels.removeWhere((label) => !labels.contains(label));

          // 月平均は年度内の経過月数で割る（12固定にしない）
          final today = ref.read(systemDatetimeNotifierProvider);
          final monthCount = elapsedPeriodMonthCount(widget.period, today);
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
                  _CategorySummaryCard(
                    totalLabel: yenmarkFormattedPriceGetter(category.sum),
                    monthlyAverageLabel: yenmarkFormattedPriceGetter(
                      monthlyAverage,
                    ),
                    filter: widget.filter,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (final group in groups)
                    MonthAccordionSection(
                      label: group.label,
                      itemCount: group.rows.length,
                      totalLabel: yenmarkFormattedPriceGetter(group.total),
                      isExpanded: _expandedLabels.contains(group.label),
                      onToggle: () {
                        setState(() {
                          if (!_expandedLabels.remove(group.label)) {
                            _expandedLabels.add(group.label);
                          }
                        });
                      },
                      children: _buildMonthChildren(group.rows),
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

  /// 月内の明細タイル。全体表示で生活収支と特別枠が混在する月だけ小見出しで分ける
  /// （片方しか無い月は見出しを省略。ユーザー指定 2026-08-29）
  List<Widget> _buildMonthChildren(List<ExpenseHistoryTileValue> rows) {
    final living = rows.where(ExpenseAccountFilter.living.includes).toList();
    final special = rows.where(ExpenseAccountFilter.special.includes).toList();
    final isMixed =
        widget.filter == ExpenseAccountFilter.all &&
        living.isNotEmpty &&
        special.isNotEmpty;

    if (!isMixed) {
      return [for (final row in rows) ExpenseHistoryListTile(value: row)];
    }
    return [
      _AccountGroupHeader(filter: ExpenseAccountFilter.living, rows: living),
      for (final row in living) ExpenseHistoryListTile(value: row),
      _AccountGroupHeader(filter: ExpenseAccountFilter.special, rows: special),
      for (final row in special) ExpenseHistoryListTile(value: row),
    ];
  }
}

/// 合計サマリー（帯=合計〔絞り込み中は状態ピル付き〕、本文=月平均）
class _CategorySummaryCard extends StatelessWidget {
  const _CategorySummaryCard({
    required this.totalLabel,
    required this.monthlyAverageLabel,
    required this.filter,
  });

  final String totalLabel;
  final String monthlyAverageLabel;
  final ExpenseAccountFilter filter;

  @override
  Widget build(BuildContext context) {
    return SummaryBandCard(
      tintColor: context.colors.expense,
      band: SummaryBandRow(
        label: '合計',
        priceLabel: totalLabel,
        trailing: filter == ExpenseAccountFilter.all
            ? null
            : _FilterStatusPill(label: filter.label),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '月平均',
                  style: AppTextStyles.appCardTertiaryTitleLabel,
                ),
              ),
              Text(
                monthlyAverageLabel,
                style: AppTextStyles.appCardSecondaryPriceLabel,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 支出一覧の絞り込みを引き継いでいることを示すピル（帯の右端）
class _FilterStatusPill extends StatelessWidget {
  const _FilterStatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: context.colors.surfaceBorder, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.filter_alt_outlined,
            size: 12,
            color: context.colors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.listTileTertiaryTitle),
        ],
      ),
    );
  }
}

/// 月内で生活収支/特別枠を分ける小見出し（名称・件数・小計）
class _AccountGroupHeader extends StatelessWidget {
  const _AccountGroupHeader({required this.filter, required this.rows});

  final ExpenseAccountFilter filter;
  final List<ExpenseHistoryTileValue> rows;

  @override
  Widget build(BuildContext context) {
    final sum = rows.fold<int>(0, (total, row) => total + row.price);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xs,
        0,
        AppSpacing.xs,
        AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(filter.label, style: AppTextStyles.listCardSectionTitle),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              '${rows.length}件',
              style: AppTextStyles.numericCaption,
            ),
          ),
          Text(
            yenmarkFormattedPriceGetter(sum),
            style: AppTextStyles.listCardSecondaryNumeric,
          ),
        ],
      ),
    );
  }
}
