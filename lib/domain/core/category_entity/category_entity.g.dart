// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryEntityImpl _$$CategoryEntityImplFromJson(Map<String, dynamic> json) =>
    _$CategoryEntityImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      smallCategoryOrderKey: (json['smallCategoryOrderKey'] as num).toInt(),
      bigCategoryKey: (json['bigCategoryKey'] as num).toInt(),
      displaydOrderInBig: (json['displaydOrderInBig'] as num).toInt(),
      smallCategoryName: json['smallCategoryName'] as String,
      defaultDisplayed: (json['defaultDisplayed'] as num).toInt(),
      bigCategoryEntity: ExpenseBigCategoryEntity.fromJson(
          json['bigCategoryEntity'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CategoryEntityImplToJson(
        _$CategoryEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'smallCategoryOrderKey': instance.smallCategoryOrderKey,
      'bigCategoryKey': instance.bigCategoryKey,
      'displaydOrderInBig': instance.displaydOrderInBig,
      'smallCategoryName': instance.smallCategoryName,
      'defaultDisplayed': instance.defaultDisplayed,
      'bigCategoryEntity': instance.bigCategoryEntity,
    };
