// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryEntityImpl _$$CategoryEntityImplFromJson(Map<String, dynamic> json) =>
    _$CategoryEntityImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      categoryColor: json['categoryColor'] as String,
      bigCategoryName: json['bigCategoryName'] as String,
      categoryIconPath: json['categoryIconPath'] as String,
      budget: (json['budget'] as num?)?.toInt() ?? 0,
      totalExpenseByBigCategory:
          (json['totalExpenseByBigCategory'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$CategoryEntityImplToJson(
        _$CategoryEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryColor': instance.categoryColor,
      'bigCategoryName': instance.bigCategoryName,
      'categoryIconPath': instance.categoryIconPath,
      'budget': instance.budget,
      'totalExpenseByBigCategory': instance.totalExpenseByBigCategory,
    };
