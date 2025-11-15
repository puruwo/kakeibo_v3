import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';

//Freezedで生成されるデータクラス
part 'fixed_cost_registration_list_entity.freezed.dart';

// 固定費登録一覧のエンティティ
@freezed
class FixedCostRegistrationListValue with _$FixedCostRegistrationListValue {
  const factory FixedCostRegistrationListValue({
    required List<FixedCostCategoryGroup> categoryGroups,
  }) = _FixedCostRegistrationListValue;
}

// カテゴリーごとの固定費グループ
@freezed
class FixedCostCategoryGroup with _$FixedCostCategoryGroup {
  const factory FixedCostCategoryGroup({
    required int categoryId,
    required String categoryName,
    required String categoryIconPath,
    required String categoryColorCode,
    required List<FixedCostEntity> items,
  }) = _FixedCostCategoryGroup;
}
