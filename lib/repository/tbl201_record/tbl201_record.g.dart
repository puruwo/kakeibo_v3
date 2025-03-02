// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tbl201_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TBL201RecordImpl _$$TBL201RecordImplFromJson(Map<String, dynamic> json) =>
    _$TBL201RecordImpl(
      id: (json['id'] as num).toInt(),
      smallCategoryOrderKey: (json['smallCategoryOrderKey'] as num).toInt(),
      bigCategoryKey: (json['bigCategoryKey'] as num).toInt(),
      displayedOrderInBig: (json['displayedOrderInBig'] as num).toInt(),
      categoryName: json['categoryName'] as String,
      defaultDisplayed: (json['defaultDisplayed'] as num).toInt(),
    );

Map<String, dynamic> _$$TBL201RecordImplToJson(_$TBL201RecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'smallCategoryOrderKey': instance.smallCategoryOrderKey,
      'bigCategoryKey': instance.bigCategoryKey,
      'displayedOrderInBig': instance.displayedOrderInBig,
      'categoryName': instance.categoryName,
      'defaultDisplayed': instance.defaultDisplayed,
    };
