import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/category_entity/category_entity.dart';
import 'package:kakeibo/domain/tbl201/small_category_repository.dart';
import 'package:kakeibo/domain/tbl202/big_category_repository.dart';

final categoryUsecaseProvider = Provider<CategoryUsecase>(
  CategoryUsecase.new,
);

class CategoryUsecase {
  CategoryUsecase(this._ref);

  final Ref _ref;

  // ゲッターを使うことで、呼び出されるたびに _ref.read() が実行され、状態が最新化される
  SmallCategoryRepository get _smallCategoryRepositoryProvider =>
      _ref.read(smallCategoryRepositoryProvider);
  BigCategoryRepository get _bigCategoryRepositoryProvider =>
      _ref.read(bigCategoryRepositoryProvider);

  /// [fetchAll] メソッドは、全ての小カテゴリー情報を取得し、それに関連する大カテゴリー情報を取得して、最終的に
  /// カテゴリー情報をまとめて返す
  Future<List<CategoryEntity>> fetchAll() async {
    // 小カテゴリーを全て取得する
    final list = await _smallCategoryRepositoryProvider.fetchAll();

    final categoryList = <CategoryEntity>[];

    // 各カテゴリー情報をentity化する
    for (var element in list) {
      
      // 小カテゴリーから大カテゴリーの情報を取得する
      final bigCategoryEntity = await _bigCategoryRepositoryProvider
          .fetchByBigCategory(bigCategoryId: element.bigCategoryKey);

      // カテゴリー情報をまとめてentityに格納する
      final categoryEntity = CategoryEntity(
          id: element.id,
          smallCategoryOrderKey: element.smallCategoryOrderKey,
          bigCategoryKey: element.bigCategoryKey,
          displaydOrderInBig: element.displayedOrderInBig,
          smallCategoryName: element.smallCategoryName,
          defaultDisplayed: element.defaultDisplayed,
          bigCategoryEntity: bigCategoryEntity);

      categoryList.add(categoryEntity);
    }

    return categoryList;
  }

  Future<CategoryEntity> fetchById(int id) async {
    // 小カテゴリーを取得する
    final smallCategoryEntity =
        await _smallCategoryRepositoryProvider.fetchBySmallCategory(smallCategoryId: id);

    // 小カテゴリーから大カテゴリーの情報を取得する
    final bigCategoryEntity = await _bigCategoryRepositoryProvider
        .fetchByBigCategory(bigCategoryId: smallCategoryEntity.bigCategoryKey);

    // カテゴリー情報をまとめてentityに格納する
    final categoryEntity = CategoryEntity(
        id: smallCategoryEntity.id,
        smallCategoryOrderKey: smallCategoryEntity.smallCategoryOrderKey,
        bigCategoryKey: smallCategoryEntity.bigCategoryKey,
        displaydOrderInBig: smallCategoryEntity.displayedOrderInBig,
        smallCategoryName: smallCategoryEntity.smallCategoryName,
        defaultDisplayed: smallCategoryEntity.defaultDisplayed,
        bigCategoryEntity: bigCategoryEntity);

    return categoryEntity;
  }

}
