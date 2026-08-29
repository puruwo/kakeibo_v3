import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/yearly_income_list/yearly_income_list_usecase.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/month_accordion_section.dart';
import 'package:kakeibo/view/yearly_expense_list_page/expense_month_group.dart';
import 'package:kakeibo/view/yearly_income_list_page/yearly_income_card.dart';

/// カテゴリー別の収入明細画面
///
/// 収入一覧のカテゴリー行タップで開く。ヘッダーにカテゴリーアイコン＋名称、
/// 上部に合計と月平均のみのサマリー（面なし・構成比バーは置かない）、
/// 明細は月毎のアコーディオンで表示する。**遷移時は全月展開した状態**で開く
/// （支出カテゴリー明細の初期全閉とは異なる。ユーザー指定 2026-08-29）。
class YearlyCategoryIncomeListPage extends ConsumerStatefulWidget {
  const YearlyCategoryIncomeListPage({
    super.key,
    required this.period,
    required this.categoryName,
  });

  final PeriodValue period;
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
        .where((c) => c.categoryName == widget.categoryName)
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
                      (income) =>
                          income.smallCategoryName == widget.categoryName,
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

          final monthCount = expensePeriodMonthCount(widget.period);
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
                  // 合計サマリー（面なし・合計と月平均のみ）
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('合計', style: AppTextStyles.appCardTitleLabel),
                        const Spacer(),
                        Text(
                          yenmarkFormattedPriceGetter(category.totalAmount),
                          style: AppTextStyles.appCardPriceLabel,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '月平均 ${yenmarkFormattedPriceGetter(monthlyAverage)}',
                          style: AppTextStyles.budgetFixedCostForecastLabel,
                        ),
                      ],
                    ),
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
