import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_usecase.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/view/component/app_exception.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final fixedCostExpenseUsecaseProvider = Provider<FixedCostExpenseUsecase>(
  FixedCostExpenseUsecase.new,
);

class FixedCostExpenseUsecase {
  FixedCostExpenseUsecase(this._ref);
  final Ref _ref;

  FixedCostExpenseRepository get _fixedCostExpenseRepositoryProvider =>
      _ref.read(fixedCostExpenseRepositoryProvider);

  FixedCostUsecase get _fixedCostUsecaseRepositoryProvider =>
      _ref.read(fixedCostUsecaseProvider);

  // DBの更新を管理するnotifierを取得
  UpdateDBCountNotifier get updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

  /// 未確定の固定費支出を確定させる
  Future<void> confirmExpense({
    required MonthlyUnconfirmedFixedCostTileValue tileValue,
    required int confirmedPrice,
  }) async {
    // エラーチェック
    if (confirmedPrice <= 0) {
      throw const AppException('0円以上で入力してください');
    }
    if (confirmedPrice >= 1888888) {
      throw const AppException('金額の入力値が大き過ぎます');
    }

    // 未確定の固定費支出を確定させる
    await _fixedCostExpenseRepositoryProvider.confirmExpense(
      id: tileValue.id,
      price: confirmedPrice,
    );

    _fixedCostUsecaseRepositoryProvider.updateEstimatedPrice(
        fixedCostId: tileValue.fixedCostId);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }

  /// 固定費支出を削除する
  Future<void> delete({required int id}) async {
    await _fixedCostExpenseRepositoryProvider.delete(id);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }

  /// 固定費支出を編集する
  Future<void> edit({
    required FixedCostExpenseEntity entity,
  }) async {
    // エラーチェック
    if (entity.price <= 0) {
      throw const AppException('0円以上で入力してください');
    }
    if (entity.price >= 1888888) {
      throw const AppException('金額の入力値が大き過ぎます');
    }

    // 固定費支出を更新する
    await _fixedCostExpenseRepositoryProvider.update(entity);

    // DBの更新回数をインクリメント
    updateDBCountNotifier.incrementState();
  }
}
