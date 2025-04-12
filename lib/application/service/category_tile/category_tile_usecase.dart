import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/category_tile_entity/category_tile_entity.dart';
import 'package:kakeibo/domain/category_entity/category_repository.dart';
import 'package:kakeibo/domain/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/small_category_entity/small_category_repository.dart';

final categoryTileProvider = Provider<CategoryTileUsecase>(
  CategoryTileUsecase.new,
);

class CategoryTileUsecase {
  final Ref _ref;

  CategoryRepository get _categoryRepository => _ref.read(categoryRepositoryProvider);
  SmallCategoryRepository get _smallCategoryRepository => _ref.read(smallCategoryRepositoryProvider);

  CategoryTileUsecase(this._ref);

  Future<List<CategoryTileEntity>> fetchSelectedRangeData(MonthPeriodValue monthPeriodValue) async {
    
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