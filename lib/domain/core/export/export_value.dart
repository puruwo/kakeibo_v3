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
    required int bigCategoryId,
    required String smallCategoryName,
    required int smallCategoryId,
    required String colorCode,
    required String iconName,
    required String incomeSourceBigCategoryName,
    required int incomeSourceBigCategoryId,
  }) = _ExportValue;
}

ExportValue exportValueFromJson(Map<String, dynamic> json) {
  return ExportValue(
    id: json['id'] as int,
    date: json['date'] as String,
    price: json['price'] as int,
    memo: json['memo'] as String,
    bigCategoryName: json['bigCategoryName'] as String,
    bigCategoryId: json['bigCategoryId'] as int,
    smallCategoryName: json['smallCategoryName'] as String,
    smallCategoryId: json['smallCategoryId'] as int,
    colorCode: json['colorCode'] as String,
    iconName: json['iconPathName'] as String,
    incomeSourceBigCategoryName: json['incomeSourceBigCategoryName'] as String,
    incomeSourceBigCategoryId: json['incomeSourceBigCategoryId'] as int,
  );
}

Map<String, dynamic> exportValueToJson(ExportValue instance) {
  return <String, dynamic>{
    'id': instance.id,
    'date': instance.date,
    'price': instance.price,
    'memo': instance.memo,
    'bigCategoryName': instance.bigCategoryName,
    'bigCategoryId': instance.bigCategoryId,
    'smallCategoryName': instance.smallCategoryName,
    'smallCategoryId': instance.smallCategoryId,
    'colorCode': instance.colorCode,
    'iconName': instance.iconName,
    'incomeSourceBigCategoryName': instance.incomeSourceBigCategoryName,
    'incomeSourceBigCategoryId': instance.incomeSourceBigCategoryId,
  };
}

List<dynamic> toList(ExportValue instance) => [
      instance.id,
      instance.date,
      instance.price,
      instance.memo,
      instance.bigCategoryName,
      instance.bigCategoryId,
      instance.smallCategoryName,
      instance.smallCategoryId,
      instance.colorCode,
      instance.iconName,
      instance.incomeSourceBigCategoryName,
      instance.incomeSourceBigCategoryId,
    ];
