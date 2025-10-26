// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_cost_category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FixedCostCategoryEntityImpl _$$FixedCostCategoryEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$FixedCostCategoryEntityImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      categoryName: json['categoryName'] as String,
      colorCode: json['colorCode'] as String,
      resourcePath: json['resourcePath'] as String,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
      isDisplayed: (json['isDisplayed'] as num?)?.toInt() ?? 1,
      sortKey: (json['sortKey'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$FixedCostCategoryEntityImplToJson(
        _$FixedCostCategoryEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryName': instance.categoryName,
      'colorCode': instance.colorCode,
      'resourcePath': instance.resourcePath,
      'displayOrder': instance.displayOrder,
      'isDisplayed': instance.isDisplayed,
      'sortKey': instance.sortKey,
    };
