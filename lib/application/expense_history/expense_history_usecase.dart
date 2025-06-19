import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:collection/collection.dart';
import 'package:kakeibo/application/expense_history/expense_history_service.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_group_value.dart';
import 'dart:collection';

import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// 支出タイルのValueを取得し、日付ごとにグループ分けして返却するプロバイダ

final expenseHistoryGroupByDateNotifierProvider = AsyncNotifierProvider.family<
    ExpenseHistoryUsecaseNotifier,
    List<ExpenseHistoryTileGroupValue>,
    PeriodValue>(
  ExpenseHistoryUsecaseNotifier.new,
);

class ExpenseHistoryUsecaseNotifier extends FamilyAsyncNotifier<
    List<ExpenseHistoryTileGroupValue>, PeriodValue> {

  @override
  Future<List<ExpenseHistoryTileGroupValue>> build(
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

    // 取得したタイルデータをDateTimeでグループ分けする
    // groupListsByは、List<T>をMap<K, List<T>>に変換するメソッド
    final grouped = entities.groupListsBy<DateTime>((e) => e.date);

    //DateTimeで分けられたグループを、上から降順に並び替える
    //型指定してやらんとエラーになる、Object型で判定される
    SplayTreeMap<DateTime, List<ExpenseHistoryTileValue>> sortedGroup =
        SplayTreeMap.from(
            grouped, (DateTime key1, DateTime key2) => key2.compareTo(key1));

    final List<ExpenseHistoryTileGroupValue> result = [];

    // グループ分けされたExpenseHistoryTileValueを、さらに各グループ内でidによって降順で並び替える
    for (var aGroup in sortedGroup.entries) {
      // idによる降順で並び替え
      aGroup.value.sort(((a, b) => b.id.compareTo(a.id)));

      // グループ分けされ並べ替えたMapをExpenseHistoryTileGroupValueに変換する
      final buffGroup = ExpenseHistoryTileGroupValue(
        date: aGroup.key,
        expenseHistoryTileValueList: aGroup.value,
      );

      result.add(buffGroup);
    }

    return result;
  }
}
