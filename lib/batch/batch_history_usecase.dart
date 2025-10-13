import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost/fixed_cost_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/batch_history/batch_history_entity.dart';
import 'package:kakeibo/domain/db/batch_history/batch_history_repository.dart';
import 'package:kakeibo/util/extension/datetime_extension.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/date_scope.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final batchProcessUsecaseProvider = Provider<BatchProcessUsecase>(
  BatchProcessUsecase.new,
);

class BatchProcessUsecase {
  BatchProcessUsecase(this._ref);
  final Ref _ref;

  BatchHistoryRepository get _batchHistoryRepositoryProvider =>
      _ref.read(batchHistoryRepositoryProvider);

  // 登録処理
  Future<bool> grobalBatchProscessing() async {
    final dateScope = await _ref.read(dateScopeEntityProvider.future);

    // 今の集計期間の終了日を取得
    final currentMonthEndDate = dateScope.monthPeriod.endDatetime;

    // batchHistoryをチェックして、最近のバッチ処理実行済み期間の最終日を取得
    final latestBatchProcessingDateString =
        await _batchHistoryRepositoryProvider.fetchLatestDate();
    DateTime latestBatchProcessingDate =
        latestBatchProcessingDateString.toDateTime();

    // 最近のバッチ処理実行済み期間の最終日が、今の集計期間の最終日以降の場合は何もしない
    if (currentMonthEndDate.isBefore(latestBatchProcessingDate) ||
        currentMonthEndDate.isAtSameMomentAs(latestBatchProcessingDate)) {
      return false;
    }

    // 最近のバッチ処理実行済み期間の最終日の翌日を開始日として、バッチ処理を実行する
    // 月ごとの支払い登録が最短繰り返し期間なので、実行する期間単位は月単位とする

    // バッチ実行済み最終日がmonthEndDateを超えるまで繰り返す
    while (currentMonthEndDate.isAfter(latestBatchProcessingDate)) {
      // バッチ開始日
      final start = latestBatchProcessingDate.add(const Duration(days: 1));

      // バッチ終了日
      // バッチ終了日は1ヶ月後の1日前とするが、現在のdateScopeの月の終了日を超えないようにする
      final end = currentMonthEndDate
              .isBefore(start.addMonths(1).add(const Duration(days: -1)))
          ? currentMonthEndDate
          : start.addMonths(1).add(const Duration(days: -1));

      // バッチ処理の開始日と終了日を設定
      final batchPeriod = PeriodValue(
        startDatetime: start,
        endDatetime: end,
      );

      // 月ごとのバッチ処理を実行
      await monthlyBatchProcess(periodValue: batchPeriod);

      // 最近のバッチ処理実行済み期間の最終日を更新
      latestBatchProcessingDate = batchPeriod.endDatetime;
    }

    return true;
  }

  Future<void> monthlyBatchProcess({required PeriodValue periodValue}) async {
    // =========バッチ処理==========
    // 月の変わり目に呼ばれる処理

    await _ref.read(fixedCostUsecaseProvider).addExpenseForFixedCost(
        periodValue); // その月に支払いがある固定費を取得し、expenseに支出データを追加する

    // ===========================

    // バッチ処理が行われたことを記録するため、batch_historyを更新する
    final insertEntity = BatchHistoryEntity(
        startDate: periodValue.startDatetime.toFormattedString(),
        endDate: periodValue.endDatetime.toFormattedString(),
        status: 1);
    _batchHistoryRepositoryProvider.insert(insertEntity);

    // DBの更新を管理するnotifierを取得
    final updateDBCountNotifier =
        _ref.read(updateDBCountNotifierProvider.notifier);

    // DBの更新回数を増やす
    updateDBCountNotifier.incrementState();
  }
}
