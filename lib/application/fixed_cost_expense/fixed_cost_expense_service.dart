import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost_expense/fixed_cost_expense_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final fixedCostExpenseServiceProvider = Provider<FixedCostExpenseService>(
  FixedCostExpenseService.new,
);

class FixedCostExpenseService {
  FixedCostExpenseService(this._ref);
  final Ref _ref;

  FixedCostExpenseRepository get _fixedCostExpenseRepositoryProvider =>
      _ref.read(fixedCostExpenseRepositoryProvider);

  // DBの更新を管理するnotifierを取得
  UpdateDBCountNotifier get updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

  /// 過去の固定費支出のカテゴリーを一斉変更する
  Future<void> changeCategoryOfExistingRecord({
    required FixedCostEntity originalEntity,
    required int fixedCostCategoryId,
  }) async {
    // fixedCostIdに一致するfixedCostExpenseのリストを取得する
    final List<FixedCostExpenseEntity> itemList =
        await _fixedCostExpenseRepositoryProvider.fetchFixedCostExpenseWithCostId(
            fixedCostId: originalEntity.id!);

    // それぞれのitemでカテゴリー修正のアップデートをする
    for(FixedCostExpenseEntity item in itemList){
      final newEntity = item.copyWith(fixedCostCategoryId: fixedCostCategoryId);
      await _fixedCostExpenseRepositoryProvider.update(newEntity);
    }
  }
}
