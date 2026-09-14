import 'package:flutter/material.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/core/category_entity/income_category_entity/income_category_entity.dart';

import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_repository.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_repository.dart';
import 'package:kakeibo/domain/ui_value/edit_income_small_category_list_value/edit_income_small_category_value.dart';
import 'package:kakeibo/domain/ui_value/income_big_category_value/edit_income_big_category_value.dart';
import 'package:kakeibo/theme/category_palette.dart';
import 'package:kakeibo/util/category_color_picker.dart';
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

  // DBの更新を管理するnotifierを取得
  UpdateDBCountNotifier get _updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

  /// [pickDefaultColorForNewBigCategory] は新規収入大カテゴリーの既定色を返す
  ///
  /// 既存の大カテゴリーが使っていない色のうち、収入スウォッチ順で先頭の色（KP-012 D-07）。
  Future<Color> pickDefaultColorForNewBigCategory() async {
    // 削除済みのカテゴリーの色は空いているものとして扱う（KP-024）
    final list = await _bigCategoryRepositoryProvider.fetchAllActive();
    return CategoryColorPicker.firstUnused(
      swatches: CategoryPalette.incomeSwatches,
      usedColorCodes: list.map((e) => e.colorCode),
    );
  }

  /// [fetchAllBigCategory] メソッドは、収入大カテゴリーを全て取得する
  Future<List<IncomeBigCategoryEntity>> fetchAllBigCategory() async {
    // 大カテゴリーを全て取得する
    final list = await _bigCategoryRepositoryProvider.fetchAll();

    return list;
  }

  /// [fetchAllCategory] メソッドは、収入カテゴリーを全て取得する
  Future<List<IncomeCategoryEntity>> fetchAllCategory() async {
    // 削除されていない小カテゴリーを取得する（入力画面・並び替えで使う。KP-024）
    final smallCategoryEntityList = await _smallCategoryRepositoryProvider
        .fetchAllActive();

    final results = <IncomeCategoryEntity>[];

    for (IncomeSmallCategoryEntity smallCategoryEntity
        in smallCategoryEntityList) {
      // 大カテゴリーを取得する
      final incomeBigCategoryEntity = await _bigCategoryRepositoryProvider
          .fetchByBigCategory(
            bigCategoryId: smallCategoryEntity.bigCategoryKey,
          );

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
      ((a, b) => a.smallCategoryOrderKey.compareTo(b.smallCategoryOrderKey)),
    );

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
    // 削除されていない大・小カテゴリーだけを設定画面に出す（KP-024）
    final list = await _bigCategoryRepositoryProvider.fetchAllActive();

    final bigCategoryList = <EditIncomeBigCategoryValue>[];

    for (var element in list) {
      final smallCategoryEntity = await _smallCategoryRepositoryProvider
          .fetchActiveByBigCategory(bigCategoryId: element.id);

      String smallCategoryNameText = '';
      for (var smallCategory in smallCategoryEntity) {
        smallCategoryNameText =
            '$smallCategoryNameText,${smallCategory.smallCategoryName}';
        if (smallCategoryNameText.startsWith(',')) {
          smallCategoryNameText = smallCategoryNameText.substring(1);
        }
      }

      bigCategoryList.add(
        EditIncomeBigCategoryValue(
          id: element.id,
          colorCode: element.colorCode,
          bigCategoryName: element.name,
          resourcePath: element.iconPath,
          incomeSmallCategoryList: smallCategoryEntity,
          incomeSmallCategoryNameText: smallCategoryNameText,
        ),
      );
    }

    bigCategoryList.sort((a, b) => a.id.compareTo(b.id));

    return bigCategoryList;
  }

  /// [fetchSmallCategoriesByBig] は bigId 指定で smallCategory の一覧を取得する
  Future<List<EditIncomeSmallCategoryValue>> fetchSmallCategoriesByBig(
    int bigCategoryId,
  ) async {
    // 削除されていない小カテゴリーのリストを取得する（KP-024）
    final fetchList = await _smallCategoryRepositoryProvider
        .fetchActiveByBigCategory(bigCategoryId: bigCategoryId);

    final resultList = <EditIncomeSmallCategoryValue>[];

    for (var element in fetchList) {
      resultList.add(
        EditIncomeSmallCategoryValue(
          id: element.id,
          bigCategoryKey: element.bigCategoryKey,
          name: element.smallCategoryName,
          smallCategoryOrderKey: element.smallCategoryOrderKey,
          displayOrderInBig: element.displayedOrderInBig,
          defaultDisplayed: element.defaultDisplayed,
          editedStateDisplayOrder: element.displayedOrderInBig,
          etitedStateIsChecked: element.defaultDisplayed == 1,
        ),
      );
    }

    resultList.sort(
      ((a, b) => a.displayOrderInBig.compareTo(b.displayOrderInBig)),
    );

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

  /// 大カテゴリー削除（既定カテゴリー: 月次収入・ボーナスは削除不可）
  ///
  /// 配下の小カテゴリーごと論理削除し、登録済みの収入は残す（KP-024。以前は収入レコードごと物理削除していた）
  Future<void> deleteBig(int bigId) async {
    if (IncomeBigCategoryConstants.isDefaultCategory(bigId)) {
      throw const AppException('このカテゴリーは削除できません');
    }

    // 小カテゴリーを論理削除
    await _smallCategoryRepositoryProvider.deleteByBigCategory(
      bigCategoryId: bigId,
    );

    // 大カテゴリーを論理削除
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

  /// 小カテゴリーの編集（並び替え・編集・追加・削除）
  ///
  /// [editValues] は編集中リスト（→ EdittingIncomeSmallCategoryListNotifier）で、
  /// まだDBに無い項目は id が負の一意な値、表示順は並びどおりの 0..n-1 になっている。
  /// 編集前の値との対応づけは id で行う（引数のリストは並べ替えない）。
  /// 編集前にあって編集中リストに無い項目は、画面で削除した小カテゴリーとして論理削除する（KP-024）。
  Future<void> smallEdit({
    required List<EditIncomeSmallCategoryValue> originalValues,
    required List<EditIncomeSmallCategoryValue> editValues,
  }) async {
    final originalById = {for (final value in originalValues) value.id: value};

    // id が負なら新規、0以上なら既存項目
    final addedValues = editValues.where((value) => value.id < 0).toList();
    final savedValues = editValues.where((value) => value.id >= 0).toList();
    final savedIds = savedValues.map((value) => value.id).toSet();
    final removedValues = originalValues
        .where((value) => !savedIds.contains(value.id))
        .toList();

    // 検証は書き込みを始める前に済ませる
    // （トランザクションを張っていないため、途中で投げるとDBが半端に書き換わる）
    for (final value in savedValues) {
      // 編集前に無いidが既存項目として来るのは想定外
      if (!originalById.containsKey(value.id)) {
        throw const AppException('予期せぬエラーが発生しました(E001)');
      }
    }
    if (removedValues.isNotEmpty) {
      // 入力画面で選べるカテゴリーが無くならないよう、最後の1件は残す
      if (editValues.isEmpty) {
        throw const AppException('小カテゴリーは1件以上必要です');
      }
      // 給与・ボーナスは収入追加の初期選択に使うため削除させない
      if (removedValues.any((value) => isDefaultSmallCategory(value.id))) {
        throw const AppException('既定の小カテゴリーは削除できません');
      }
    }

    for (final value in savedValues) {
      // 変更が無ければ書き込まない
      if (originalById[value.id] == value) {
        continue;
      }

      final entity = IncomeSmallCategoryEntity(
        id: value.id,
        bigCategoryKey: value.bigCategoryKey,
        smallCategoryName: value.name,
        smallCategoryOrderKey: value.smallCategoryOrderKey,
        displayedOrderInBig: value.editedStateDisplayOrder,
        defaultDisplayed: value.etitedStateIsChecked ? 1 : 0,
      );

      await _smallCategoryRepositoryProvider.update(entity: entity);
    }

    if (addedValues.isNotEmpty) {
      int maxOrderKey = await _smallCategoryRepositoryProvider
          .getMaxSmallCategoryOrderKey(
            bigCategoryId: addedValues.first.bigCategoryKey,
          );

      // 編集中リストの並び順で採番する
      for (final value in addedValues) {
        maxOrderKey++;
        final entity = IncomeSmallCategoryEntity(
          id: value.id,
          bigCategoryKey: value.bigCategoryKey,
          smallCategoryName: value.name,
          smallCategoryOrderKey: maxOrderKey,
          displayedOrderInBig: value.editedStateDisplayOrder,
          defaultDisplayed: value.etitedStateIsChecked ? 1 : 0,
        );

        await _smallCategoryRepositoryProvider.add(entity: entity);
      }
    }

    // 削除した小カテゴリーは行を消さずに論理削除する（登録済みの収入の参照先を残す）
    for (final value in removedValues) {
      await _smallCategoryRepositoryProvider.delete(id: value.id);
    }

    _updateDBCountNotifier.incrementState();
  }

  /// 削除させない既定の小カテゴリー（給与・ボーナス）かどうか（KP-024）
  static bool isDefaultSmallCategory(int id) =>
      id == IncomeSmallCategoryConstants.salary ||
      id == IncomeSmallCategoryConstants.bonus;

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
