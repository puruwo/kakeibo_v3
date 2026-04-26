import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/db/income_small_category/income_small_category_entity.dart';

part 'edit_income_big_category_value.freezed.dart';

// 収入大カテゴリー編集画面のエンティティ
@freezed
class EditIncomeBigCategoryValue with _$EditIncomeBigCategoryValue {
  const factory EditIncomeBigCategoryValue({
    required int id,
    required String colorCode,
    required String bigCategoryName,
    required String resourcePath,
    required List<IncomeSmallCategoryEntity> incomeSmallCategoryList,
    required String incomeSmallCategoryNameText,
  }) = _EditIncomeBigCategoryValue;
}
