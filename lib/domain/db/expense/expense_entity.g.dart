// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseEntityImpl _$$ExpenseEntityImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseEntityImpl(
      id: (json['id'] as num).toInt(),
      date: json['date'] as String,
      price: (json['price'] as num).toInt(),
      paymentCategoryId: (json['paymentCategoryId'] as num).toInt(),
      memo: json['memo'] as String? ?? '',
    );

Map<String, dynamic> _$$ExpenseEntityImplToJson(_$ExpenseEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'price': instance.price,
      'paymentCategoryId': instance.paymentCategoryId,
      'memo': instance.memo,
    };
