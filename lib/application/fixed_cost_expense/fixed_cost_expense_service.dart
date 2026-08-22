import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final fixedCostExpenseServiceProvider = Provider<FixedCostExpenseService>(
  FixedCostExpenseService.new,
);

class FixedCostExpenseService {
  FixedCostExpenseService(this._ref);
  final Ref _ref;

  ExpenseRepository get _expenseRepositoryProvider =>
      _ref.read(expenseRepositoryProvider);

  // DBの更新を管理するnotifierを取得
  UpdateDBCountNotifier get updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

  /// 過去の固定費実績のカテゴリーを一斉変更する（仕様 §6.4）
  ///
  /// 実績はexpenseの固定費行になったため、1行ずつのupdateではなく
  /// fixed_cost_id を条件にした一括UPDATEで置き換える。
  Future<void> changeCategoryOfExistingRecord({
    required FixedCostEntity originalEntity,
    required int expenseSmallCategoryId,
  }) async {
    await _expenseRepositoryProvider.updateSmallCategoryByFixedCostId(
      fixedCostId: originalEntity.id!,
      expenseSmallCategoryId: expenseSmallCategoryId,
    );
  }
}
