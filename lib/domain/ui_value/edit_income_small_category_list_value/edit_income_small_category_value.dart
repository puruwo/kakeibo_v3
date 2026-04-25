import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';

part 'edit_income_small_category_value.freezed.dart';

@freezed
class EditIncomeSmallCategoryValue with _$EditIncomeSmallCategoryValue {
  const factory EditIncomeSmallCategoryValue({
    required int id,
    required int bigCategoryKey,
    required String name,
    required int smallCategoryOrderKey,
    required int displayOrderInBig,
    required int defaultDisplayed,

    // 編集後表示順
    required int editedStateDisplayOrder,
    // 編集後の表示非表示
    required bool etitedStateIsChecked,
  }) = _EditIncomeSmallCategoryValue;
}

extension EditIncomeSmallCategoryValueExtension
    on EditIncomeSmallCategoryValue {
  IncomeSmallCategoryEntity toIncomeSmallCategoryEntity({
    int? id,
    int? bigCategoryKey,
    String? name,
    int? smallCategoryOrderKey,
    int? displayOrderInBig,
    int? defaultDisplayed,
  }) {
    return IncomeSmallCategoryEntity(
      id: id ?? this.id,
      bigCategoryKey: bigCategoryKey ?? this.bigCategoryKey,
      smallCategoryOrderKey:
          smallCategoryOrderKey ?? this.smallCategoryOrderKey,
      displayedOrderInBig: displayOrderInBig ?? editedStateDisplayOrder,
      smallCategoryName: name ?? this.name,
      defaultDisplayed: defaultDisplayed ?? (etitedStateIsChecked ? 1 : 0),
    );
  }
}
