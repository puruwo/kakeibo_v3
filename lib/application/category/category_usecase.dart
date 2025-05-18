import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/core/category_entity/expense_category_entity/expense_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';

final categoryUsecaseProvider = Provider<CategoryUsecase>(
  CategoryUsecase.new,
);

class CategoryUsecase {
  CategoryUsecase(this._ref);

  final Ref _ref;

  // ゲッターを使うことで、呼び出されるたびに _ref.read() が実行され、状態が最新化される
  ExpenseSmallCategoryRepository get _smallCategoryRepositoryProvider =>
      _ref.read(expenseSmallCategoryRepositoryProvider);
  ExpenseBigCategoryRepository get _bigCategoryRepositoryProvider =>
      _ref.read(expensebigCategoryRepositoryProvider);

  /// [fetchAll] メソッドは、全ての小カテゴリー情報を取得し、それに関連する大カテゴリー情報を取得して、最終的に
  /// カテゴリー情報をまとめて返す
  Future<List<ExpenseCategoryEntity>> fetchAll() async {
    // 小カテゴリーを全て取得する
    final list = await _smallCategoryRepositoryProvider.fetchAll();

    final categoryList = <ExpenseCategoryEntity>[];

    // 各カテゴリー情報をentity化する
    for (var element in list) {
      // 小カテゴリーから大カテゴリーの情報を取得する
      final bigCategoryEntity = await _bigCategoryRepositoryProvider
          .fetchByBigCategory(bigCategoryId: element.bigCategoryKey);

      // カテゴリー情報をまとめてentityに格納する
      final categoryEntity = ExpenseCategoryEntity(
        id: element.id,
        smallCategoryOrderKey: element.smallCategoryOrderKey,
        bigCategoryKey: element.bigCategoryKey,
        displaydOrderInBig: element.displayedOrderInBig,
        smallCategoryName: element.smallCategoryName,
        defaultDisplayed: element.defaultDisplayed,
        bigCategoryName: bigCategoryEntity.bigCategoryName,
        colorCode: bigCategoryEntity.colorCode,
        resourcePath: bigCategoryEntity.resourcePath,
        displayOrder: bigCategoryEntity.displayOrder,
        isDisplayed: bigCategoryEntity.isDisplayed,
      );

      categoryList.add(categoryEntity);
    }

    // smallCategoryOrderKeyの昇順で並び替える
    categoryList.sort(
        ((a, b) => a.smallCategoryOrderKey.compareTo(b.smallCategoryOrderKey)));

    // smallCategoryOrderKeyが歯抜けの場合の対策として整数連続値でsortKeyを付与する
    int i=0;
    for(ExpenseCategoryEntity categoryEntity in categoryList){
      final updated = categoryEntity.copyWith(sortKey: i);
      categoryList[i] = updated;
      i++;
    }

    return categoryList;
  }

  Future<ExpenseCategoryEntity> fetchByBigCategory(int id) async {
    // 小カテゴリーを取得する
    final smallCategoryEntity = await _smallCategoryRepositoryProvider
        .fetchBySmallCategory(smallCategoryId: id);

    // 小カテゴリーから大カテゴリーの情報を取得する
    final bigCategoryEntity = await _bigCategoryRepositoryProvider
        .fetchByBigCategory(bigCategoryId: smallCategoryEntity.bigCategoryKey);

    // カテゴリー情報をまとめてentityに格納する
    final categoryEntity = ExpenseCategoryEntity(
      id: smallCategoryEntity.id,
      smallCategoryOrderKey: smallCategoryEntity.smallCategoryOrderKey,
      bigCategoryKey: smallCategoryEntity.bigCategoryKey,
      displaydOrderInBig: smallCategoryEntity.displayedOrderInBig,
      smallCategoryName: smallCategoryEntity.smallCategoryName,
      defaultDisplayed: smallCategoryEntity.defaultDisplayed,
      bigCategoryName: bigCategoryEntity.bigCategoryName,
      colorCode: bigCategoryEntity.colorCode,
      resourcePath: bigCategoryEntity.resourcePath,
      displayOrder: bigCategoryEntity.displayOrder,
      isDisplayed: bigCategoryEntity.isDisplayed,
    );

    return categoryEntity;
  }
}
