import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';
import 'package:kakeibo/domain/ui_value/yearly_income_list_value/income_category_summary_value.dart';
import 'package:kakeibo/domain/ui_value/yearly_income_list_value/yearly_income_list_entity.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// 年間収入一覧を取得するユースケース

final yearlyIncomeListNotifierProvider = AsyncNotifierProvider.family<
    YearlyIncomeListUsecaseNotifier,
    YearlyIncomeListValue,
    DateScopeEntity>(
  YearlyIncomeListUsecaseNotifier.new,
);

class YearlyIncomeListUsecaseNotifier
    extends FamilyAsyncNotifier<YearlyIncomeListValue, DateScopeEntity> {
  late IncomeRepository _incomeRepo;
  late IncomeSmallCategoryRepository _incomeSmallCategoryRepo;
  late IncomeBigCategoryRepository _incomeBigCategoryRepo;

  @override
  Future<YearlyIncomeListValue> build(DateScopeEntity arg) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _incomeRepo = ref.read(incomeRepositoryProvider);
    _incomeSmallCategoryRepo = ref.read(incomeSmallCategoryRepositoryProvider);
    _incomeBigCategoryRepo = ref.read(incomeBigCategoryRepositoryProvider);

    // 年の期間で収入を取得
    final incomeList = await _incomeRepo.fetchWithoutCategory(
      period: arg.yearPeriod,
    );

    // 月ごとにグループ化するためのマップ
    final Map<String, List<IncomeHistoryTileValue>> monthlyMap = {};

    for (var income in incomeList) {
      // 日付をパース (YYYYMMdd形式)
      final dateStr = income.date;
      final year = dateStr.substring(0, 4);
      final month = dateStr.substring(4, 6);
      final day = dateStr.substring(6, 8);
      final date = DateTime(int.parse(year), int.parse(month), int.parse(day));

      // 月のキー (例: "2023年 12月")
      final monthKey = '${date.year}年 ${date.month}月';

      // カテゴリー情報を取得
      final category = await _incomeSmallCategoryRepo.fetchBySmallCategory(
          smallCategoryId: income.categoryId);

      // 大カテゴリー情報を取得
      final bigCategory = await _incomeBigCategoryRepo.fetchByBigCategory(
          bigCategoryId: category.bigCategoryKey);

      // IncomeHistoryTileValueを作成
      final tileValue = IncomeHistoryTileValue(
        id: income.id,
        date: date,
        price: income.price,
        paymentCategoryId: income.categoryId,
        memo: income.memo,
        smallCategoryName: category.smallCategoryName,
        bigCategoryName: bigCategory.name,
        colorCode: bigCategory.colorCode,
        iconPath: bigCategory.iconPath,
      );

      // 月ごとのマップに追加
      if (!monthlyMap.containsKey(monthKey)) {
        monthlyMap[monthKey] = [];
      }
      monthlyMap[monthKey]!.add(tileValue);
    }

    // 月ごとのグループを作成（新しい順にソート）
    final monthlyGroups = <MonthlyIncomeGroup>[];
    final sortedKeys = monthlyMap.keys.toList()
      ..sort((a, b) {
        // "2023年 12月" のような文字列から年月を抽出して比較
        final aYear = int.parse(a.split('年')[0]);
        final aMonth = int.parse(a.split('年 ')[1].split('月')[0]);
        final bYear = int.parse(b.split('年')[0]);
        final bMonth = int.parse(b.split('年 ')[1].split('月')[0]);

        // 新しい順（降順）
        if (aYear != bYear) {
          return bYear.compareTo(aYear);
        }
        return bMonth.compareTo(aMonth);
      });

    for (var monthKey in sortedKeys) {
      final incomes = monthlyMap[monthKey]!;
      // 各月内では日付の新しい順にソート
      incomes.sort((a, b) => b.date.compareTo(a.date));

      monthlyGroups.add(
        MonthlyIncomeGroup(
          monthLabel: monthKey,
          incomes: incomes,
        ),
      );
    }

    // カテゴリー別の集計を計算
    final Map<String, IncomeCategorySummaryValue> categoryMap = {};
    int totalIncome = 0;

    for (var group in monthlyGroups) {
      for (var income in group.incomes) {
        totalIncome += income.price;

        final categoryKey = income.bigCategoryName;
        if (categoryMap.containsKey(categoryKey)) {
          final existing = categoryMap[categoryKey]!;
          categoryMap[categoryKey] = existing.copyWith(
            totalAmount: existing.totalAmount + income.price,
          );
        } else {
          categoryMap[categoryKey] = IncomeCategorySummaryValue(
            categoryName: income.bigCategoryName,
            colorCode: income.colorCode,
            iconPath: income.iconPath,
            totalAmount: income.price,
            percentage: 0.0, // 後で計算
          );
        }
      }
    }

    // 割合を計算
    final categorySummaries = categoryMap.values.map((summary) {
      final percentage = totalIncome > 0
          ? (summary.totalAmount / totalIncome) * 100
          : 0.0;
      return summary.copyWith(percentage: percentage);
    }).toList();

    // 金額の多い順にソート
    categorySummaries.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));

    return YearlyIncomeListValue(
      monthlyGroups: monthlyGroups,
      totalIncome: totalIncome,
      categorySummaries: categorySummaries,
    );
  }
}
