import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/ui_value/expense_big_category_with_small_list_value/i_expense_big_category_with_small_list_value.dart';

//Freezedで生成されるデータクラス
part 'edit_expense_big_category_value.freezed.dart';

// 大カテゴリー編集画面のエンティティ
@freezed
class EditExpenseBigCategoryValue
    with _$EditExpenseBigCategoryValue
    implements IExpenseBigCategoryValueWithSmallList {
  const factory EditExpenseBigCategoryValue({
    // 大カテゴリーのEntity
    required int id,
    required String colorCode,
    required String bigCategoryName,
    required String resourcePath,
    required int displayOrder,
    required int isDisplayed,
    required List<ExpenseSmallCategoryEntity> expenseSmallCategoryList,
    required String expenseSmallCategoryNameText,

    // 編集後表示順
    required int editedStateDisplayOrder,
    // 編集後の表示非表示の設定
    required bool etitedStateIsChecked,
  }) = _EditExpenseBigCategoryValue;
}
