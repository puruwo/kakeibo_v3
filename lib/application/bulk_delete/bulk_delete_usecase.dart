import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/bulk_delete/bulk_delete_mode.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_usecase.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/income/income_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final bulkDeleteUsecaseProvider = Provider<BulkDeleteUsecase>(
  BulkDeleteUsecase.new,
);

/// 支出・収入レコードをまとめて削除するユースケース（KP-031）
///
/// 選択した ID をリポジトリの `deleteByIds`（1トランザクション）で削除する。
/// 支出に確定済みの固定費行が含まれていたら、そのマスタごとに1回だけ推定額を再計算する
/// （1件削除の FixedCostRecordUsecase.delete と同じ規則。仕様 §4）。
class BulkDeleteUsecase {
  BulkDeleteUsecase(this._ref);
  final Ref _ref;

  ExpenseRepository get _expenseRepository =>
      _ref.read(expenseRepositoryProvider);

  IncomeRepository get _incomeRepository => _ref.read(incomeRepositoryProvider);

  FixedCostUsecase get _fixedCostUsecase => _ref.read(fixedCostUsecaseProvider);

  UpdateDBCountNotifier get _updateDBCountNotifier =>
      _ref.read(updateDBCountNotifierProvider.notifier);

  /// [mode] の種別のレコードを [ids] でまとめて削除する。空なら何もしない
  Future<void> delete({
    required BulkDeleteMode mode,
    required List<int> ids,
  }) async {
    if (ids.isEmpty) return;
    switch (mode) {
      case BulkDeleteMode.expense:
        await _deleteExpenses(ids);
      case BulkDeleteMode.income:
        await _deleteIncomes(ids);
    }
  }

  Future<void> _deleteExpenses(List<int> ids) async {
    // 再計算の要否判定に必要なので、削除前に対象行を読む（確定済みの固定費行が属するマスタ）
    final idSet = ids.toSet();
    final all = await _expenseRepository.fetchAll();
    final fixedCostIdsToRecalculate = <int>{
      for (final e in all)
        if (idSet.contains(e.id) && e.isConfirmed == 1 && e.fixedCostId != null)
          e.fixedCostId!,
    };

    await _expenseRepository.deleteByIds(ids);

    // 確定済み行の削除で平均の根拠が変わるため、マスタごとに1回再計算する
    for (final fixedCostId in fixedCostIdsToRecalculate) {
      await _fixedCostUsecase.updateEstimatedPrice(fixedCostId: fixedCostId);
    }

    // DBの更新回数をインクリメント（一覧と開いた元の画面が取り直す）
    _updateDBCountNotifier.incrementState();
  }

  Future<void> _deleteIncomes(List<int> ids) async {
    await _incomeRepository.deleteByIds(ids);
    _updateDBCountNotifier.incrementState();
  }
}
