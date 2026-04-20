import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'monthly_balance_value.freezed.dart';

enum MonthlyBalanceType {
  future, // 未来の月
  noRecorod, // 記録なし
  noIncome, // 収入なし
  noExpense, // 支出なし
  surplus, // 黒字
  deficit, // 赤字
}

// 月次計画のエンティティ
@freezed
class MonthlyBalanceValue with _$MonthlyBalanceValue {
  const factory MonthlyBalanceValue({
    required int month,
    required int monthlyIncome,
    required int monthlyExpense,
    required int savings,
    required MonthlyBalanceType monthlyBalanceType,
    // 分析タブ遷移用の代表日（集計期間の開始日を格納）
    required DateTime representativeDate,
  }) = _MonthlyBalanceValue;

}
