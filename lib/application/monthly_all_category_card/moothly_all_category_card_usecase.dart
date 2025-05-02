import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/ui_value/category_card_value/all_category_card_value/all_category_card_entity.dart';

import 'package:kakeibo/domain/core/all_category_accounting_entity/all_category_accounting_repository.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final monthlyAllCategoryCardNotifierProvider = 
    AsyncNotifierProvider.family<MonthlyAllCategoryTileUsecaseNotifier, AllCategoryCardEntity, MonthPeriodValue>(
    MonthlyAllCategoryTileUsecaseNotifier.new,
);

class MonthlyAllCategoryTileUsecaseNotifier extends FamilyAsyncNotifier<AllCategoryCardEntity,MonthPeriodValue> {
  late AllCategoryAccountingRepository _allCategoryAccountingRepository;
  late CategoryAccountingRepository _categoryAccountingRepositoryProvider;

  @override
  Future<AllCategoryCardEntity> build(MonthPeriodValue selectedMonthPeriod) async{
    // 初回生成時
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _allCategoryAccountingRepository = ref.read(allCategoryAccountingRepositoryProvider);
    _categoryAccountingRepositoryProvider = ref.read(categoryAccountingRepositoryProvider);

    return fetch(selectedMonthPeriod: selectedMonthPeriod);
  }

  // 前カテゴリー合計のタイルデータを取得する
  Future<AllCategoryCardEntity> fetch({required MonthPeriodValue selectedMonthPeriod}) async {

    // 選択した月の集計期間から開始日と終了日を取得する
    DateTime fromDate = selectedMonthPeriod.startDatetime;
    DateTime toDate = selectedMonthPeriod.endDatetime;

    final allCategoryAccountingEntity =
        await _allCategoryAccountingRepository.fetch(fromDate: fromDate, toDate: toDate);

    // カテゴリータイルのリストを取得する
    final categoryEntityList =
        await _categoryAccountingRepositoryProvider.fetchAll(fromDate: fromDate, toDate: toDate);
    // 大カテゴリーが何個あるか
    final categoryCount = categoryEntityList.length;
    // CategoryEntityから要素を取り出してリストにする
    final categoryIdList = categoryEntityList.map((e) => e.id).toList();
    final categoryNameList = categoryEntityList.map((e) => e.bigCategoryName).toList();
    final categoryExpenseList = categoryEntityList.map((e) => e.totalExpenseByBigCategory).toList();
    final categoryIconPathList = categoryEntityList.map((e) => e.categoryIconPath).toList();
    final categoryColorList = categoryEntityList.map((e) => e.categoryColor).toList();

    return AllCategoryCardEntity(
      allCategoryTotalExpense: allCategoryAccountingEntity.totalExpense,
      allCategoryTotalBudget: allCategoryAccountingEntity.totalBudget,
      categoryCount: categoryCount,
      categoryIdList: categoryIdList,
      categoryNameList: categoryNameList,
      categoryExpenseList: categoryExpenseList,
      categoryIconPathList: categoryIconPathList,
      categoryColorList: categoryColorList,
    );
  }
}
