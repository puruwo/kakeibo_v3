import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/category_tile_entity/category_tile_entity.dart';
import 'package:kakeibo/domain/category_entity/category_repository.dart';
import 'package:kakeibo/domain/small_category_entity/small_category_repository.dart';

final categoryTileProvider = Provider<CategoryTileUsecase>(
  CategoryTileUsecase.new,
);

class CategoryTileUsecase {
  final Ref _ref;

  CategoryRepository get _categoryRepository => _ref.read(categoryRepositoryProvider);
  SmallCategoryRepository get _smallCategoryRepository => _ref.read(smallCategoryRepositoryProvider);

  // CategoryTileRepository get _categoryTileRepository => _ref.read(categoryTileRepositoryProvider);

  CategoryTileUsecase(this._ref);

  Future<List<CategoryTileEntity>> fetchAll() async {
    
    // todo: 選択日時を取得する
    // 例として2025年3月のデータを取得
    DateTime fromDate = DateTime.utc(2025, 3, 1); 
    DateTime toDate = DateTime.utc(2025, 3, 31);

    // todo: 名前を変更する
    // カテゴリータイルのリストを取得する
    final categoryList = await _categoryRepository.fetchAll(fromDate,toDate);

    // カテゴリータイルのリストの並び順でList<SmallCategoryExpenceEntity>を取得する
    List<CategoryTileEntity> categoryTileList = [];
    for(int i = 0; i < categoryList.length; i++){
      final smallCategoryList = await _smallCategoryRepository.fetchAll(categoryList[i].id, fromDate, toDate);
      categoryTileList.add(CategoryTileEntity(categoryEntity:categoryList[i],smallCategoryList:smallCategoryList));
    }

    return categoryTileList;
  }
}