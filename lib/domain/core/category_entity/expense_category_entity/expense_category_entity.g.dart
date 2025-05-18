// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseCategoryEntityImpl _$$ExpenseCategoryEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$ExpenseCategoryEntityImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      smallCategoryOrderKey: (json['smallCategoryOrderKey'] as num).toInt(),
      bigCategoryKey: (json['bigCategoryKey'] as num).toInt(),
      displaydOrderInBig: (json['displaydOrderInBig'] as num).toInt(),
      smallCategoryName: json['smallCategoryName'] as String,
      defaultDisplayed: (json['defaultDisplayed'] as num).toInt(),
      bigCategoryName: json['bigCategoryName'] as String,
      colorCode: json['colorCode'] as String,
      resourcePath: json['resourcePath'] as String,
      displayOrder: (json['displayOrder'] as num).toInt(),
      isDisplayed: (json['isDisplayed'] as num).toInt(),
      sortKey: (json['sortKey'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ExpenseCategoryEntityImplToJson(
        _$ExpenseCategoryEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'smallCategoryOrderKey': instance.smallCategoryOrderKey,
      'bigCategoryKey': instance.bigCategoryKey,
      'displaydOrderInBig': instance.displaydOrderInBig,
      'smallCategoryName': instance.smallCategoryName,
      'defaultDisplayed': instance.defaultDisplayed,
      'bigCategoryName': instance.bigCategoryName,
      'colorCode': instance.colorCode,
      'resourcePath': instance.resourcePath,
      'displayOrder': instance.displayOrder,
      'isDisplayed': instance.isDisplayed,
      'sortKey': instance.sortKey,
    };
