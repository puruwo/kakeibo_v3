import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'edit_fixed_cost_category_value.freezed.dart';

// 固定費カテゴリー編集画面のエンティティ
@freezed
class EditFixedCostCategoryValue with _$EditFixedCostCategoryValue {
  const factory EditFixedCostCategoryValue({
    required int id,
    required String name,
    required String colorCode,
    required String resourcePath,
    required int displayOrder,
    required int isDisplayed,

    // 編集後表示順
    required int editedStateDisplayOrder,
    // 編集後の表示非表示の設定
    required bool editedStateIsChecked,
  }) = _EditFixedCostCategoryValue;
}
