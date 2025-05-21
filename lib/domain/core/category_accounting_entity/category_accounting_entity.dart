import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'category_accounting_entity.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'category_accounting_entity.g.dart';

// 月毎カテゴリー毎の支出データの取得時に利用するentity
// このentityのみSQLで一括でデータ形成している
@freezed
class CategoryAccountingEntity with _$CategoryAccountingEntity {
  const factory CategoryAccountingEntity({
    @Default(0) int id,
    required String categoryColor,
    required String bigCategoryName,
    required String categoryIconPath,
    @Default(0) int totalExpenseByBigCategory,
  }) = _CategoryAccountingEntity;

  @override
  factory CategoryAccountingEntity.fromJson(Map<String, dynamic> json) =>
      _$CategoryAccountingEntityFromJson(json);
}