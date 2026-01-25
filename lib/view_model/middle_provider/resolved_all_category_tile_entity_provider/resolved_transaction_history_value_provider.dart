import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/expense_history/historical_transaction_usecase.dart';
import 'package:kakeibo/domain/ui_value/daily_transaction_group/daily_transaction_group.dart';
import 'package:kakeibo/view_model/state/date_scope/historical_page/historical_date_scope.dart';

// historical系のページで利用する
// 全トランザクションデータ（支出、ボーナス支出、収入、固定費確定/未確定）を取得
final resolvedTransactionHistoryValueProvider =
    FutureProvider<List<DailyTransactionGroup>>((ref) async {
  // 月の期間だけを選択して監視する（selectedDateの変更では再読み込みしない）
  final monthPeriod = await ref.watch(
      historicalDateScopeEntityProvider.selectAsync((data) => data.monthPeriod));

  // 選択された月単位期間を元に、全トランザクションデータを取得する
  final result = await ref
      .watch(historicalTransactionNotifierProvider(monthPeriod).future);

  // 日付順にグループ分けして返す
  return groupTransactionsByDate(result);
});
