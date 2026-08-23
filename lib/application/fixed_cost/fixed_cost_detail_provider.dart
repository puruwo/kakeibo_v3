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

/// 指定マスタの確定行（is_confirmed=1）の実額の平均を取得する
///
/// 確定型→変動型に切り替えた直後の予想額に使う（仕様 §6.5・§6.8）。
/// 確定行が0件のときは null。
final confirmedFixedCostPriceAverageProvider = FutureProvider.autoDispose
    .family<int?, int>((ref, fixedCostId) async {
  // DBが更新された場合に再取得する
  ref.watch(updateDBCountNotifierProvider);

  final average = await ref
      .read(expenseRepositoryProvider)
      .fetchConfirmedFixedCostPriceAverage(fixedCostId: fixedCostId);

  return average?.toInt();
});

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
