// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'big_category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BigCategoryEntityImpl _$$BigCategoryEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$BigCategoryEntityImpl(
      id: (json['id'] as num).toInt(),
      colorCode: json['colorCode'] as String,
      bigCategoryName: json['bigCategoryName'] as String,
      resourcePath: json['resourcePath'] as String,
      displayOrder: (json['displayOrder'] as num).toInt(),
      isDisplayed: (json['isDisplayed'] as num).toInt(),
    );

Map<String, dynamic> _$$BigCategoryEntityImplToJson(
        _$BigCategoryEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'colorCode': instance.colorCode,
      'bigCategoryName': instance.bigCategoryName,
      'resourcePath': instance.resourcePath,
      'displayOrder': instance.displayOrder,
      'isDisplayed': instance.isDisplayed,
    };
