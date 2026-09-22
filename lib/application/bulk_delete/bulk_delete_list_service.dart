import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/income/income_entity.dart';
import 'package:kakeibo/domain/db/income_big_category/income_big_category_entity.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';
import 'package:kakeibo/domain/ui_value/daily_transaction_group/daily_transaction_group.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/domain/ui_value/income_history_tile_value/income_history_tile_value.dart';

// 一括削除の一覧を組み立てる純粋関数群（KP-031）
//
// 全履歴を対象にするため、既存の ExpenseHistoryService / IncomeHistoryService のように
// 1行ごとにカテゴリーを問い合わせる（N+1）形は使わず、呼び出し側が全件取得した
// カテゴリーを Map で引く（仕様 §5）。
// 参照先のカテゴリーが無い行も落とさない（名前は空・アイコンは無し）。
// 論理削除済みのカテゴリー（delete_flag=1）は fetchAll に含まれるため、そのまま名前が出る。

/// DB上の日付文字列（yyyyMMdd）を日付だけの DateTime に変換する
///
/// 形式が崩れている行は 1970/1/1 に寄せて末尾に出す（削除対象から外さないため）。
DateTime parseRecordDate(String yyyyMMdd) {
  if (yyyyMMdd.length != 8) return DateTime(1970, 1, 1);
  final parsed = DateTime.tryParse(
    '${yyyyMMdd.substring(0, 4)}-${yyyyMMdd.substring(4, 6)}-${yyyyMMdd.substring(6, 8)}',
  );
  return parsed ?? DateTime(1970, 1, 1);
}

/// 支出の全行からタイル値を組む
List<ExpenseHistoryTileValue> buildBulkDeleteExpenseTiles({
  required List<ExpenseEntity> expenses,
  required List<ExpenseSmallCategoryEntity> smallCategories,
  required List<ExpenseBigCategoryEntity> bigCategories,
}) {
  final smallById = {for (final s in smallCategories) s.id: s};
  final bigById = {for (final b in bigCategories) b.id: b};

  return [
    for (final expense in expenses)
      () {
        final small = smallById[expense.paymentCategoryId];
        final big = small == null ? null : bigById[small.bigCategoryKey];
        return ExpenseHistoryTileValue(
          id: expense.id,
          date: parseRecordDate(expense.date),
          price: expense.effectivePrice,
          paymentCategoryId: expense.paymentCategoryId,
          memo: expense.memo,
          smallCategoryName: small?.smallCategoryName ?? '',
          bigCategoryId: big?.id ?? 0,
          bigCategoryName: big?.bigCategoryName ?? '',
          colorCode: big?.colorCode ?? '',
          iconPath: big?.resourcePath ?? '',
          incomeSourceBigCategory: expense.incomeSourceBigCategory,
          fixedCostId: expense.fixedCostId,
          isConfirmed: expense.isConfirmed,
        );
      }(),
  ];
}

/// 収入の全行からタイル値を組む
List<IncomeHistoryTileValue> buildBulkDeleteIncomeTiles({
  required List<IncomeEntity> incomes,
  required List<IncomeSmallCategoryEntity> smallCategories,
  required List<IncomeBigCategoryEntity> bigCategories,
}) {
  final smallById = {for (final s in smallCategories) s.id: s};
  final bigById = {for (final b in bigCategories) b.id: b};

  return [
    for (final income in incomes)
      () {
        final small = smallById[income.categoryId];
        final big = small == null ? null : bigById[small.bigCategoryKey];
        return IncomeHistoryTileValue(
          id: income.id,
          date: parseRecordDate(income.date),
          price: income.price,
          paymentCategoryId: income.categoryId,
          memo: income.memo,
          smallCategoryName: small?.smallCategoryName ?? '',
          bigCategoryId: big?.id ?? 0,
          bigCategoryName: big?.name ?? '',
          colorCode: big?.colorCode ?? '',
          iconPath: big?.iconPath ?? '',
        );
      }(),
  ];
}

/// 日付だけのキーでまとめる（時刻は落とす）
Map<DateTime, List<T>> _groupByDate<T>(
  List<T> items,
  DateTime Function(T) dateOf,
) {
  final grouped = <DateTime, List<T>>{};
  for (final item in items) {
    final d = dateOf(item);
    grouped.putIfAbsent(DateTime(d.year, d.month, d.day), () => []).add(item);
  }
  return grouped;
}

/// 支出タイルを日付ごとにまとめる（日付降順・同じ日の中は ID 降順。履歴タブと同じ並び）
List<DailyTransactionGroup> groupBulkDeleteExpenseTiles(
  List<ExpenseHistoryTileValue> tiles,
) {
  final grouped = _groupByDate(tiles, (t) => t.date);
  final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final date in dates)
      DailyTransactionGroup(
        date: date,
        expenses: grouped[date]!..sort((a, b) => b.id.compareTo(a.id)),
      ),
  ];
}

/// 収入タイルを日付ごとにまとめる（日付降順・同じ日の中は ID 降順）
List<DailyTransactionGroup> groupBulkDeleteIncomeTiles(
  List<IncomeHistoryTileValue> tiles,
) {
  final grouped = _groupByDate(tiles, (t) => t.date);
  final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final date in dates)
      DailyTransactionGroup(
        date: date,
        incomes: grouped[date]!..sort((a, b) => b.id.compareTo(a.id)),
      ),
  ];
}

/// 日付グループに含まれる全レコードの ID（支出モードは expenses、収入モードは incomes）
Set<int> collectBulkDeleteRecordIds(List<DailyTransactionGroup> groups) {
  return {
    for (final group in groups) ...[
      for (final e in group.expenses) e.id,
      for (final i in group.incomes) i.id,
    ],
  };
}
