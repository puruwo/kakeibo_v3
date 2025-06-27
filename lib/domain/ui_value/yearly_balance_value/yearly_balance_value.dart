import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'yearly_balance_value.freezed.dart';

enum YearlyBalanceType {
  noRecorod, // 記録なし
  noIncome, // 収入なし
  noExpense, // 支出なし
  surplus, // 黒字
  deficit, // 赤字
}
// 年間収支カードのエンティティ
@freezed
class YearlyBalanceValue with _$YearlyBalanceValue {
  const factory YearlyBalanceValue({
    required int yearlyIncome,
    required int yearlyExpense,
    required int savings,
    required YearlyBalanceType yearlyBalanceType,
  }) = _YearlyBalanceValue;

}
