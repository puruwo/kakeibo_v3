import 'package:kakeibo/domain/db/expense/expense_entity.dart';

/// 支払い履歴ページのサマリー（合計・回数・平均）と年ごとのグルーピング
///
/// 合計・回数・平均は**確定済みの行のみ**から算出する（未確定行は予想額であり実績ではない）。
/// 平均は ADR-027 の推定額と同じ「確定行のみの平均」の定義に揃える。
class FixedCostPaymentHistorySummary {
  const FixedCostPaymentHistorySummary({
    required this.totalPrice,
    required this.confirmedCount,
    required this.averagePrice,
    required this.firstPaymentDate,
    required this.yearGroups,
  });

  /// 確定済みの支払い合計
  final int totalPrice;

  /// 確定済みの支払い回数
  final int confirmedCount;

  /// 確定済みの平均額。確定行が0件なら null
  final int? averagePrice;

  /// 最も古い支払日（未確定含む・yyyyMMdd）。0件なら null
  final String? firstPaymentDate;

  /// 年ごとのグループ（新しい年が先頭。各グループ内も新しい順）
  final List<PaymentHistoryYearGroup> yearGroups;

  /// 支払日の新しい順に並んだ履歴から算出する
  factory FixedCostPaymentHistorySummary.fromHistory(
    List<ExpenseEntity> history,
  ) {
    final confirmed = history.where((e) => e.isConfirmed == 1).toList();
    final total = confirmed.fold<int>(0, (sum, e) => sum + e.effectivePrice);
    final average =
        confirmed.isEmpty ? null : (total / confirmed.length).round();

    // 年ごとにまとめる（入力が新しい順なので挿入順を保てば年も新しい順になる）
    final groups = <String, List<ExpenseEntity>>{};
    for (final e in history) {
      groups.putIfAbsent(e.date.substring(0, 4), () => []).add(e);
    }

    return FixedCostPaymentHistorySummary(
      totalPrice: total,
      confirmedCount: confirmed.length,
      averagePrice: average,
      firstPaymentDate: history.isEmpty ? null : history.last.date,
      yearGroups: groups.entries
          .map((entry) => PaymentHistoryYearGroup(
                year: entry.key,
                records: entry.value,
              ))
          .toList(),
    );
  }
}

/// 1年分の支払い履歴
class PaymentHistoryYearGroup {
  const PaymentHistoryYearGroup({required this.year, required this.records});

  /// 西暦4桁
  final String year;

  /// その年の行（新しい順）
  final List<ExpenseEntity> records;

  /// その年の確定済み合計（未確定行は含めない）
  int get confirmedTotal => records
      .where((e) => e.isConfirmed == 1)
      .fold<int>(0, (sum, e) => sum + e.effectivePrice);
}
