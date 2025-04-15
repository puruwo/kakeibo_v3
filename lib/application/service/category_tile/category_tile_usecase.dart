import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/category_tile_entity/category_tile_entity.dart';
import 'package:kakeibo/domain/category_entity/category_repository.dart';
import 'package:kakeibo/domain/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/small_category_entity/small_category_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final categoryTileNotifierProvider = AsyncNotifierProvider.family<CategoryTileUsecaseNotifier,List<CategoryTileEntity>,MonthPeriodValue>(
  CategoryTileUsecaseNotifier.new,
);

class CategoryTileUsecaseNotifier extends FamilyAsyncNotifier<List<CategoryTileEntity>, MonthPeriodValue> {
  late CategoryRepository _categoryRepository;
  late SmallCategoryRepository _smallCategoryRepository;

  @override
  Future<List<CategoryTileEntity>> build(MonthPeriodValue monthPeriodValue) async {
    // 初回生成時
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _categoryRepository = ref.read(categoryRepositoryProvider);
    _smallCategoryRepository = ref.read(smallCategoryRepositoryProvider);

    return fetch(monthPeriodValue);
  }

  Future<List<CategoryTileEntity>> fetch(MonthPeriodValue monthPeriodValue) async {
    
    // 選択した月の集計期間から開始日と終了日を取得する
    DateTime fromDate = monthPeriodValue.startDatetime; 
    DateTime toDate = monthPeriodValue.endDatetime;

    // todo: 名前を変更する
    // カテゴリータイルのリストを取得する
    final categoryList = await _categoryRepository.fetchAll(fromDate:fromDate,toDate:toDate);

    // カテゴリータイルのリストの並び順でList<SmallCategoryExpenceEntity>を取得する
    List<CategoryTileEntity> categoryTileList = [];
    for(int i = 0; i < categoryList.length; i++){
      final smallCategoryList = await _smallCategoryRepository.fetchAll(bigCategoryId:categoryList[i].id, fromDate:fromDate, toDate:toDate);
      categoryTileList.add(CategoryTileEntity(categoryEntity:categoryList[i],smallCategoryList:smallCategoryList));
    }

    return categoryTileList;
  }
}