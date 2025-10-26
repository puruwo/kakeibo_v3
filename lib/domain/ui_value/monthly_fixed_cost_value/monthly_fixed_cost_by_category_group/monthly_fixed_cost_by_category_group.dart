import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/i_monthly_fixed_tile_value.dart';

part 'monthly_fixed_cost_by_category_group.freezed.dart';

/// カテゴリー別にグルーピングされた固定費のグループ
@freezed
class MonthlyFixedCostByCategoryGroup with _$MonthlyFixedCostByCategoryGroup {
  const factory MonthlyFixedCostByCategoryGroup({
    required int fixedCostCategoryId,
    required String categoryName,
    required String colorCode,
    required String resourcePath,
    required List<IMonthlyFixedTileValue> items,
  }) = _MonthlyFixedCostByCategoryGroup;
}
