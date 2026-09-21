import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/unconfirmed_fixed_cost_prompt/unconfirmed_fixed_cost_prompt_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

/// 起動時の促しの対象（支払日が現在の月度より前の月度にある未確定行）
///
/// 確定・削除で対象が減るため、DBの更新を監視して取り直す。
final launchUnconfirmedFixedCostTargetsProvider =
    FutureProvider.autoDispose<List<MonthlyUnconfirmedFixedCostTileValue>>((
      ref,
    ) async {
      ref.watch(updateDBCountNotifierProvider);
      return ref
          .read(unconfirmedFixedCostPromptUsecaseProvider)
          .fetchLaunchPromptTargets();
    });

/// 指定した月度の注意バナーの対象（支払日から3日経過した未確定行）
final overdueUnconfirmedFixedCostTargetsProvider = FutureProvider.autoDispose
    .family<List<MonthlyUnconfirmedFixedCostTileValue>, PeriodValue>((
      ref,
      shownPeriod,
    ) async {
      ref.watch(updateDBCountNotifierProvider);
      return ref
          .read(unconfirmedFixedCostPromptUsecaseProvider)
          .fetchOverdueTargets(shownPeriod: shownPeriod);
    });
