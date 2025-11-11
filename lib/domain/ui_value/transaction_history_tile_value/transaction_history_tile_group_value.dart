import 'package:freezed_annotation/freezed_annotation.dart';
import 'transaction_history_tile_value.dart';

//Freezedで生成されるデータクラス
part 'transaction_history_tile_group_value.freezed.dart';

// 複数タイプの取引を日付でグループ化したUIモデル
@freezed
class TransactionHistoryTileGroupValue with _$TransactionHistoryTileGroupValue {
  const factory TransactionHistoryTileGroupValue({
    required DateTime date,
    required List<TransactionHistoryTileValue> transactionHistoryTileValueList,
  }) = _TransactionHistoryTileGroupValue;
}
