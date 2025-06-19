import 'dart:collection';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:kakeibo/application/expense_history/expense_history_service.dart';
import 'package:kakeibo/application/expense_history/request_expense_history.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_group_value.dart';

import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// 支出タイルのValueを小カテゴリー指定して取得し、日付ごとにグループ分けして返却するプロバイダ

final categoryExpenseHistoryNotifierProvider = AsyncNotifierProvider.family<
    CategoryExpenseHistoryUsecaseNotifier,
    List<ExpenseHistoryTileGroupValue>,
    RequestExpenseHistory>(
  CategoryExpenseHistoryUsecaseNotifier.new,
);

class CategoryExpenseHistoryUsecaseNotifier extends FamilyAsyncNotifier<
    List<ExpenseHistoryTileGroupValue>, RequestExpenseHistory> {
  @override
  Future<List<ExpenseHistoryTileGroupValue>> build(
      RequestExpenseHistory request) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    final _service = ExpenseHistoryService(
      expenseRepo: ref.read(expenseRepositoryProvider),
      smallCategoryRepo: ref.read(expenseSmallCategoryRepositoryProvider),
      bigCategoryRepo: ref.read(expensebigCategoryRepositoryProvider),
    );

    // 指定された大カテゴリーから項目のカテゴリーIdを取得する
    final smallCategoryIdList = await _service.smallCategoryRepo
        .fetchSmallCategoryIdListByBigCategoryId(bigCategoryId: request.bigId);

    final entities = <ExpenseHistoryTileValue>[];
    // 取得した小カテゴリーIdを元に、ExpenseHistoryTileValueのリストを取得する
    for (int i = 0; i < smallCategoryIdList.length; i++) {
      // 小カテゴリーIdを指定して、月次支出のタイル情報を取得する
      final records = await _service.fetchTileList(0, request.monthPeriodValue,
          smallId: smallCategoryIdList[i]);
      entities.addAll(records);
    }

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
