import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

/// 固定費の設定画面・固定費行の編集シートで使う読み取り系プロバイダー（仕様 §6.6・§6.7）

/// 固定費マスタを1件取得する
final fixedCostByIdProvider =
    FutureProvider.autoDispose.family<FixedCostEntity, int>((ref, id) async {
  // DBが更新された場合に再取得する
  ref.watch(updateDBCountNotifierProvider);

  return await ref.read(fixedCostRepositoryProvider).fetch(fixedCostId: id);
});

/// 固定費の設定画面の「支払い履歴」に出す件数
const int kFixedCostPaymentHistoryLimit = 5;

/// 指定マスタの支払い履歴（直近 [kFixedCostPaymentHistoryLimit] 件）を取得する
final fixedCostPaymentHistoryProvider = FutureProvider.autoDispose
    .family<List<ExpenseEntity>, int>((ref, fixedCostId) async {
  // DBが更新された場合に再取得する
  ref.watch(updateDBCountNotifierProvider);

  return await ref.read(expenseRepositoryProvider).fetchByFixedCostId(
        fixedCostId: fixedCostId,
        limit: kFixedCostPaymentHistoryLimit,
      );
});
