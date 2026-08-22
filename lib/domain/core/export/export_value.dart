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
    // 固定費マスタへの参照。NULL＝通常支出（v10で追加）
    int? fixedCostId,
    // 0=未確定 / 1=確定。通常支出は常に1（v10で追加）
    @Default(1) int isConfirmed,
    // 予想額。未確定の固定費行のみ値を持つ（v10で追加）
    int? estimatedPrice,
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
    fixedCostId: json['fixedCostId'] as int?,
    isConfirmed: json['isConfirmed'] as int? ?? 1,
    estimatedPrice: json['estimatedPrice'] as int?,
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
    'fixedCostId': instance.fixedCostId,
    'isConfirmed': instance.isConfirmed,
    'estimatedPrice': instance.estimatedPrice,
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
      instance.fixedCostId,
      instance.isConfirmed,
      instance.estimatedPrice,
    ];
