// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IncomeCategoryEntityImpl _$$IncomeCategoryEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$IncomeCategoryEntityImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      smallCategoryOrderKey: (json['smallCategoryOrderKey'] as num).toInt(),
      bigCategoryKey: (json['bigCategoryKey'] as num).toInt(),
      displaydOrderInBig: (json['displaydOrderInBig'] as num).toInt(),
      categoryName: json['categoryName'] as String,
      defaultDisplayed: (json['defaultDisplayed'] as num).toInt(),
      bigCategoryName: json['bigCategoryName'] as String,
      colorCode: json['colorCode'] as String,
      resourcePath: json['resourcePath'] as String,
      sortKey: (json['sortKey'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$IncomeCategoryEntityImplToJson(
        _$IncomeCategoryEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'smallCategoryOrderKey': instance.smallCategoryOrderKey,
      'bigCategoryKey': instance.bigCategoryKey,
      'displaydOrderInBig': instance.displaydOrderInBig,
      'categoryName': instance.categoryName,
      'defaultDisplayed': instance.defaultDisplayed,
      'bigCategoryName': instance.bigCategoryName,
      'colorCode': instance.colorCode,
      'resourcePath': instance.resourcePath,
      'sortKey': instance.sortKey,
    };
