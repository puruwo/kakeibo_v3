// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'small_category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SmallCategoryEntityImpl _$$SmallCategoryEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$SmallCategoryEntityImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      displeyOrder: (json['displeyOrder'] as num?)?.toInt() ?? 0,
      smallCategoryName: json['smallCategoryName'] as String,
      totalExpenseBySmallCategory:
          (json['totalExpenseBySmallCategory'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SmallCategoryEntityImplToJson(
        _$SmallCategoryEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displeyOrder': instance.displeyOrder,
      'smallCategoryName': instance.smallCategoryName,
      'totalExpenseBySmallCategory': instance.totalExpenseBySmallCategory,
    };
