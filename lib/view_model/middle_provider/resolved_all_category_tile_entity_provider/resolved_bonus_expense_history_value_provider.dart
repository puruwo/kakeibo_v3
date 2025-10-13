import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/expense_history/bonus_expense_history_digest_usecase.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';

import 'package:kakeibo/view_model/state/date_scope/analyze_page/date_scope.dart';

final resolvedBonusExpenseHistoryValueProvider =
    FutureProvider<List<ExpenseHistoryTileValue>>((ref) async {
  
  // 選択された日付から集計期間を取得する
  final yearPeriodValue = await ref.watch(dateScopeEntityProvider.selectAsync((data) => data.yearPeriod));
  
  // 選択された集計期間を元に、Entityを取得する
  final result = ref.watch(bonusExpenseHistoryDigestNotifierProvider(yearPeriodValue).future);
  return result;
});
