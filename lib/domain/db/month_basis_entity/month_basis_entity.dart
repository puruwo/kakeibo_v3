import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'month_basis_entity.freezed.dart';

// 月の基準採択を集計期間の初日にするか、最終日にするかの設定

// ex)20250525から20250624までの集計期間を選択した場合
// 5月と表示するか、6月と表示するか
// start -> 5月
// end -> 6月

// 予算設定の入力月をどっちの月の入力として扱うのか

enum MonthBasis {start, end}

@freezed
class MonthBasisEntity with _$MonthBasisEntity {
  const factory MonthBasisEntity({
    required MonthBasis monthBasis,
  }) = _MonthBasisEntity;

}