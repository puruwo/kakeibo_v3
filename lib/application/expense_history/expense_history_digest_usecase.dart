import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/expense_history/expense_history_service.dart';

import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// 支出タイルのValueを取得し、日付ごとにグループ分けせずにそのままリストで返却するプロバイダ

final expenseHistoryDigestNotifierProvider = AsyncNotifierProvider.family<
    ExpenseHistoryUsecaseNotifier,
    List<ExpenseHistoryTileValue>,
    PeriodValue>(
  ExpenseHistoryUsecaseNotifier.new,
);

class ExpenseHistoryUsecaseNotifier extends FamilyAsyncNotifier<
    List<ExpenseHistoryTileValue>, PeriodValue> {

  @override
  Future<List<ExpenseHistoryTileValue>> build(
      PeriodValue selectedMonthPeriod) async {
    
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    final _service = ExpenseHistoryService(
      expenseRepo: ref.read(expenseRepositoryProvider),
      smallCategoryRepo: ref.read(expenseSmallCategoryRepositoryProvider),
      bigCategoryRepo: ref.read(expensebigCategoryRepositoryProvider),
    );

    // incomeSourceBigIdは0を指定して、月次支出のみを取得する
    final entities = await _service.fetchTileList(0,selectedMonthPeriod);

    return entities;
  }
}
