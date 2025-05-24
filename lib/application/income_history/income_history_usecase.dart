import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final incomeHistoryNotifierProvider = AsyncNotifierProvider.family<
    IncomeHistoryUsecaseNotifier,
    List<IncomeHistoryTileValue>,
    MonthPeriodValue>(
  IncomeHistoryUsecaseNotifier.new,
);

class IncomeHistoryUsecaseNotifier extends FamilyAsyncNotifier<
    List<IncomeHistoryTileValue>, MonthPeriodValue> {
  // 収入履歴に関するリポジトリ
  late IncomeRepository _incomeRepositoryProvider;

  // 小カテゴリーに関するリポジトリ
  late IncomeSmallCategoryRepository _smallCategoryRepository;

  // 大カテゴリーに関するリポジトリ
  late IncomeBigCategoryRepository _bigCategoryRepository;

  @override
  Future<List<IncomeHistoryTileValue>> build(
      MonthPeriodValue selectedMonthPeriod) async {

    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _incomeRepositoryProvider = ref.read(incomeRepositoryProvider);

    _smallCategoryRepository = ref.read(incomeSmallCategoryRepositoryProvider);

    _bigCategoryRepository = ref.read(incomeBigCategoryRepositoryProvider);

    return fetch(selectedMonthPeriod: selectedMonthPeriod);
  }

  // 期間指定でタイルデータを取得する
  Future<List<IncomeHistoryTileValue>> fetch({required MonthPeriodValue selectedMonthPeriod}) async {
    
    // SqfExpenseからデータを取得する
    final incomeList = await _incomeRepositoryProvider.fetchWithoutCategory(period: selectedMonthPeriod);

    // 取得した支出データから、それぞれカテゴリーなどの情報を取得し、タイルのデータを作成する
    List<IncomeHistoryTileValue> result = [];

    for (var income in incomeList) {
      // 支出のレコードからカテゴリーidを取得し、小カテゴリーの情報を取得する
      final smallCategory =
          await _smallCategoryRepository.fetchBySmallCategory(smallCategoryId: income.categoryId);

      // 小カテゴリーのレコードから大カテゴリーidを取得し、大カテゴリーの情報を取得する
      final bigCategory =
          await _bigCategoryRepository.fetchByBigCategory(bigCategoryId: smallCategory.bigCategoryKey);

      final incomeHistoryTileValue = IncomeHistoryTileValue(
        id: income.id,
        date: DateTime.parse(
        '${income.date.substring(0, 4)}-${income.date.substring(4, 6)}-${income.date.substring(6, 8)}'),
        price: income.price,
        paymentCategoryId: income.categoryId,
        memo: income.memo,
        smallCategoryName: smallCategory.smallCategoryName,
        bigCategoryName: bigCategory.name,
        colorCode: bigCategory.colorCode,
        iconPath: bigCategory.iconPath,
      );

      result.add(incomeHistoryTileValue);
    }

    return result;
  }
}
