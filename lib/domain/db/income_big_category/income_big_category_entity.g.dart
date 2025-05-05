// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_big_category_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IncomeBigCategoryEntityImpl _$$IncomeBigCategoryEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$IncomeBigCategoryEntityImpl(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      colorCode: json['colorCode'] as String,
      iconPath: json['iconPath'] as String,
    );

Map<String, dynamic> _$$IncomeBigCategoryEntityImplToJson(
        _$IncomeBigCategoryEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'colorCode': instance.colorCode,
      'iconPath': instance.iconPath,
    };
