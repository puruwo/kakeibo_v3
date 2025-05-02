import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/category_card_entity.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final monthlyCategoryCardNotifierProvider = AsyncNotifierProvider.family<MonthlyCategoryCardUsecaseNotifier,List<CategoryCardEntity>,MonthPeriodValue>(
  MonthlyCategoryCardUsecaseNotifier.new,
);

class MonthlyCategoryCardUsecaseNotifier extends FamilyAsyncNotifier<List<CategoryCardEntity>, MonthPeriodValue> {
  late CategoryAccountingRepository _categoryAccountingRepositoryProvider;
  late SmallCategoryTileRepository _smallCategoryTileRepository;

  @override
  Future<List<CategoryCardEntity>> build(MonthPeriodValue monthPeriodValue) async {
    // 初回生成時
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _categoryAccountingRepositoryProvider = ref.read(categoryAccountingRepositoryProvider);
    _smallCategoryTileRepository = ref.read(smallCategoryTileRepositoryProvider);

    return fetch(monthPeriodValue);
  }

  Future<List<CategoryCardEntity>> fetch(MonthPeriodValue monthPeriodValue) async {
    
    // 選択した月の集計期間から開始日と終了日を取得する
    DateTime fromDate = monthPeriodValue.startDatetime; 
    DateTime toDate = monthPeriodValue.endDatetime;

    // todo: 名前を変更する
    // カテゴリータイルのリストを取得する
    final categoryList = await _categoryAccountingRepositoryProvider.fetchAll(fromDate:fromDate,toDate:toDate);

    // カテゴリータイルのリストの並び順でList<SmallCategoryTileExpenceEntity>を取得する
    List<CategoryCardEntity> categoryTileList = [];
    for(int i = 0; i < categoryList.length; i++){
      final smallCategoryList = await _smallCategoryTileRepository.fetchAll(bigCategoryId:categoryList[i].id, fromDate:fromDate, toDate:toDate);
      categoryTileList.add(CategoryCardEntity(monthlyExpenseByCategoryEntity:categoryList[i],smallCategoryList:smallCategoryList));
    }

    return categoryTileList;
  }
}