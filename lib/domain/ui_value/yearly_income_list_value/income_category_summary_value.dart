import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'income_category_summary_value.freezed.dart';

// カテゴリー別収入集計のエンティティ（大カテゴリー単位）
@freezed
class IncomeCategorySummaryValue with _$IncomeCategorySummaryValue {
  const factory IncomeCategorySummaryValue({
    required int bigCategoryId,
    // 大カテゴリー名
    required String categoryName,
    required String colorCode,
    required String iconPath,
    required int totalAmount,
    required double percentage,
    // この大カテゴリーに属する小カテゴリー別の内訳（金額降順）
    @Default([]) List<IncomeSmallCategorySummaryValue> smallCategories,
  }) = _IncomeCategorySummaryValue;
}

// 小カテゴリー別の内訳（収入カテゴリー明細のヘッダーで使う）
@freezed
class IncomeSmallCategorySummaryValue with _$IncomeSmallCategorySummaryValue {
  const factory IncomeSmallCategorySummaryValue({
    required String smallCategoryName,
    required int totalAmount,
    // 大カテゴリー合計に対する割合（0〜100）
    required double percentage,
  }) = _IncomeSmallCategorySummaryValue;
}
