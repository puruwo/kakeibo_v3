import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/category_entity/expense_category_entity/expense_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/ui_value/edit_expense_small_category_list_value/edit_expense_small_category_value.dart';
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
        categoryName: element.smallCategoryName,
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
      categoryName: smallCategoryEntity.smallCategoryName,
      defaultDisplayed: smallCategoryEntity.defaultDisplayed,
      bigCategoryName: bigCategoryEntity.bigCategoryName,
      colorCode: bigCategoryEntity.colorCode,
      resourcePath: bigCategoryEntity.resourcePath,
      displayOrder: bigCategoryEntity.displayOrder,
      isDisplayed: bigCategoryEntity.isDisplayed,
    );

    return categoryEntity;
  }

  /// [fetchBigCategory] メソッドは、小カテゴリーのキーを入力しカテゴリー情報を取得する
  Future<ExpenseBigCategoryEntity> fetchBigCategory(int bigId) async {
    // 小カテゴリーから大カテゴリーの情報を取得する
    final bigCategoryEntity = await _bigCategoryRepositoryProvider
        .fetchByBigCategory(bigCategoryId: bigId);

    return bigCategoryEntity;
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

  /// [fetchSmallCategoriesByBig]はBigIDを指定してsmallCategoryの一覧を取得する
  Future<List<EditExpenseSmallCategoryValue>> fetchSmallCategoriesByBig(
      int bigCategoryId) async {
    // カテゴリーのリストを取得する
    final fetchList = await _smallCategoryRepositoryProvider.fetchByBigCategory(
        bigCategoryId: bigCategoryId);

    final resultList = <EditExpenseSmallCategoryValue>[];

    // 各カテゴリー情報をentity化する
    for (var element in fetchList) {
      // カテゴリー情報をまとめてentityに格納する
      final smallCategoryEntity = EditExpenseSmallCategoryValue(
          id: element.id,
          bigCategoryKey: element.bigCategoryKey,
          name: element.smallCategoryName,
          smallCategoryOrderKey: element.smallCategoryOrderKey,
          displayOrderInBig: element.displayedOrderInBig,
          defaultDisplayed: element.defaultDisplayed,
          editedStateDisplayOrder: element.displayedOrderInBig,
          etitedStateIsChecked: element.defaultDisplayed == 1);

      resultList.add(smallCategoryEntity);
    }

    // smallCategoryOrderKeyの昇順で並び替える
    resultList
        .sort(((a, b) => a.displayOrderInBig.compareTo(b.displayOrderInBig)));

    // smallCategoryOrderKeyが歯抜けの場合の対策として整数連続値でsortKeyを付与する
    int i = 0;
    for (EditExpenseSmallCategoryValue smallCategoryEntity in resultList) {
      final updated = smallCategoryEntity.copyWith(editedStateDisplayOrder: i);
      resultList[i] = updated;
      i++;
    }

    return resultList;
  }

  // 大カテゴリーの複数編集処理
  Future<void> bigCategoriesEdit(
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

    // DBの更新回数をインクリメント
    _updateDBCountNotifier.incrementState();
  }

  // 大カテゴリーの単一編集処理
  Future<void> bigEdit(
      {required ExpenseBigCategoryEntity original,
      required ExpenseBigCategoryEntity edit}) async {
    // 変更があればアップデートする
    if (original != edit) {
      _bigCategoryRepositoryProvider.update(entity: edit);
    }

    // DBの更新回数をインクリメント
    _updateDBCountNotifier.incrementState();
  }

  // 小カテゴリーの編集処理
  Future<void> smallEdit(
      {required List<EditExpenseSmallCategoryValue> originalValues,
      required List<EditExpenseSmallCategoryValue> editValues}) async {
    //エラーチェック
    if (originalValues.length > editValues.length) {
      // リストの長さが一致しない場合
      throw const AppException('予期せぬエラーが発生しました(E001)');
    }

    // カテゴリーID順に並べてfor文で扱いやすくする
    // 追加カテゴリーは-1で入力されるため、ID順に並べると-1が先頭に来てしまう
    // そのため、IDの降順で並べる
    originalValues.sort((a, b) => b.id.compareTo(a.id));
    editValues.sort((a, b) => b.id.compareTo(a.id));

    for (var i = 0; i < originalValues.length; i++) {
      // 変更があればアップデートする
      if (originalValues[i] != editValues[i]) {
        final entity = ExpenseSmallCategoryEntity(
            id: editValues[i].id,
            bigCategoryKey: editValues[i].bigCategoryKey,
            smallCategoryName: editValues[i].name,
            smallCategoryOrderKey: editValues[i].smallCategoryOrderKey,
            displayedOrderInBig: editValues[i].editedStateDisplayOrder,
            defaultDisplayed: editValues[i].etitedStateIsChecked ? 1 : 0);

        // 小カテゴリーを更新する
        _smallCategoryRepositoryProvider.update(entity: entity);
      }
    }

    // 編集後の要素の方が多い場合は、追加された要素があると考えられる
    if (originalValues.length < editValues.length) {
      // 追加された要素を取得する
      final addedElements = editValues.sublist(originalValues.length);

      // 現在の最大smallCategoryOrderKeyを取得する
      int maxOrderKey =
          await _smallCategoryRepositoryProvider.getMaxSmallCategoryOrderKey(
              bigCategoryId: addedElements.first.bigCategoryKey);

      // 追加された要素をDBに保存する
      for (var element in addedElements) {
        // 最大値 + 1 で新しいsmallCategoryOrderKeyを設定
        maxOrderKey++;
        final entity = ExpenseSmallCategoryEntity(
            id: element.id,
            bigCategoryKey: element.bigCategoryKey,
            smallCategoryName: element.name,
            smallCategoryOrderKey: maxOrderKey,
            displayedOrderInBig: element.editedStateDisplayOrder,
            defaultDisplayed: element.etitedStateIsChecked ? 1 : 0);

        await _smallCategoryRepositoryProvider.add(entity: entity);
      }
    }

    // DBの更新回数をインクリメント
    _updateDBCountNotifier.incrementState();
  }

  // 大カテゴリーの追加処理
  Future<int> addBig(ExpenseBigCategoryEntity entity) async {
    // 小カテゴリーの追加は、リポジトリのaddメソッドを呼び出す
    final addedBigId = await _bigCategoryRepositoryProvider.add(entity: entity);

    // DBの更新回数をインクリメント
    _updateDBCountNotifier.incrementState();

    // 追加された大カテゴリーのIDを返す
    return addedBigId;
  }

  // 小カテゴリーの追加処理
  Future<void> addSmall(ExpenseSmallCategoryEntity entity) async {
    // 受け取ったentityのsmallCategoryOrderKeyは仮の値であるため、表示順の最大値を取得する
    final maxOrderKey = await _smallCategoryRepositoryProvider
        .getMaxSmallCategoryOrderKey(bigCategoryId: entity.bigCategoryKey);

    // 既存の最大値 + 1 で新しいsmallCategoryOrderKeyを設定
    final newEntity = ExpenseSmallCategoryEntity(
      id: entity.id,
      bigCategoryKey: entity.bigCategoryKey,
      smallCategoryName: entity.smallCategoryName,
      smallCategoryOrderKey: maxOrderKey + 1,
      displayedOrderInBig: entity.displayedOrderInBig,
      defaultDisplayed: entity.defaultDisplayed,
    );

    // 小カテゴリーの追加は、リポジトリのaddメソッドを呼び出す
    await _smallCategoryRepositoryProvider.add(entity: newEntity);

    // DBの更新回数をインクリメント
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

      final updatedEntity = ExpenseSmallCategoryEntity(
        id: smallCategory.id,
        smallCategoryOrderKey: newOrder,
        bigCategoryKey: smallCategory.bigCategoryKey,
        displayedOrderInBig: smallCategory.displayedOrderInBig,
        smallCategoryName: smallCategory.smallCategoryName,
        defaultDisplayed: smallCategory.defaultDisplayed,
      );

      await _smallCategoryRepositoryProvider.update(entity: updatedEntity);
    }

    // DBの更新回数をインクリメント
    _updateDBCountNotifier.incrementState();
  }
}
