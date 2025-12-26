import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'transaction_history_tile_value.freezed.dart';

// 取引タイプの列挙型
enum TransactionType {
  expense,          // 支出(月次)
  bonusExpense,     // 支出(ボーナス)
  income,           // 収入
  fixedCostExpense, // 固定費
}

// 複数タイプの取引を統一的に扱うUIモデル
@freezed
class TransactionHistoryTileValue with _$TransactionHistoryTileValue {
  const factory TransactionHistoryTileValue({
    required int id,
    required DateTime date,
    required int price,
    required TransactionType type,
    required int categoryId,
    @Default('') String memo,
    required String smallCategoryName,
    required String bigCategoryName,
    required String colorCode,
    required String iconPath,
  }) = _TransactionHistoryTileValue;
}
