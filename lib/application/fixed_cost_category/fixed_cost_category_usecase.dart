import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final fixedCostCategoryUsecaseProvider = Provider<FixedCostCategoryUsecase>(
  FixedCostCategoryUsecase.new,
);

class FixedCostCategoryUsecase {
  FixedCostCategoryUsecase(this._ref);
  final Ref _ref;

  FixedCostCategoryRepository get _fixedCostCategoryRepository =>
      _ref.read(fixedCostCategoryRepositoryProvider);

  // DBの更新を管理するnotifierを取得
  UpdateDBCountNotifier get updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

  // 全件取得
  Future<List<FixedCostCategoryEntity>> fetchAll() async {
    return await _fixedCostCategoryRepository.fetchAll();
  }

  // ID指定取得
  Future<FixedCostCategoryEntity> fetch({required int id}) async {
    return await _fixedCostCategoryRepository.fetch(id: id);
  }

  // 登録処理
  Future<void> add({required FixedCostCategoryEntity entity}) async {
    // エラーチェック
    if (entity.categoryName.isEmpty) {
      throw const AppException('カテゴリー名を入力してください');
    }

    // データを追加
    await _fixedCostCategoryRepository.insert(entity);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }

  // 編集処理
  Future<void> edit({
    required FixedCostCategoryEntity originalEntity,
    required FixedCostCategoryEntity editEntity,
  }) async {
    // エラーチェック
    if (originalEntity == editEntity) {
      throw const AppException('変更がありません');
    }
    if (editEntity.categoryName.isEmpty) {
      throw const AppException('カテゴリー名を入力してください');
    }

    // データを更新
    await _fixedCostCategoryRepository.update(editEntity);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }

  // 削除処理
  Future<void> delete({required int id}) async {
    await _fixedCostCategoryRepository.delete(id);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }

  // 表示・非表示切り替え（一旦メソッドだけ用意）
  Future<void> toggleDisplay(
      {required int id, required int isDisplayed}) async {
    final entity = await _fixedCostCategoryRepository.fetch(id: id);
    final updatedEntity = entity.copyWith(isDisplayed: isDisplayed);
    await _fixedCostCategoryRepository.update(updatedEntity);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }

  // 並び順変更（一旦メソッドだけ用意）
  Future<void> updateDisplayOrder({
    required List<FixedCostCategoryEntity> entities,
  }) async {
    for (var i = 0; i < entities.length; i++) {
      final updatedEntity = entities[i].copyWith(displayOrder: i);
      await _fixedCostCategoryRepository.update(updatedEntity);
    }

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }

  // 並び順変更（一旦メソッドだけ用意）
  Future<FixedCostCategoryEntity> fetchCategoryById(
    int id,
  ) async {
    return await _fixedCostCategoryRepository.fetch(id: id);
  }

  /// 表示順を一括更新（並び替え画面用）
  /// [newOrders] は { カテゴリーID: 新しい表示順 } のMap
  Future<void> updateDisplayOrders(Map<int, int> newOrders) async {
    for (final entry in newOrders.entries) {
      final categoryId = entry.key;
      final newOrder = entry.value;

      final entity = await _fixedCostCategoryRepository.fetch(id: categoryId);
      final updatedEntity = entity.copyWith(displayOrder: newOrder);
      await _fixedCostCategoryRepository.update(updatedEntity);
    }

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }
}
