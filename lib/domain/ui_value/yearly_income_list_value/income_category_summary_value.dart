import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'income_category_summary_value.freezed.dart';

// カテゴリー別収入集計のエンティティ
@freezed
class IncomeCategorySummaryValue with _$IncomeCategorySummaryValue {
  const factory IncomeCategorySummaryValue({
    required String categoryName,
    required String colorCode,
    required String iconPath,
    required int totalAmount,
    required double percentage,
  }) = _IncomeCategorySummaryValue;
}
