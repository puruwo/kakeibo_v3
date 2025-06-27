import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/yearly_balance_usecase/yearly_balance_usecase.dart';
import 'package:kakeibo/domain/ui_value/yearly_balance_value/yearly_balance_value.dart';
import 'package:kakeibo/view_model/state/date_scope/date_scope.dart';

// カレンダーで表示されている選択期間を取得し、Entityを取得する中間プロバイダ
final resolvedYearlyBalanceValueProvider =
    FutureProvider<YearlyBalanceValue>((ref) async {

  // 選択された日付から集計期間を取得する
  final dateScope = await ref.watch(dateScopeEntityProvider.selectAsync((dateScope) => dateScope));

  // 選択された集計期間を元に、Entityを取得する
  final value = ref.watch(yearlyBalanceNotifierProvider(dateScope).future);
  return value;
});
