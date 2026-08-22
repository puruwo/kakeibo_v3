import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/view/daily_expense_summary_page/parts/daily_expense_graph_area.dart';

part 'daily_expense_summary_value.freezed.dart';

/// 日次支出サマリーページ用のValueクラス
/// カテゴリー別グループ化、合計金額計算などをプロバイダー層で事前に処理済みのデータを保持
@freezed
class DailyExpenseSummaryValue with _$DailyExpenseSummaryValue {
  factory DailyExpenseSummaryValue({
    /// 対象日
    required DateTime date,

    /// カテゴリー別にグループ化された支出（固定費行も含む）
    required List<ExpenseCategoryGroup> expensesByCategory,

    /// 変動費（固定費以外の支出）合計
    required int variableExpenseTotal,

    /// 固定費合計（未確定は予想額で計上）
    required int fixedCostTotal,

    /// 固定費のうち未確定分の合計
    required int unconfirmedFixedCostTotal,

    /// 総支出
    required int totalExpense,

    /// データがない場合true
    required bool hasNoData,

    /// グラフ用カテゴリーサマリー
    required List<CategorySummary> categorySummaries,
  }) = _DailyExpenseSummaryValue;
}

/// カテゴリー別にグループ化された支出
@freezed
class ExpenseCategoryGroup with _$ExpenseCategoryGroup {
  factory ExpenseCategoryGroup({
    /// カテゴリー名（大カテゴリー）
    required String categoryName,

    /// カテゴリーアイコンパス
    required String iconPath,

    /// カテゴリー色コード
    required String colorCode,

    /// このカテゴリーに属する支出リスト（固定費行も含む）
    required List<ExpenseHistoryTileValue> expenses,

    /// カテゴリー内の支出合計
    required int categoryTotal,
  }) = _ExpenseCategoryGroup;
}
