import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/category_entity/income_category_entity/income_category_entity.dart';

import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/domain/ui_value/edit_income_small_category_list_value/edit_income_small_category_value.dart';
import 'package:kakeibo/domain/ui_value/income_big_category_value/edit_income_big_category_value.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

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
  IncomeRepository get _incomeRepositoryProvider =>
      _ref.read(incomeRepositoryProvider);

  // DBの更新を管理するnotifierを取得
  UpdateDBCountNotifier get _updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

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

  /// [fetchAllBigCategoriesWithSmallList] は smallCategory の情報を添えて全ての大カテゴリーを取得する
  Future<List<EditIncomeBigCategoryValue>>
      fetchAllBigCategoriesWithSmallList() async {
    final list = await _bigCategoryRepositoryProvider.fetchAll();

    final bigCategoryList = <EditIncomeBigCategoryValue>[];

    for (var element in list) {
      final smallCategoryEntity = await _smallCategoryRepositoryProvider
          .fetchByBigCategory(bigCategoryId: element.id);

      String smallCategoryNameText = '';
      for (var smallCategory in smallCategoryEntity) {
        smallCategoryNameText =
            '$smallCategoryNameText,${smallCategory.smallCategoryName}';
        if (smallCategoryNameText.startsWith(',')) {
          smallCategoryNameText = smallCategoryNameText.substring(1);
        }
      }

      bigCategoryList.add(EditIncomeBigCategoryValue(
        id: element.id,
        colorCode: element.colorCode,
        bigCategoryName: element.name,
        resourcePath: element.iconPath,
        incomeSmallCategoryList: smallCategoryEntity,
        incomeSmallCategoryNameText: smallCategoryNameText,
      ));
    }

    bigCategoryList.sort((a, b) => a.id.compareTo(b.id));

    return bigCategoryList;
  }

  /// [fetchSmallCategoriesByBig] は bigId 指定で smallCategory の一覧を取得する
  Future<List<EditIncomeSmallCategoryValue>> fetchSmallCategoriesByBig(
      int bigCategoryId) async {
    final fetchList = await _smallCategoryRepositoryProvider.fetchByBigCategory(
        bigCategoryId: bigCategoryId);

    final resultList = <EditIncomeSmallCategoryValue>[];

    for (var element in fetchList) {
      resultList.add(EditIncomeSmallCategoryValue(
        id: element.id,
        bigCategoryKey: element.bigCategoryKey,
        name: element.smallCategoryName,
        smallCategoryOrderKey: element.smallCategoryOrderKey,
        displayOrderInBig: element.displayedOrderInBig,
        defaultDisplayed: element.defaultDisplayed,
        editedStateDisplayOrder: element.displayedOrderInBig,
        etitedStateIsChecked: element.defaultDisplayed == 1,
      ));
    }

    resultList
        .sort(((a, b) => a.displayOrderInBig.compareTo(b.displayOrderInBig)));

    int i = 0;
    for (EditIncomeSmallCategoryValue smallCategoryEntity in resultList) {
      final updated = smallCategoryEntity.copyWith(editedStateDisplayOrder: i);
      resultList[i] = updated;
      i++;
    }

    return resultList;
  }

  /// 大カテゴリーの新規追加
  Future<int> addBig(IncomeBigCategoryEntity entity) async {
    final addedId = await _bigCategoryRepositoryProvider.add(entity: entity);
    _updateDBCountNotifier.incrementState();
    return addedId;
  }

  /// 大カテゴリー単一編集
  Future<void> bigEdit({
    required IncomeBigCategoryEntity original,
    required IncomeBigCategoryEntity edit,
  }) async {
    if (original != edit) {
      await _bigCategoryRepositoryProvider.update(entity: edit);
    }
    _updateDBCountNotifier.incrementState();
  }

  /// 大カテゴリー削除（id=1, id=2 は削除不可）
  /// 紐づく小カテゴリーと income レコードも削除する
  Future<void> deleteBig(int bigId) async {
    if (bigId == 1 || bigId == 2) {
      throw const AppException('このカテゴリーは削除できません');
    }

    // 紐づく小カテゴリーIDを先に取得
    final smallIds = await _smallCategoryRepositoryProvider
        .fetchSmallCategoryIdListByBigCategoryId(bigCategoryId: bigId);
    final smallIdSet = smallIds.toSet();

    // 紐づく income レコードを削除（期間によらず該当する小カテゴリーをまとめて削除）
    final allIncomes = await _incomeRepositoryProvider.fetchAll();
    for (final income in allIncomes) {
      if (smallIdSet.contains(income.categoryId)) {
        _incomeRepositoryProvider.delete(income.id);
      }
    }

    // 小カテゴリーを削除
    await _smallCategoryRepositoryProvider
        .deleteByBigCategory(bigCategoryId: bigId);

    // 大カテゴリーを削除
    await _bigCategoryRepositoryProvider.delete(id: bigId);

    _updateDBCountNotifier.incrementState();
  }

  /// 小カテゴリーの追加処理
  Future<void> addSmall(IncomeSmallCategoryEntity entity) async {
    // 受け取った smallCategoryOrderKey は仮値のため最大値を取得して採番する
    final maxOrderKey = await _smallCategoryRepositoryProvider
        .getMaxSmallCategoryOrderKey(bigCategoryId: entity.bigCategoryKey);

    final newEntity = IncomeSmallCategoryEntity(
      id: entity.id,
      bigCategoryKey: entity.bigCategoryKey,
      smallCategoryName: entity.smallCategoryName,
      smallCategoryOrderKey: maxOrderKey + 1,
      displayedOrderInBig: entity.displayedOrderInBig,
      defaultDisplayed: entity.defaultDisplayed,
    );

    await _smallCategoryRepositoryProvider.add(entity: newEntity);

    _updateDBCountNotifier.incrementState();
  }

  /// 小カテゴリーの編集（並び替え・編集・追加）
  Future<void> smallEdit({
    required List<EditIncomeSmallCategoryValue> originalValues,
    required List<EditIncomeSmallCategoryValue> editValues,
  }) async {
    if (originalValues.length > editValues.length) {
      throw const AppException('予期せぬエラーが発生しました(E001)');
    }

    // ID降順（追加カテゴリーは-1のため先頭に来る）
    originalValues.sort((a, b) => b.id.compareTo(a.id));
    editValues.sort((a, b) => b.id.compareTo(a.id));

    for (var i = 0; i < originalValues.length; i++) {
      if (originalValues[i] != editValues[i]) {
        final entity = IncomeSmallCategoryEntity(
          id: editValues[i].id,
          bigCategoryKey: editValues[i].bigCategoryKey,
          smallCategoryName: editValues[i].name,
          smallCategoryOrderKey: editValues[i].smallCategoryOrderKey,
          displayedOrderInBig: editValues[i].editedStateDisplayOrder,
          defaultDisplayed: editValues[i].etitedStateIsChecked ? 1 : 0,
        );

        await _smallCategoryRepositoryProvider.update(entity: entity);
      }
    }

    if (originalValues.length < editValues.length) {
      final addedElements = editValues.sublist(originalValues.length);

      int maxOrderKey =
          await _smallCategoryRepositoryProvider.getMaxSmallCategoryOrderKey(
              bigCategoryId: addedElements.first.bigCategoryKey);

      for (var element in addedElements) {
        maxOrderKey++;
        final entity = IncomeSmallCategoryEntity(
          id: element.id,
          bigCategoryKey: element.bigCategoryKey,
          smallCategoryName: element.name,
          smallCategoryOrderKey: maxOrderKey,
          displayedOrderInBig: element.editedStateDisplayOrder,
          defaultDisplayed: element.etitedStateIsChecked ? 1 : 0,
        );

        await _smallCategoryRepositoryProvider.add(entity: entity);
      }
    }

    _updateDBCountNotifier.incrementState();
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
      await _smallCategoryRepositoryProvider.update(entity: updatedEntity);
    }

    _updateDBCountNotifier.incrementState();
  }
}
