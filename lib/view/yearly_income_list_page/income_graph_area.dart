import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/application/yearly_income_list/yearly_income_list_usecase.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/card_container.dart';

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
    // 円グラフエリア
    return ref
        .watch(yearlyIncomeListNotifierProvider(widget.period))
        .when(
          data: (incomeDatas) {
            if (incomeDatas.monthlyGroups.isEmpty) {
              return CardContainer(
                constraints: const BoxConstraints(maxHeight: 200),
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: Text(
                    '収入データがありません',
                    style: AppTextStyles.listEmptyMessage,
                  ),
                ),
              );
            }

            return CardContainer(
              constraints: const BoxConstraints(maxHeight: 200),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 総収入ヘッダー
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('総収入', style: AppTextStyles.appCardTitleLabel),
                      Text(
                        yenmarkFormattedPriceGetter(incomeDatas.totalIncome),
                        style: AppTextStyles.appCardPriceLabel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(height: 0, thickness: 1),
                  const SizedBox(height: 16),
                  // 円グラフとカテゴリー一覧
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 円グラフ
                        SizedBox(
                          width: 100,
                          height: 100,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              startDegreeOffset: 270,
                              centerSpaceRadius: 25,
                              sections: incomeDatas.categorySummaries.map((
                                category,
                              ) {
                                return PieChartSectionData(
                                  color: ColorCode.toColor(
                                    category.colorCode,
                                  ),
                                  value: category.totalAmount.toDouble(),
                                  titlePositionPercentageOffset: 0.3,
                                  title: category.categoryName,
                                  titleStyle: AppTextStyles.appCardGraphLabel,
                                  radius: 25,
                                );
                              }).toList(),
                              pieTouchData: PieTouchData(enabled: false),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        // カテゴリー一覧（スクロール可能）
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              // カテゴリー1つあたりの高さを計算（アイコン28 + パディング8 = 36）
                              const categoryHeight = 36.0;
                              final totalCategoriesHeight =
                                  incomeDatas.categorySummaries.length *
                                  categoryHeight;

                              // スクロールが必要かどうかを判定
                              final needsScroll =
                                  totalCategoriesHeight > constraints.maxHeight;

                              return SingleChildScrollView(
                                physics: needsScroll
                                    ? const AlwaysScrollableScrollPhysics()
                                    : const NeverScrollableScrollPhysics(),
                                child: Column(
                                  children: incomeDatas.categorySummaries.map((
                                    category,
                                  ) {
                                    // カテゴリー別の支出金額
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          // アイコン
                                          SvgPicture.asset(
                                            category.iconPath,
                                            colorFilter: ColorFilter.mode(
                                              ColorCode.toColor(
                                                category.colorCode,
                                              ),
                                              BlendMode.srcIn,
                                            ),
                                            semanticsLabel: 'categoryIcon',
                                            width: 25,
                                            height: 25,
                                          ),
                                          const SizedBox(width: 4),
                                          // カテゴリー名
                                          Expanded(
                                            child: Text(
                                              category.categoryName,
                                              style: AppTextStyles
                                                  .listTilePrimaryTitle,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // 金額
                                          Text(
                                            yenmarkFormattedPriceGetter(category.totalAmount),
                                            style: AppTextStyles
                                                .appCardSecondaryPriceLabel,
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => Container(
            height: 200,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: context.colors.surfaceElevated2,
              border: Border.all(color: context.colors.surfaceBorder, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Container(
            height: 200,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
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
