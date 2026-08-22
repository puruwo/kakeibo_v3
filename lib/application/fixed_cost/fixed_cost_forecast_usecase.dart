import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_occurrence_service.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/ui_value/fixed_cost_forecast_value/fixed_cost_forecast_value.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

/// 対象期間の固定費見込みを大カテゴリー別に算出するユースケース（仕様 §7.3）
///
/// 予算の自動加算は廃止したため、見込みは合計に足し込まず参考表示にだけ使う。
/// 算出は [FixedCostOccurrenceService] の2段構え（実績行＋未生成分の周期展開）に委ねる。
final fixedCostForecastNotifierProvider =
    AsyncNotifierProvider.family<
      FixedCostForecastUsecaseNotifier,
      FixedCostForecastValue,
      PeriodValue
    >(FixedCostForecastUsecaseNotifier.new);

class FixedCostForecastUsecaseNotifier
    extends FamilyAsyncNotifier<FixedCostForecastValue, PeriodValue> {
  @override
  Future<FixedCostForecastValue> build(PeriodValue selectedMonthPeriod) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    final occurrenceService = ref.read(fixedCostOccurrenceServiceProvider);
    final smallCategoryRepo = ref.read(expenseSmallCategoryRepositoryProvider);
    final bigCategoryRepo = ref.read(expensebigCategoryRepositoryProvider);

    final occurrences = await occurrenceService.fetchOccurrences(
      period: selectedMonthPeriod,
    );

    // 小カテゴリー → 大カテゴリー の対応表を作る
    final smallCategories = await smallCategoryRepo.fetchAll();
    final smallToBig = <int, int>{
      for (final small in smallCategories) small.id: small.bigCategoryKey,
    };

    // 大カテゴリー別に集約する（予算の設定単位と粒度を合わせる。仕様 §7.3）
    final amountByBigCategory = <int, int>{};
    var total = 0;
    for (final occurrence in occurrences) {
      final bigCategoryId = smallToBig[occurrence.expenseSmallCategoryId];
      // 参照先が解決できない場合は大カテゴリー別の内訳に出せないが、
      // 合計からは落とさない（合計と内訳の差分として見えるようにする）
      total += occurrence.amount;
      if (bigCategoryId == null) continue;
      amountByBigCategory[bigCategoryId] =
          (amountByBigCategory[bigCategoryId] ?? 0) + occurrence.amount;
    }

    // 表示順は大カテゴリーの表示順に合わせる
    final bigCategories = await bigCategoryRepo.fetchAll();
    final byBigCategory = <FixedCostForecastByCategory>[];
    for (final bigCategory in bigCategories) {
      final amount = amountByBigCategory[bigCategory.id] ?? 0;
      // 見込み0円のカテゴリーには表示しない（仕様 §7.3）
      if (amount == 0) continue;
      byBigCategory.add(
        FixedCostForecastByCategory(
          expenseBigCategoryId: bigCategory.id,
          bigCategoryName: bigCategory.bigCategoryName,
          amount: amount,
        ),
      );
    }

    return FixedCostForecastValue(byBigCategory: byBigCategory, total: total);
  }
}
