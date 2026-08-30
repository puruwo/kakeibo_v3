import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/yearly_income_list/yearly_income_list_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/yearly_income_list_value/income_category_summary_value.dart';
import 'package:kakeibo/domain_service/system_datetime/system_datetime.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/month_accordion_section.dart';
import 'package:kakeibo/view/component/summary_band_card.dart';
import 'package:kakeibo/util/period_month_count.dart';
import 'package:kakeibo/view/yearly_income_list_page/yearly_income_card.dart';

/// 大カテゴリー別の収入明細画面
///
/// 収入一覧のカテゴリー行タップで開く。ヘッダーにカテゴリーアイコン＋名称、
/// 上部に帯付きカード（帯=合計＋月平均、本文=小カテゴリー別の内訳）、
/// 明細は月毎のアコーディオンで表示する。**遷移時は全月展開した状態**で開く
/// （支出カテゴリー明細の初期全閉とは異なる。ユーザー指定 2026-08-29）。
class YearlyCategoryIncomeListPage extends ConsumerStatefulWidget {
  const YearlyCategoryIncomeListPage({
    super.key,
    required this.period,
    required this.bigCategoryId,
    required this.categoryName,
  });

  final PeriodValue period;

  /// 大カテゴリーID（集計・絞り込みのキー）
  final int bigCategoryId;

  /// 大カテゴリー名（AppBarの表示用。記録が消えた後も名前を出せるよう別に持つ）
  final String categoryName;

  @override
  ConsumerState<YearlyCategoryIncomeListPage> createState() =>
      _YearlyCategoryIncomeListPageState();
}

class _YearlyCategoryIncomeListPageState
    extends ConsumerState<YearlyCategoryIncomeListPage> {
  /// 開いている月のラベル集合。初期表示は全月展開した状態にする
  final Set<String> _expandedLabels = {};
  bool _expandedInitialized = false;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top + kToolbarHeight;
    final valueAsync = ref.watch(
      yearlyIncomeListNotifierProvider(widget.period),
    );

    // 編集・削除で再集計された最新の内訳から自カテゴリーを引き直す
    final category = valueAsync.valueOrNull?.categorySummaries
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
              SvgPicture.asset(
                category.iconPath,
                colorFilter: ColorFilter.mode(
                  ColorCode.toColor(category.colorCode),
                  BlendMode.srcIn,
                ),
                semanticsLabel: 'categoryIcon',
                width: 20,
                height: 20,
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(widget.categoryName, style: AppTextStyles.pageHeaderText),
          ],
        ),
      ),
      body: valueAsync.when(
        data: (value) {
          // 自カテゴリーの明細だけを月グループから抽出する（空になった月は除く）
          final groups = [
            for (final group in value.monthlyGroups)
              (
                label: group.monthLabel,
                incomes: group.incomes
                    .where(
                      (income) => income.bigCategoryId == widget.bigCategoryId,
                    )
                    .toList(),
              ),
          ].where((group) => group.incomes.isNotEmpty).toList();

          if (category == null || groups.isEmpty) {
            // 全件削除された等でこのカテゴリーの記録が無くなった場合
            return Center(
              child: Text('記録がまだありません', style: AppTextStyles.listEmptyMessage),
            );
          }

          final labels = {for (final g in groups) g.label};
          if (!_expandedInitialized) {
            // 遷移時は全月展開した状態で開く
            _expandedLabels.addAll(labels);
            _expandedInitialized = true;
          }
          // 編集・削除の再集計で消えた月のラベルを掃除する
          _expandedLabels.removeWhere((label) => !labels.contains(label));

          // 月平均は年度内の経過月数で割る（12固定にしない）
          final today = ref.read(systemDatetimeNotifierProvider);
          final monthCount = elapsedPeriodMonthCount(widget.period, today);
          final monthlyAverage = (category.totalAmount / monthCount).round();

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
                    category: category,
                    monthlyAverage: monthlyAverage,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  for (final group in groups)
                    MonthAccordionSection(
                      label: group.label,
                      itemCount: group.incomes.length,
                      totalLabel: yenmarkFormattedPriceGetter(
                        group.incomes.fold<int>(
                          0,
                          (sum, income) => sum + income.price,
                        ),
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
                        for (final income in group.incomes)
                          YearlyIncomeCard(value: income),
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

/// 合計サマリー（帯=合計＋月平均、本文=小カテゴリー別の内訳。バーは置かない）
class _CategorySummaryCard extends StatelessWidget {
  const _CategorySummaryCard({
    required this.category,
    required this.monthlyAverage,
  });

  final IncomeCategorySummaryValue category;
  final int monthlyAverage;

  @override
  Widget build(BuildContext context) {
    return SummaryBandCard(
      tintColor: context.colors.income,
      band: SummaryBandRow(
        label: '合計',
        priceLabel: yenmarkFormattedPriceGetter(category.totalAmount),
        trailing: Text(
          '月平均 ${yenmarkFormattedPriceGetter(monthlyAverage)}',
          style: AppTextStyles.numericCaption,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md - 2,
          ),
          child: Column(
            children: [
              for (final small in category.smallCategories)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          small.smallCategoryName,
                          style: AppTextStyles.appCardTertiaryTitleLabel,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${small.percentage.toStringAsFixed(1)}%',
                        style: AppTextStyles.numericCaption,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        yenmarkFormattedPriceGetter(small.totalAmount),
                        style: AppTextStyles.appCardTertiaryPriceLabel,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
