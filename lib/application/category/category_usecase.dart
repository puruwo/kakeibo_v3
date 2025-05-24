import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/domain/core/category_entity/expense_category_entity/expense_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/ui_value/expense_big_category_with_small_list_value/edit_expense_big_category_value.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

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

  void _invalidateCategoryProvider() =>
      _ref.invalidate(categoryUsecaseProvider);

  // DBの更新を管理するnotifierを取得
  UpdateDBCountNotifier get _updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

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
    int i = 0;
    for (ExpenseCategoryEntity categoryEntity in categoryList) {
      final updated = categoryEntity.copyWith(sortKey: i);
      categoryList[i] = updated;
      i++;
    }

    return categoryList;
  }

  /// [fetchBySmallId] メソッドは、小カテゴリーのキーを入力しカテゴリー情報を取得する
  Future<ExpenseCategoryEntity> fetchBySmallId(int id) async {
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

  /// [fetchAllBigCategoriesWithSmallList]はsmallCategoryの情報を添えて全ての大カテゴリーを取得する
  Future<List<EditExpenseBigCategoryValue>>
      fetchAllBigCategoriesWithSmallList() async {
    // 大カテゴリーを全て取得する
    final list = await _bigCategoryRepositoryProvider.fetchAll();

    final bigCategoryList = <EditExpenseBigCategoryValue>[];

    // 各カテゴリー情報をentity化する
    for (var element in list) {
      // 大カテゴリーから小カテゴリーのリストを取得する
      final smallCategoryEntity = await _smallCategoryRepositoryProvider
          .fetchByBigCategory(bigCategoryId: element.id);

      String smallCategoryNameText = '';
      // 小カテゴリーの名前をまとめる
      for (var smallCategory in smallCategoryEntity) {
        smallCategoryNameText =
            '$smallCategoryNameText,${smallCategory.smallCategoryName}';
        // 先頭がカンマの場合のみ取り除く
        if (smallCategoryNameText.startsWith(',')) {
          smallCategoryNameText = smallCategoryNameText.substring(1);
        }
      }

      // カテゴリー情報をまとめてentityに格納する
      final bigCategoryEntity = EditExpenseBigCategoryValue(
          id: element.id,
          colorCode: element.colorCode,
          bigCategoryName: element.bigCategoryName,
          resourcePath: element.resourcePath,
          displayOrder: element.displayOrder,
          isDisplayed: element.isDisplayed,
          expenseSmallCategoryList: smallCategoryEntity,
          expenseSmallCategoryNameText: smallCategoryNameText,
          // 初期値は取得したデータをそのまま設定
          editedStateDisplayOrder: element.displayOrder,
          etitedStateIsChecked: element.isDisplayed == 1 ? true : false);

      bigCategoryList.add(bigCategoryEntity);
    }

    // smallCategoryOrderKeyの昇順で並び替える
    bigCategoryList.sort(((a, b) => a.displayOrder.compareTo(b.displayOrder)));

    // smallCategoryOrderKeyが歯抜けの場合の対策として整数連続値でsortKeyを付与する
    int i = 0;
    for (EditExpenseBigCategoryValue bigCategoryEntity in bigCategoryList) {
      final updated = bigCategoryEntity.copyWith(editedStateDisplayOrder: i);
      bigCategoryList[i] = updated;
      i++;
    }

    return bigCategoryList;
  }

  // 編集処理
  Future<void> edit(
      {required List<EditExpenseBigCategoryValue> originalValues,
      required List<EditExpenseBigCategoryValue> editValues}) async {
    //エラーチェック
    if (originalValues.length != editValues.length) {
      // リストの長さが一致しない場合
      throw const AppException('予期せぬエラーが発生しました(E001)');
    }

    // カテゴリーID順に並べてfor文で扱いやすくする
    originalValues.sort((a, b) => a.id.compareTo(b.id));

    for (var i = 0; i < originalValues.length; i++) {
      // 変更があればアップデートする
      if (originalValues[i] != editValues[i]) {
        final entity = ExpenseBigCategoryEntity(
            id: editValues[i].id,
            colorCode: editValues[i].colorCode,
            bigCategoryName: editValues[i].bigCategoryName,
            resourcePath: editValues[i].resourcePath,
            displayOrder: editValues[i].editedStateDisplayOrder,
            isDisplayed: editValues[i].etitedStateIsChecked ? 1 : 0);

        _bigCategoryRepositoryProvider.update(entity: entity);
      }
    }

    // providerをdisposeしてリフレッシュ
    _invalidateCategoryProvider;

    // DBの更新回数をインクリメント
    _updateDBCountNotifier.incrementState();
  }
}
