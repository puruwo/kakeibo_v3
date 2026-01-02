import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/category_entity/income_category_entity/income_category_entity.dart';

import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';

final incomeCategoryUsecaseProvider = Provider<IncomeCategoryUsecase>(
  IncomeCategoryUsecase.new,
);

class IncomeCategoryUsecase {
  IncomeCategoryUsecase(this._ref);

  final Ref _ref;

  // ゲッターを使うことで、呼び出されるたびに _ref.read() が実行され、状態が最新化される
  IncomeSmallCategoryRepository get _smallCategoryRepositoryProvider =>
      _ref.read(incomeSmallCategoryRepositoryProvider);
  IncomeBigCategoryRepository get _bigCategoryRepositoryProvider =>
      _ref.read(incomeBigCategoryRepositoryProvider);

  /// [fetchAllBigCategory] メソッドは、収入大カテゴリーを全て取得する
  Future<List<IncomeBigCategoryEntity>> fetchAllBigCategory() async {
    // 大カテゴリーを全て取得する
    final list = await _bigCategoryRepositoryProvider.fetchAll();

    return list;
  }

  /// [fetchAllCategory] メソッドは、収入カテゴリーを全て取得する
  Future<List<IncomeCategoryEntity>> fetchAllCategory() async {
    // 小カテゴリーを取得する
    final smallCategoryEntityList =
        await _smallCategoryRepositoryProvider.fetchAll();

    final results = <IncomeCategoryEntity>[];

    for (IncomeSmallCategoryEntity smallCategoryEntity
        in smallCategoryEntityList) {
      // 大カテゴリーを取得する
      final incomeBigCategoryEntity =
          await _bigCategoryRepositoryProvider.fetchByBigCategory(
              bigCategoryId: smallCategoryEntity.bigCategoryKey);

      // カテゴリー情報をまとめてentityに格納する
      final categoryEntity = IncomeCategoryEntity(
        id: smallCategoryEntity.id,
        smallCategoryOrderKey: smallCategoryEntity.smallCategoryOrderKey,
        bigCategoryKey: smallCategoryEntity.bigCategoryKey,
        displaydOrderInBig: smallCategoryEntity.displayedOrderInBig,
        categoryName: smallCategoryEntity.smallCategoryName,
        defaultDisplayed: smallCategoryEntity.defaultDisplayed,
        bigCategoryName: incomeBigCategoryEntity.name,
        colorCode: incomeBigCategoryEntity.colorCode,
        resourcePath: incomeBigCategoryEntity.iconPath,
        // displayOrder: incomeBigCategoryEntity.displayOrder,
        // isDisplayed: incomeBigCategoryEntity.isDisplayed,
      );

      results.add(categoryEntity);
    }

    // smallCategoryOrderKeyの昇順で並び替える
    results.sort(
        ((a, b) => a.smallCategoryOrderKey.compareTo(b.smallCategoryOrderKey)));

    // smallCategoryOrderKeyが歯抜けの場合の対策として整数連続値でsortKeyを付与する
    int i = 0;
    for (IncomeCategoryEntity categoryEntity in results) {
      final updated = categoryEntity.copyWith(sortKey: i);
      results[i] = updated;
      i++;
    }

    return results;
  }

  /// [fetchBigCategoryByBigId] メソッドは、収入カテゴリーを取得する
  Future<IncomeBigCategoryEntity> fetchBigCategoryByBigId(int id) async {
    // 大カテゴリーを取得する
    final incomeBigCategoryEntity = await _bigCategoryRepositoryProvider
        .fetchByBigCategory(bigCategoryId: id);

    return incomeBigCategoryEntity;
  }

  /// [fetchCategoryBySmallId] メソッドは、収入カテゴリーを取得する
  Future<IncomeCategoryEntity> fetchCategoryBySmallId(int id) async {
    // 小カテゴリーを取得する
    final smallCategoryEntity = await _smallCategoryRepositoryProvider
        .fetchBySmallCategory(smallCategoryId: id);

    // 大カテゴリーを取得する
    final incomeBigCategoryEntity = await _bigCategoryRepositoryProvider
        .fetchByBigCategory(bigCategoryId: smallCategoryEntity.bigCategoryKey);

    // カテゴリー情報をまとめてentityに格納する
    final categoryEntity = IncomeCategoryEntity(
      id: smallCategoryEntity.id,
      smallCategoryOrderKey: smallCategoryEntity.smallCategoryOrderKey,
      bigCategoryKey: smallCategoryEntity.bigCategoryKey,
      displaydOrderInBig: smallCategoryEntity.displayedOrderInBig,
      categoryName: smallCategoryEntity.smallCategoryName,
      defaultDisplayed: smallCategoryEntity.defaultDisplayed,
      bigCategoryName: incomeBigCategoryEntity.name,
      colorCode: incomeBigCategoryEntity.colorCode,
      resourcePath: incomeBigCategoryEntity.iconPath,
      // displayOrder: incomeBigCategoryEntity.displayOrder,
      // isDisplayed: incomeBigCategoryEntity.isDisplayed,
    );

    return categoryEntity;
  }

  /// 表示順を一括更新（並び替え画面用）
  /// [newOrders] は { カテゴリーID: 新しい表示順 } のMap
  Future<void> updateDisplayOrders(Map<int, int> newOrders) async {
    for (final entry in newOrders.entries) {
      final categoryId = entry.key;
      final newOrder = entry.value;

      // 小カテゴリーを取得して更新
      final smallCategory = await _smallCategoryRepositoryProvider
          .fetchBySmallCategory(smallCategoryId: categoryId);

      // エンティティに定義されているupdateメソッドを使用
      final updatedEntity = IncomeSmallCategoryEntity(
        id: smallCategory.id,
        smallCategoryOrderKey: newOrder,
        bigCategoryKey: smallCategory.bigCategoryKey,
        displayedOrderInBig: smallCategory.displayedOrderInBig,
        smallCategoryName: smallCategory.smallCategoryName,
        defaultDisplayed: smallCategory.defaultDisplayed,
      );
      updatedEntity.update();
    }
  }
}
