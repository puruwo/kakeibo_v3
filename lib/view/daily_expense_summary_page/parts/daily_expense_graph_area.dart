import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/view/component/card_container.dart';

/// カテゴリー別支出サマリー
class CategorySummary {
  final String categoryName;
  final String iconPath;
  final String colorCode;
  final int totalAmount;

  CategorySummary({
    required this.categoryName,
    required this.iconPath,
    required this.colorCode,
    required this.totalAmount,
  });
}

/// 日別支出グラフエリア
/// IncomeGraphAreaと同様のUIで、総支出とカテゴリー別支出を表示
class DailyExpenseGraphArea extends StatelessWidget {
  const DailyExpenseGraphArea({
    super.key,
    required this.totalExpense,
    required this.categorySummaries,
  });

  final int totalExpense;
  final List<CategorySummary> categorySummaries;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    if (categorySummaries.isEmpty) {
      return CardContainer(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            '支出データがありません',
            style: YearlyIncomeListStyles.noDataMessage,
          ),
        ),
      );
    }

    return CardContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 総支出ヘッダー
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('総支出', style: AppTextStyles.appCardTitleLabel),
              Row(
                children: [
                  Text('${formatter.format(totalExpense)} ',
                      style: AppTextStyles.appCardPriceLabel),
                  Text('円', style: AppTextStyles.appCardPriceUnit),
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
          categorySummaries.length == 1
              // カテゴリーが1つの場合は円グラフを表示せずカテゴリー一覧のみ
              ? _buildCategoryList(formatter)
              // カテゴリーが複数の場合は円グラフとカテゴリー一覧を横並び
              : Row(
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
                          sections: categorySummaries.map((category) {
                            return PieChartSectionData(
                              color: MyColors()
                                  .getColorFromHex(category.colorCode),
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
                    // カテゴリー一覧
                    Flexible(child: _buildCategoryList(formatter)),
                  ],
                ),
        ],
      ),
    );
  }

  /// カテゴリー一覧ウィジェット
  Widget _buildCategoryList(NumberFormat formatter) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: categorySummaries.map((category) {
        // カテゴリー別の支出金額
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // アイコン
              SvgPicture.asset(
                category.iconPath,
                colorFilter: ColorFilter.mode(
                    MyColors().getColorFromHex(category.colorCode),
                    BlendMode.srcIn),
                semanticsLabel: 'categoryIcon',
                width: 25,
                height: 25,
              ),
              const SizedBox(width: 4),
              // カテゴリー名
              Expanded(
                child: Text(category.categoryName,
                    style: AppTextStyles.appCardSecondaryTitleLabel),
              ),
              const SizedBox(width: 8),
              // 金額
              Text('${formatter.format(category.totalAmount)} ',
                  style: AppTextStyles.appCardSecondaryPriceLabel),
              // 円
              Text('円', style: AppTextStyles.appCardSecondaryPriceUnit),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// ExpenseHistoryTileValueのリストからCategorySummaryリストを生成
  static List<CategorySummary> createCategorySummaries(
      List<ExpenseHistoryTileValue> expenses) {
    final Map<String, CategorySummary> grouped = {};

    for (final expense in expenses) {
      final key = expense.bigCategoryName;
      if (grouped.containsKey(key)) {
        grouped[key] = CategorySummary(
          categoryName: expense.bigCategoryName,
          iconPath: expense.iconPath,
          colorCode: expense.colorCode,
          totalAmount: grouped[key]!.totalAmount + expense.price,
        );
      } else {
        grouped[key] = CategorySummary(
          categoryName: expense.bigCategoryName,
          iconPath: expense.iconPath,
          colorCode: expense.colorCode,
          totalAmount: expense.price,
        );
      }
    }

    // 金額の降順でソート
    final summaries = grouped.values.toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return summaries;
  }
}
