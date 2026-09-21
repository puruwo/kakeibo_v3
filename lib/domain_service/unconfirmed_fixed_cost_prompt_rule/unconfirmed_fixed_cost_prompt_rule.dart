import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';

/// 未確定固定費の金額確定を促す対象かどうかの判定規則（純粋関数・正本。KP-028）
///
/// 入力は 支払日・確定済みか・今日・月度の区切り だけで、`expense` の型に依存させない
/// （共同固定費の行にも同じ規則を使うため）。
///
/// 規則の境界値は
/// `test/domain_service/unconfirmed_fixed_cost_prompt_rule/unconfirmed_fixed_cost_prompt_rule_test.dart`
/// で固定している。
class UnconfirmedFixedCostPromptRule {
  UnconfirmedFixedCostPromptRule._();

  /// 月間分析の注意バナーに出すまでの猶予日数（支払日からこの日数が経過したら対象）
  static const int overdueGraceDays = 3;

  /// 起動時の促しの対象か
  ///
  /// 未確定で、支払日が現在の月度（[currentPeriod]）より前の月度にある行。
  static bool isLaunchPromptTarget({
    required DateTime paymentDate,
    required bool isConfirmed,
    required PeriodValue currentPeriod,
  }) {
    if (isConfirmed) return false;
    return _dateOnly(
      paymentDate,
    ).isBefore(_dateOnly(currentPeriod.startDatetime));
  }

  /// 月間分析の注意バナーの対象か
  ///
  /// 未確定で、支払日が表示中の月度（[shownPeriod]）にあり、
  /// 支払日＋[overdueGraceDays]日 ≦ [today] の行。
  static bool isOverdueTarget({
    required DateTime paymentDate,
    required bool isConfirmed,
    required DateTime today,
    required PeriodValue shownPeriod,
  }) {
    if (isConfirmed) return false;

    final payment = _dateOnly(paymentDate);
    final isInPeriod =
        !payment.isBefore(_dateOnly(shownPeriod.startDatetime)) &&
        !payment.isAfter(_dateOnly(shownPeriod.endDatetime));
    if (!isInPeriod) return false;

    // 日数の加算は DateTime の正規化に任せる（月末・年末をまたいでも正しく繰り上がる）
    final overdueFrom = DateTime(
      payment.year,
      payment.month,
      payment.day + overdueGraceDays,
    );
    return !_dateOnly(today).isBefore(overdueFrom);
  }

  /// 時刻を落として日付だけにする（運用日付は起動時刻を含むため）
  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
