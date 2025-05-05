import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kakeibo/model/database_helper.dart';

//Freezedで生成されるデータクラス
part 'income_big_category_entity.freezed.dart';
//jsonを変換する処理が生成されるクラス
part 'income_big_category_entity.g.dart';

DatabaseHelper db = DatabaseHelper.instance;

@freezed
class IncomeBigCategoryEntity with _$IncomeBigCategoryEntity {
  const IncomeBigCategoryEntity._();

  const factory IncomeBigCategoryEntity({
    required int id,
    required String name,
    required String colorCode,
    required String iconPath,
  }) = _IncomeBigCategoryEntity;

  @override
  factory IncomeBigCategoryEntity.fromJson(Map<String, dynamic> json) =>
      _$IncomeBigCategoryEntityFromJson(json);

}
