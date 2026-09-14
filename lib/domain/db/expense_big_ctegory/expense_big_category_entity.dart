import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/model/database_helper.dart';
import 'package:kakeibo/model/table_calmn_name.dart';

//Freezedで生成されるデータクラス
part 'expense_big_category_entity.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'expense_big_category_entity.g.dart';

DatabaseHelper db = DatabaseHelper.instance;

@freezed
class ExpenseBigCategoryEntity with _$ExpenseBigCategoryEntity {
  const ExpenseBigCategoryEntity._();

  const factory ExpenseBigCategoryEntity({
    required int id,
    required String colorCode,
    required String bigCategoryName,
    required String resourcePath,
    required int displayOrder,
    required int isDisplayed,
    // 論理削除（0=有効 / 1=削除済み）。v14で追加（KP-024）
    @Default(0) int deleteFlag,
  }) = _BigCategoryEntity;

  @override
  factory ExpenseBigCategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$ExpenseBigCategoryEntityFromJson(json);

  update(){
    print('id: $id,smallCategoryKey: $colorCode,bigCategoryKey: $bigCategoryName,categoryName: $resourcePath,defaultDisplayed: $displayOrder,isDisplayed:$isDisplayedを登録しました');
    db.update(SqfExpenseBigCategory.tableName, {
      SqfExpenseBigCategory.id: id,
      SqfExpenseBigCategory.colorCode: colorCode,
      SqfExpenseBigCategory.name: bigCategoryName,
      SqfExpenseBigCategory.resourcePath: resourcePath,
      SqfExpenseBigCategory.displayOrder: displayOrder,
      SqfExpenseBigCategory.isDisplayed: isDisplayed,
    }, id);
  }

  //削除機能はなし
  //過去のレコードのカテゴリーの参照先がなくなってしまうため
}
