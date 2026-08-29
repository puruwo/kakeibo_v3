import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/expense_history/expense_history_service.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/db/expense/expense_repository.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

/// 支出一覧画面（案件 UIデザイン改修 §6）のユースケース。
///
/// 指定期間（年度）の全支出（生活収支＋特別枠）を取得し、
/// 総支出とカテゴリー別の内訳（構成比・明細つき）にまとめる。
// 画面を閉じたら破棄する（updateDBCountをwatchするため、常駐させると
// DB更新のたびに年間全件の再取得が走り続ける）
final yearlyExpenseListNotifierProvider = AsyncNotifierProvider.autoDispose
    .family<
      YearlyExpenseListUsecaseNotifier,
      YearlyExpenseListValue,
      PeriodValue
    >(YearlyExpenseListUsecaseNotifier.new);

class YearlyExpenseListUsecaseNotifier
    extends
        AutoDisposeFamilyAsyncNotifier<YearlyExpenseListValue, PeriodValue> {
  @override
  Future<YearlyExpenseListValue> build(PeriodValue period) async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    final service = ExpenseHistoryService(
      expenseRepo: ref.read(expenseRepositoryProvider),
      smallCategoryRepo: ref.read(expenseSmallCategoryRepositoryProvider),
      bigCategoryRepo: ref.read(expensebigCategoryRepositoryProvider),
    );

    // 総支出（年間収支カード）と一致させるため、生活収支と特別枠の両方を含める
    final results = await Future.wait([
      service.fetchTileList(AccountTypeConstants.living, period),
      service.fetchTileList(AccountTypeConstants.special, period),
    ]);
    final allRows = [...results[0], ...results[1]]
      // 新しい記録が上（日付降順・同日はid降順）
      ..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        if (byDate != 0) return byDate;
        return b.id.compareTo(a.id);
      });

    final totalExpense = allRows.fold<int>(0, (sum, row) => sum + row.price);

    // 支出大カテゴリーごとに集計する（タイル値は大カテゴリー名で解決済み）
    final Map<String, List<ExpenseHistoryTileValue>> byCategory = {};
    for (final row in allRows) {
      byCategory.putIfAbsent(row.bigCategoryName, () => []).add(row);
    }

    final categories =
        [
            for (final entry in byCategory.entries)
              YearlyExpenseCategorySummary(
                bigCategoryName: entry.key,
                iconPath: entry.value.first.iconPath,
                colorCode: entry.value.first.colorCode,
                sum: entry.value.fold<int>(0, (sum, row) => sum + row.price),
                rows: entry.value,
              ),
          ]
          // 金額が大きい順（使い道の俯瞰が目的のため）
          ..sort((a, b) => b.sum.compareTo(a.sum));

    return YearlyExpenseListValue(
      totalExpense: totalExpense,
      allRows: allRows,
      categories: categories,
    );
  }
}

/// 支出一覧画面の表示値
class YearlyExpenseListValue {
  const YearlyExpenseListValue({
    required this.totalExpense,
    required this.allRows,
    required this.categories,
  });

  /// 期間の総支出（未確定の固定費は予想額で計上）
  final int totalExpense;

  /// 全明細（日付降順）
  final List<ExpenseHistoryTileValue> allRows;

  /// カテゴリー別の内訳（金額降順）
  final List<YearlyExpenseCategorySummary> categories;

  /// 生活収支の合計
  int get livingTotal => _sumBySource(allRows, AccountTypeConstants.living);

  /// 特別枠の合計
  int get specialTotal => _sumBySource(allRows, AccountTypeConstants.special);
}

/// 拠出元（生活収支/特別枠）を指定して明細を合計する
int _sumBySource(List<ExpenseHistoryTileValue> rows, int source) => rows
    .where((row) => row.incomeSourceBigCategory == source)
    .fold<int>(0, (sum, row) => sum + row.price);

/// カテゴリー1件分の内訳
class YearlyExpenseCategorySummary {
  const YearlyExpenseCategorySummary({
    required this.bigCategoryName,
    required this.iconPath,
    required this.colorCode,
    required this.sum,
    required this.rows,
  });

  final String bigCategoryName;
  final String iconPath;
  final String colorCode;
  final int sum;

  /// このカテゴリーの明細（日付降順）
  final List<ExpenseHistoryTileValue> rows;

  /// 総支出に対する構成比（0.0〜1.0）。総支出0のときは0
  double ratioOf(int totalExpense) =>
      totalExpense <= 0 ? 0 : sum / totalExpense;

  /// このカテゴリーの生活収支分の合計
  int get livingSum => _sumBySource(rows, AccountTypeConstants.living);

  /// このカテゴリーの特別枠分の合計
  int get specialSum => _sumBySource(rows, AccountTypeConstants.special);
}
