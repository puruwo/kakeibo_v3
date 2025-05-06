import 'package:freezed_annotation/freezed_annotation.dart';

//Freezedで生成されるデータクラス
part 'export_value.freezed.dart';

// 支出データのエンティティ
@freezed
class ExportValue with _$ExportValue {
  const factory ExportValue({
    required int id,
    required String date,
    required int price,
    @Default('') String memo,
    required String bigCategoryName,
    required String smallCategoryName,
    required String colorCode,
    required String iconName,
    required String incomeSourceBigCategoryName,
  }) = _ExportValue;

}

ExportValue exportValueFromJson(Map<String, dynamic> json) {
  return ExportValue(
    id: json['id'] as int,
    date: json['date'] as String,
    price: json['price'] as int,
    memo: json['memo'] as String,
    bigCategoryName: json['bigCategoryName'] as String,
    smallCategoryName: json['smallCategoryName'] as String,
    colorCode: json['colorCode'] as String,
    iconName: json['iconPathName'] as String,
    incomeSourceBigCategoryName: json['incomeSourceBigCategoryName'] as String,
  );
}

Map<String, dynamic> exportValueToJson(ExportValue instance) {
  return <String, dynamic>{
    'id': instance.id,
    'date': instance.date,
    'price': instance.price,
    'memo': instance.memo,
    'bigCategoryName': instance.bigCategoryName,
    'smallCategoryName': instance.smallCategoryName,
    'colorCode': instance.colorCode,
    'iconName': instance.iconName,
    'incomeSourceBigCategoryName': instance.incomeSourceBigCategoryName,
  };
}

List<dynamic> toList(ExportValue instance) => [
        instance.id,
        instance.date,
        instance.price,
        instance.memo,
        instance.bigCategoryName,
        instance.smallCategoryName,
        instance.colorCode,
        instance.iconName,
        instance.incomeSourceBigCategoryName,
      ];

