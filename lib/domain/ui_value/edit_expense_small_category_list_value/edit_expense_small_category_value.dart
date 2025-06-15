import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';

//Freezedで生成されるデータクラス
part 'edit_expense_small_category_value.freezed.dart';

// 大カテゴリー編集画面のエンティティ
@freezed
class EditExpenseSmallCategoryValue with _$EditExpenseSmallCategoryValue {
  const factory EditExpenseSmallCategoryValue({
    // 大カテゴリーのEntity
    required int id,
    required int bigCategoryKey,
    required String name,
    required int smallCategoryOrderKey,
    required int displayOrderInBig,
    required int defaultDisplayed,

    // 編集後表示順
    required int editedStateDisplayOrder,
    // 編集後の表示非表示の設定
    required bool etitedStateIsChecked,
  }) = _EditExpenseSmallCategoryValue;
}

// entityからExpenseSmallCategoryValueに変換する拡張メソッド
extension EditExpenseSmallCategoryValueExtension
    on EditExpenseSmallCategoryValue {
  /// entityからExpenseSmallCategoryValueに変換する
  ExpenseSmallCategoryEntity toExpenseSmallCategoryEntity({
    int? id,
    int? bigCategoryKey,
    String? name,
    int? smallCategoryOrderKey,
    int? displayOrderInBig,
    int? defaultDisplayed,
  }) {
    return ExpenseSmallCategoryEntity(
      id: id ?? this.id,
      bigCategoryKey: bigCategoryKey ?? this.bigCategoryKey,
      smallCategoryOrderKey:
          smallCategoryOrderKey ?? this.smallCategoryOrderKey,
      displayedOrderInBig: displayOrderInBig ?? this.editedStateDisplayOrder,
      smallCategoryName: name ?? this.name,
      defaultDisplayed: defaultDisplayed ?? (this.etitedStateIsChecked ? 1 : 0),
    );
  }
}
