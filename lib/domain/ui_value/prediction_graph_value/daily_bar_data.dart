import 'package:freezed_annotation/freezed_annotation.dart';

part 'daily_bar_data.freezed.dart';

/// 日別カテゴリー別支出データ
@freezed
class DailyBarData with _$DailyBarData {
  const factory DailyBarData({
    required DateTime date,
    required bool isFutureDate,
    required List<CategoryExpense> categoryExpenses,
    // BarAreaHeightに対する比率 (0.0 ~ 1.0)
    required double normalizedTotalHeight,
  }) = _DailyBarData;
}

/// カテゴリー別支出データ
@freezed
class CategoryExpense with _$CategoryExpense {
  const factory CategoryExpense({
    required int bigCategoryId,
    required int price,
    required String colorCode,
    required String iconPath,
    required String categoryName,
    // BarAreaHeightに対する比率 (0.0 ~ 1.0)
    required double normalizedHeight,
  }) = _CategoryExpense;
}
