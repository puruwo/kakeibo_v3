// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tbl201_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TBL201RecordImpl _$$TBL201RecordImplFromJson(Map<String, dynamic> json) =>
    _$TBL201RecordImpl(
      id: json['id'] as int,
      smallCategoryOrderKey: json['smallCategoryOrderKey'] as int,
      bigCategoryKey: json['bigCategoryKey'] as int,
      displayedOrderInBig: json['displayedOrderInBig'] as int,
      categoryName: json['categoryName'] as String,
      defaultDisplayed: json['defaultDisplayed'] as int,
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
