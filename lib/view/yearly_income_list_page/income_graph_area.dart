import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/application/yearly_income_list/yearly_income_list_usecase.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';

class IncomeGraphArea extends ConsumerStatefulWidget {
  const IncomeGraphArea({super.key, required this.dateScope});

  final DateScopeEntity dateScope;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomeGraphAreaState();
}

class _IncomeGraphAreaState extends ConsumerState<IncomeGraphArea> {
  @override
  Widget build(BuildContext context) {
    // 円グラフエリア
    return ref.watch(yearlyIncomeListNotifierProvider(widget.dateScope)).when(
          data: (incomeDatas) {
            if (incomeDatas.monthlyGroups.isEmpty) {
              return Container(
                constraints: const BoxConstraints(maxHeight: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: MyColors.quarternarySystemfill,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '収入データがありません',
                    // TODO: スタイルをまとめる
                    style: GoogleFonts.notoSans(
                      fontSize: 14,
                      color: MyColors.secondaryLabel,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              );
            }

            final formatter = NumberFormat('#,###');

            return Container(
              constraints: const BoxConstraints(maxHeight: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MyColors.quarternarySystemfill,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 総収入ヘッダー
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('総収入', style: MyFonts.appCardTitleLabel),
                      Row(
                        children: [
                          Text('${formatter.format(incomeDatas.totalIncome)} ',
                              style: MyFonts.appCardPriceLabel),
                          Text('円', style: MyFonts.appCardPriceUnit),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(
                    height: 0,
                    thickness: 1,
                  ),
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
                              sections:
                                  incomeDatas.categorySummaries.map((category) {
                                return PieChartSectionData(
                                  color: MyColors()
                                      .getColorFromHex(category.colorCode),
                                  value: category.totalAmount.toDouble(),
                                  titlePositionPercentageOffset: 0.3,
                                  title: category.categoryName,
                                  titleStyle: MyFonts.appCardGraphLabel,
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
                                  children: incomeDatas.categorySummaries
                                      .map((category) {
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
                                                MyColors().getColorFromHex(
                                                    category.colorCode),
                                                BlendMode.srcIn),
                                            semanticsLabel: 'categoryIcon',
                                            width: 25,
                                            height: 25,
                                          ),
                                          const SizedBox(width: 4),
                                          // カテゴリー名
                                          Expanded(
                                            child: Text(
                                              category.categoryName,
                                              style: MyFonts.appCardSecondaryTitleLabel
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // 金額
                                          Text(
                                            '${formatter.format(category.totalAmount)} ',
                                            style: MyFonts.appCardSecondaryPriceLabel
                                          ),
                                          // 円
                                          Text(
                                            '円',
                                            style: MyFonts.appCardSecondaryPriceUnit
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
              color: MyColors.tertiarySystemBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => Container(
            height: 200,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            decoration: BoxDecoration(
              color: MyColors.tertiarySystemBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'エラーが発生しました',
                style: GoogleFonts.notoSans(
                  fontSize: 14,
                  color: MyColors.red,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        );
  }
}
