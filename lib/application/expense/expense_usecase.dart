import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_usecase.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final expenseUsecaseProvider = Provider<ExpenseUsecase>(
  ExpenseUsecase.new,
);

class ExpenseUsecase {
  ExpenseUsecase(this._ref);
  final Ref _ref;

  ExpenseRepository get _expenseRepositoryProvider =>
      _ref.read(expenseRepositoryProvider);

  FixedCostUsecase get _fixedCostUsecaseProvider =>
      _ref.read(fixedCostUsecaseProvider);


  // DBの更新を管理するnotifierを取得
  UpdateDBCountNotifier get updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

  // 登録処理
  Future<void> add({required ExpenseEntity expenseEntity}) async {
    
    //エラーチェック
    if (expenseEntity.price <= 0) {
      throw const AppException('0円以上で入力してください');
    }
    if (expenseEntity.price >= 1888888) {
      throw const AppException('金額の入力値が大き過ぎます');
    }

    // tbl001にデータを追加する
    _expenseRepositoryProvider.insert(expenseEntity);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();

  }

  // 編集処理
  Future<void> edit(
      {required ExpenseEntity originalEntity,
      required ExpenseEntity editEntity}) async {

    //エラーチェック
    if (originalEntity == editEntity) {
      // 変更がない場合は何もしない
      throw const AppException('変更がありません');
    }
    if (editEntity.price <= 0) {
      throw const AppException('0円以上で入力してください');
    }
    if (editEntity.price >= 1888888) {
      throw const AppException('金額の入力値が大き過ぎます');
    }

    // tbl001にデータを追加する
    _expenseRepositoryProvider.update(editEntity);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }

  /// 確定していない固定費の支出を更新する
  Future<void> updateUnconfirmedCost({
    required int id,
    required int confirmedPrice,
    required int fixedCostId,
  }) async {

    // エラーチェック 
    if (confirmedPrice <= 0) {
      throw const AppException('0円以上で入力してください');
    }
    if (confirmedPrice >= 1888888) {
      throw const AppException('金額の入力値が大き過ぎます');
    }

    // 確定していない固定費の支出を更新する
    await _expenseRepositoryProvider.updateUnconfirmedCost(
      id: id,
      confirmedPrice: confirmedPrice,
    );

    // 確定した変動固定費の推定金額を更新する
    await _fixedCostUsecaseProvider.updateEstimatedPrice(fixedCostId: fixedCostId);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }

  Future<void> delete({required int id}) async {
    // tbl001にデータを削除する
    _expenseRepositoryProvider.delete(id);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }
}
