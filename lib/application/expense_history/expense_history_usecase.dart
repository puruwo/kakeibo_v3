import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:collection/collection.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_group_value.dart';
import 'dart:collection';

import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

final expenseHistoryNotifierProvider = AsyncNotifierProvider.family<
    ExpenseHistoryUsecaseNotifier,
    List<ExpenseHistoryTileGroupValue>,
    MonthPeriodValue>(
  ExpenseHistoryUsecaseNotifier.new,
);

class ExpenseHistoryUsecaseNotifier extends FamilyAsyncNotifier<
    List<ExpenseHistoryTileGroupValue>, MonthPeriodValue> {
  // tbl001(支出履歴)に関するリポジトリ
  late ExpenseRepository _expenseRepositoryProvider;

  // tbl201(小カテゴリー)に関するリポジトリ
  late ExpenseSmallCategoryRepository _smallCategoryRepository;

  // tbl202(大カテゴリー)に関するリポジトリ
  late ExpenseBigCategoryRepository _bigCategoryRepository;

  @override
  Future<List<ExpenseHistoryTileGroupValue>> build(
      MonthPeriodValue selectedMonthPeriod) async {

    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _expenseRepositoryProvider = ref.read(expenseRepositoryProvider);

    _smallCategoryRepository = ref.read(expenseSmallCategoryRepositoryProvider);

    _bigCategoryRepository = ref.read(expensebigCategoryRepositoryProvider);

    return fetch(selectedMonthPeriod: selectedMonthPeriod);
  }

  // 前カテゴリー合計のタイルデータを取得する
  Future<List<ExpenseHistoryTileGroupValue>> fetch({required MonthPeriodValue selectedMonthPeriod}) async {
    
    // tbl001からデータを取得する
    final expenseList = await _expenseRepositoryProvider.fetchWithoutCategory(period: selectedMonthPeriod);

    // 取得した支出データから、それぞれカテゴリーなどの情報を取得し、タイルのデータを作成する
    List<ExpenseHistoryTileValue> tileList = [];

    for (var expense in expenseList) {
      // 支出のレコードからカテゴリーidを取得し、小カテゴリーの情報を取得する
      final smallCategory =
          await _smallCategoryRepository.fetchBySmallCategory(smallCategoryId: expense.paymentCategoryId);

      // 小カテゴリーのレコードから大カテゴリーidを取得し、大カテゴリーの情報を取得する
      final bigCategory =
          await _bigCategoryRepository.fetchByBigCategory(bigCategoryId: smallCategory.bigCategoryKey);

      final expenseHistoryTileValue = ExpenseHistoryTileValue(
        id: expense.id,
        date: DateTime.parse(
        '${expense.date.substring(0, 4)}-${expense.date.substring(4, 6)}-${expense.date.substring(6, 8)}'),
        price: expense.price,
        paymentCategoryId: expense.paymentCategoryId,
        memo: expense.memo,
        smallCategoryName: smallCategory.smallCategoryName,
        bigCategoryName: bigCategory.bigCategoryName,
        colorCode: bigCategory.colorCode,
        iconPath: bigCategory.resourcePath,
      );

      tileList.add(expenseHistoryTileValue);
    }

    // 取得したタイルデータをDateTimeでグループ分けする
    // groupListsByは、List<T>をMap<K, List<T>>に変換するメソッド
    final grouped = tileList.groupListsBy<DateTime>((e) => e.date);

    //DateTimeで分けられたグループを、上から降順に並び替える
    //型指定してやらんとエラーになる、Object型で判定される
    SplayTreeMap<DateTime, List<ExpenseHistoryTileValue>> sortedGroup = SplayTreeMap.from(
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
