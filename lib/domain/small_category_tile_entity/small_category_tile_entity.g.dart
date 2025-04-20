// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'small_category_tile_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SmallCategoryTileEntityImpl _$$SmallCategoryTileEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$SmallCategoryTileEntityImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      displeyOrder: (json['displeyOrder'] as num?)?.toInt() ?? 0,
      smallCategoryName: json['smallCategoryName'] as String,
      totalExpenseBySmallCategory:
          (json['totalExpenseBySmallCategory'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$SmallCategoryTileEntityImplToJson(
        _$SmallCategoryTileEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'displeyOrder': instance.displeyOrder,
      'smallCategoryName': instance.smallCategoryName,
      'totalExpenseBySmallCategory': instance.totalExpenseBySmallCategory,
    };
