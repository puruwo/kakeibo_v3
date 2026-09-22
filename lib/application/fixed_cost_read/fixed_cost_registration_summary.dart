import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';

/// 固定費登録リストページのサマリー（登録件数・月あたり・年あたり）
///
/// 頻度の違う固定費（毎月・隔月・毎年など）を1年あたりの金額に換算して合算する。
/// 変動する固定費は金額が決まっていないため、予想額（estimatedPrice）で計算する。
class FixedCostRegistrationSummary {
  const FixedCostRegistrationSummary({
    required this.count,
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.hasVariable,
  });

  /// 登録中の固定費の件数
  final int count;

  /// 月あたりの金額（年あたりの合計を12で割って四捨五入）
  final int monthlyPrice;

  /// 年あたりの金額
  final int yearlyPrice;

  /// 変動する固定費を含むか（含むとき、金額は予想額まじりの概算になる）
  final bool hasVariable;

  /// 登録中の固定費（削除済みを含まない）から算出する
  factory FixedCostRegistrationSummary.fromFixedCosts(
    List<FixedCostEntity> fixedCosts,
  ) {
    // 端数は合算してから丸める（1件ずつ丸めると件数ぶん誤差が積もるため）
    final yearly = fixedCosts.fold<double>(
      0,
      (sum, e) => sum + _yearlyPriceOf(e),
    );
    return FixedCostRegistrationSummary(
      count: fixedCosts.length,
      monthlyPrice: (yearly / 12).round(),
      yearlyPrice: yearly.round(),
      hasVariable: fixedCosts.any((e) => e.variable == 1),
    );
  }

  /// 1件の固定費の1年あたりの金額
  static double _yearlyPriceOf(FixedCostEntity e) {
    // 頻度が不正（0以下）のデータは換算できないため合計に含めない
    if (e.intervalNumber <= 0) return 0;
    final price = e.variable == 1 ? e.estimatedPrice : e.price;
    if (e.intervalUnit == PaymentFrequencyIntervalUnit.year.inturvalUnitNumber) {
      return price / e.intervalNumber;
    }
    return price * 12 / e.intervalNumber;
  }
}
