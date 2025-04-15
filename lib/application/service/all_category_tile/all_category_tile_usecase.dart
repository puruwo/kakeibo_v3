import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/all_category_tile_entity/all_category_tile_entity.dart';

import 'package:kakeibo/domain/all_category_entity/all_category_repository.dart';
import 'package:kakeibo/domain/category_entity/category_repository.dart';
import 'package:kakeibo/domain/month_period_value/month_period_value.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final allCategoryTileNotifierProvider = 
    AsyncNotifierProvider.family<AllCategoryTileUsecaseNotifier, AllCategoryTileEntity, MonthPeriodValue>(
    AllCategoryTileUsecaseNotifier.new,
);

class AllCategoryTileUsecaseNotifier extends FamilyAsyncNotifier<AllCategoryTileEntity,MonthPeriodValue> {
  late AllCategoryRepository _allCategoryRepository;
  late CategoryRepository _categoryRepository;

  @override
  Future<AllCategoryTileEntity> build(MonthPeriodValue selectedMonthPeriod) async{
    // 初回生成時
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _allCategoryRepository = ref.read(allCategoryRepositoryProvider);
    _categoryRepository = ref.read(categoryRepositoryProvider);

    return fetch(selectedMonthPeriod: selectedMonthPeriod);
  }

  // 前カテゴリー合計のタイルデータを取得する
  Future<AllCategoryTileEntity> fetch({required MonthPeriodValue selectedMonthPeriod}) async {

    // 選択した月の集計期間から開始日と終了日を取得する
    DateTime fromDate = selectedMonthPeriod.startDatetime;
    DateTime toDate = selectedMonthPeriod.endDatetime;

    final allCategoryEntity =
        await _allCategoryRepository.fetch(fromDate: fromDate, toDate: toDate);

    // カテゴリータイルのリストを取得する
    final categoryEntityList =
        await _categoryRepository.fetchAll(fromDate: fromDate, toDate: toDate);
    // 大カテゴリーが何個あるか
    final categoryCount = categoryEntityList.length;
    // CategoryEntityから要素を取り出してリストにする
    final categoryIdList = categoryEntityList.map((e) => e.id).toList();
    final categoryNameList = categoryEntityList.map((e) => e.bigCategoryName).toList();
    final categoryExpenseList = categoryEntityList.map((e) => e.totalExpenseByBigCategory).toList();
    final categoryIconPathList = categoryEntityList.map((e) => e.categoryIconPath).toList();
    final categoryColorList = categoryEntityList.map((e) => e.categoryColor).toList();

    return AllCategoryTileEntity(
      allCategoryTotalExpense: allCategoryEntity.totalExpense,
      allCategoryTotalBudget: allCategoryEntity.totalBudget,
      categoryCount: categoryCount,
      categoryIdList: categoryIdList,
      categoryNameList: categoryNameList,
      categoryExpenseList: categoryExpenseList,
      categoryIconPathList: categoryIconPathList,
      categoryColorList: categoryColorList,
    );
  }
}
