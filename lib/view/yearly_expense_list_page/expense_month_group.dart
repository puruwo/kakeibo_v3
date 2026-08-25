import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';

/// 支出明細の月ごとのまとまり（案件 UIデザイン改修 §6）
///
/// カテゴリー明細の月別アコーディオンで使う。
/// 年度期間は暦年をまたぐため、期間開始年と異なる年の月は「yyyy年M月」で示す。
class ExpenseMonthGroup {
  const ExpenseMonthGroup({
    required this.label,
    required this.total,
    required this.rows,
  });

  /// 月見出し（例: 「8月」「2027年1月」）
  final String label;

  /// この月の合計
  final int total;

  /// この月の明細（日付降順）
  final List<ExpenseHistoryTileValue> rows;

  /// 日付降順の明細リストを暦月ごとにまとめる
  static List<ExpenseMonthGroup> groupByMonth(
    List<ExpenseHistoryTileValue> rows, {
    required int periodStartYear,
  }) {
    final groups = <ExpenseMonthGroup>[];
    // rowsは日付降順なので、月キーの変わり目で区切るだけでよい
    String? currentKey;
    List<ExpenseHistoryTileValue> current = [];

    void closeGroup() {
      if (currentKey == null || current.isEmpty) return;
      final first = current.first.date;
      final label = first.year == periodStartYear
          ? '${first.month}月'
          : '${first.year}年${first.month}月';
      groups.add(
        ExpenseMonthGroup(
          label: label,
          total: current.fold<int>(0, (sum, row) => sum + row.price),
          rows: current,
        ),
      );
    }

    for (final row in rows) {
      final key = '${row.date.year}-${row.date.month}';
      if (key != currentKey) {
        closeGroup();
        currentKey = key;
        current = [];
      }
      current.add(row);
    }
    closeGroup();

    return groups;
  }
}

/// 期間に含まれる集計月数（月平均の分母）
///
/// 集計開始日が1日以外の年度期間（例: 4/25〜翌4/24）でも12を返すよう、
/// 終端の日が開始日以上のときだけ1ヶ月に数える。
int expensePeriodMonthCount(PeriodValue period) {
  final start = period.startDatetime;
  final end = period.endDatetime;
  final months =
      (end.year - start.year) * 12 +
      (end.month - start.month) +
      (end.day >= start.day ? 1 : 0);
  return months <= 0 ? 1 : months;
}
