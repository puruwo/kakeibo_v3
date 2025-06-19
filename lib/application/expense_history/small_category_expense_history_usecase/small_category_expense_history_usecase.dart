import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:kakeibo/application/expense_history/expense_history_service.dart';
import 'package:kakeibo/application/expense_history/small_category_expense_history_usecase/request_small_expense_history.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_group_value.dart';

import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// 支出タイルのValueを小カテゴリー指定して取得し、日付ごとにグループ分けして返却するプロバイダ

final smallCategoryExpenseHistoryNotifierProvider =
    AsyncNotifierProvider.family<SmallCategoryExpenseHistoryUsecaseNotifier,
        List<ExpenseHistoryTileGroupValue>, RequestSmallExpenseHistory>(
  SmallCategoryExpenseHistoryUsecaseNotifier.new,
);

class SmallCategoryExpenseHistoryUsecaseNotifier extends FamilyAsyncNotifier<
    List<ExpenseHistoryTileGroupValue>, RequestSmallExpenseHistory> {
  @override
  Future<List<ExpenseHistoryTileGroupValue>> build(
      RequestSmallExpenseHistory request) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    final _service = ExpenseHistoryService(
      expenseRepo: ref.read(expenseRepositoryProvider),
      smallCategoryRepo: ref.read(expenseSmallCategoryRepositoryProvider),
      bigCategoryRepo: ref.read(expensebigCategoryRepositoryProvider),
    );

    // 小カテゴリーIdを指定して、月次支出のタイル情報を取得する
    final records = await _service.fetchTileList(0, request.monthPeriodValue,
        smallId: request.smallId);

    // 取得したタイルデータをDateTimeでグループ分けする
    // groupListsByは、List<T>をMap<K, List<T>>に変換するメソッド
    final grouped = records.groupListsBy<DateTime>((e) => e.date);

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
