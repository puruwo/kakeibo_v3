// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_small_category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SmallCategoryEntityImpl _$$SmallCategoryEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$SmallCategoryEntityImpl(
      id: (json['id'] as num).toInt(),
      smallCategoryOrderKey: (json['smallCategoryOrderKey'] as num).toInt(),
      bigCategoryKey: (json['bigCategoryKey'] as num).toInt(),
      displayedOrderInBig: (json['displayedOrderInBig'] as num).toInt(),
      smallCategoryName: json['smallCategoryName'] as String,
      defaultDisplayed: (json['defaultDisplayed'] as num).toInt(),
    );

Map<String, dynamic> _$$SmallCategoryEntityImplToJson(
        _$SmallCategoryEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'smallCategoryOrderKey': instance.smallCategoryOrderKey,
      'bigCategoryKey': instance.bigCategoryKey,
      'displayedOrderInBig': instance.displayedOrderInBig,
      'smallCategoryName': instance.smallCategoryName,
      'defaultDisplayed': instance.defaultDisplayed,
    };
