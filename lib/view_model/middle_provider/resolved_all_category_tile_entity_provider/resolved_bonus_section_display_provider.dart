import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/domain/ui_value/bonus_plan_value/bonus_section_display_type.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_annual_balance_chart_value_provider.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_bonus_plan_provider.dart';

/// ボーナス収支と生活収支グラフの状態を合成し、
/// ホーム画面ボーナスセクションの表示状態を決定する中間プロバイダ。
final resolvedBonusSectionDisplayProvider =
    FutureProvider<BonusSectionDisplayType>((ref) async {
  final bonusPlan = await ref.watch(resolvedBonusPlanValueProvider.future);
  final bonusEmpty =
      bonusPlan.yearlyBonusIncome == 0 && bonusPlan.yearlyBonusExpense == 0;

  if (!bonusEmpty) {
    return BonusSectionDisplayType.normal;
  }

  final chart =
      await ref.watch(resolvedAnnualBalanceChartValueProvider.future);
  if (chart.hasNoRecord) {
    return BonusSectionDisplayType.hidden;
  }

  return BonusSectionDisplayType.registerPrompt;
});
