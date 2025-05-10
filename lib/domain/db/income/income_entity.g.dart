// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'income_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$IncomeEntityImpl _$$IncomeEntityImplFromJson(Map<String, dynamic> json) =>
    _$IncomeEntityImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      categoryId: (json['categoryId'] as num?)?.toInt() ?? 0,
      date: json['date'] as String,
      price: (json['price'] as num?)?.toInt() ?? 0,
      memo: json['memo'] as String? ?? '',
    );

Map<String, dynamic> _$$IncomeEntityImplToJson(_$IncomeEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'categoryId': instance.categoryId,
      'date': instance.date,
      'price': instance.price,
      'memo': instance.memo,
    };
