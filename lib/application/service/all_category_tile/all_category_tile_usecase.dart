import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/all_category_tile_entity/all_category_tile_entity.dart';

import 'package:kakeibo/domain/all_category_entity/all_category_repository.dart';
import 'package:kakeibo/domain/category_entity/category_repository.dart';

final allCategoryTileProvider = Provider<AllCategoryTileUsecase>(
  AllCategoryTileUsecase.new,
);

class AllCategoryTileUsecase {
  final Ref _ref;

  AllCategoryRepository get _allCategoryRepository =>
      _ref.read(allCategoryRepositoryProvider);
  CategoryRepository get _categoryRepository =>
      _ref.read(categoryRepositoryProvider);

  AllCategoryTileUsecase(this._ref);

  Future<AllCategoryTileEntity> fetch() async {
    // todo: 選択日時を取得する
    // 例として2025年3月のデータを取得
    DateTime fromDate = DateTime.utc(2025, 3, 1);
    DateTime toDate = DateTime.utc(2025, 3, 31);

    final allCategoryEntity =
        await _allCategoryRepository.fetch(fromDate: fromDate, toDate: toDate);

    // todo: 名前を変更する
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
