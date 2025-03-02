// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tbl202_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TBL202RecordImpl _$$TBL202RecordImplFromJson(Map<String, dynamic> json) =>
    _$TBL202RecordImpl(
      id: (json['id'] as num).toInt(),
      colorCode: json['colorCode'] as String,
      bigCategoryName: json['bigCategoryName'] as String,
      resourcePath: json['resourcePath'] as String,
      displayOrder: (json['displayOrder'] as num).toInt(),
      isDisplayed: (json['isDisplayed'] as num).toInt(),
    );

Map<String, dynamic> _$$TBL202RecordImplToJson(_$TBL202RecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'colorCode': instance.colorCode,
      'bigCategoryName': instance.bigCategoryName,
      'resourcePath': instance.resourcePath,
      'displayOrder': instance.displayOrder,
      'isDisplayed': instance.isDisplayed,
    };
