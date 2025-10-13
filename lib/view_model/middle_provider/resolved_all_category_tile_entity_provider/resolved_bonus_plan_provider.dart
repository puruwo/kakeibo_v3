import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/bonus_plan_usecase/bonus_plan_usecase.dart';
import 'package:kakeibo/domain/ui_value/bonus_plan_value/bonus_plan_value.dart';
import 'package:kakeibo/view_model/state/date_scope/home_page/home_date_scope.dart';

// カレンダーで表示されている選択期間を取得し、Valueを取得する中間プロバイダ
final resolvedBonusPlanValueProvider =
    FutureProvider<BonusPlanValue>((ref) async {

  // 選択された日付から集計期間を取得する
  final yearPeriodValue = await ref.watch(homeDateScopeEntityProvider.selectAsync((data) => data.yearPeriod));

  // 選択された集計期間を元に、Entityを取得する
  final value = ref.watch(bonusPlanNotifierProvider(yearPeriodValue).future);
  return value;
});
