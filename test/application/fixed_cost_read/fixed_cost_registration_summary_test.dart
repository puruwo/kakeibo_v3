// 固定費登録リストページのサマリー（件数・月あたり・年あたり）のUT
// （lib/application/fixed_cost_read/fixed_cost_registration_summary.dart）
import 'package:flutter_test/flutter_test.dart';
import 'package:kakeibo/application/fixed_cost_read/fixed_cost_registration_summary.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';

void main() {
  /// 固定額の固定費を作る（unit: 1=月・2=年）
  FixedCostEntity fixed({
    required int price,
    int number = 1,
    int unit = 1,
  }) => FixedCostEntity(
    variable: 0,
    price: price,
    intervalNumber: number,
    intervalUnit: unit,
    firstPaymentDate: '20250101',
  );

  /// 変動する固定費を作る（金額は予想額で持つ）
  FixedCostEntity variable({required int estimatedPrice}) => FixedCostEntity(
    variable: 1,
    estimatedPrice: estimatedPrice,
    intervalNumber: 1,
    intervalUnit: 1,
    firstPaymentDate: '20250101',
  );

  test('0件ならすべて0で、変動なし', () {
    final summary = FixedCostRegistrationSummary.fromFixedCosts(const []);

    expect(summary.count, 0);
    expect(summary.monthlyPrice, 0);
    expect(summary.yearlyPrice, 0);
    expect(summary.hasVariable, isFalse);
  });

  test('毎月の固定費は年あたり12回ぶん、月あたりはそのままの金額になる', () {
    final summary = FixedCostRegistrationSummary.fromFixedCosts([
      fixed(price: 80000),
    ]);

    expect(summary.count, 1);
    expect(summary.monthlyPrice, 80000);
    expect(summary.yearlyPrice, 960000);
  });

  test('隔月・半年毎・毎年・隔年を1年あたりに換算して合算する', () {
    final summary = FixedCostRegistrationSummary.fromFixedCosts([
      fixed(price: 4000, number: 2), // 隔月 → 年6回 24,000
      fixed(price: 30000, number: 6), // 半年毎 → 年2回 60,000
      fixed(price: 12000, unit: 2), // 毎年 → 12,000
      fixed(price: 20000, number: 2, unit: 2), // 隔年 → 10,000
    ]);

    expect(summary.count, 4);
    expect(summary.yearlyPrice, 106000);
    // 106,000 / 12 = 8,833.33…
    expect(summary.monthlyPrice, 8833);
  });

  test('変動する固定費は金額（price）ではなく予想額で計算する', () {
    final summary = FixedCostRegistrationSummary.fromFixedCosts([
      variable(estimatedPrice: 6000),
    ]);

    expect(summary.monthlyPrice, 6000);
    expect(summary.yearlyPrice, 72000);
    expect(summary.hasVariable, isTrue);
  });

  test('端数は1件ずつではなく合算してから丸める', () {
    // 毎年 5,900円 ×2件: 1件ずつ月あたりに丸めると 492×2=984 だが、合算なら 11,800/12=983.33…
    final summary = FixedCostRegistrationSummary.fromFixedCosts([
      fixed(price: 5900, unit: 2),
      fixed(price: 5900, unit: 2),
    ]);

    expect(summary.yearlyPrice, 11800);
    expect(summary.monthlyPrice, 983);
  });

  test('頻度が0以下の不正なデータは件数に数えるが金額には含めない', () {
    final summary = FixedCostRegistrationSummary.fromFixedCosts([
      fixed(price: 1000),
      fixed(price: 9999, number: 0),
    ]);

    expect(summary.count, 2);
    expect(summary.monthlyPrice, 1000);
    expect(summary.yearlyPrice, 12000);
  });
}
