import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/domain/ui_value/expense_history_tile_value/expense_history_tile_value/expense_history_tile_value.dart';
import 'package:kakeibo/util/util.dart';

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

  /// この月の生活収支分の合計
  int get livingTotal => rows
      .where((row) => row.incomeSourceBigCategory == AccountTypeConstants.living)
      .fold<int>(0, (sum, row) => sum + row.price);

  /// この月の特別枠分の合計
  int get specialTotal => rows
      .where(
        (row) => row.incomeSourceBigCategory == AccountTypeConstants.special,
      )
      .fold<int>(0, (sum, row) => sum + row.price);

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

/// 生活/特別の内訳ラベルを組み立てる（特別枠が無い場合はnull＝表示しない）
///
/// 支出一覧のカテゴリー行・カテゴリー明細のサマリー/月ヘッダーで共用する。
String? livingSpecialBreakdownLabel({
  required int living,
  required int special,
  String livingLabel = '生活',
  String specialLabel = '特別',
}) {
  if (special <= 0) return null;
  final parts = [
    if (living > 0) '$livingLabel ${yenmarkFormattedPriceGetter(living)}',
    '$specialLabel ${yenmarkFormattedPriceGetter(special)}',
  ];
  return parts.join('　');
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
