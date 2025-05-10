// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'budget_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BudgetEntityImpl _$$BudgetEntityImplFromJson(Map<String, dynamic> json) =>
    _$BudgetEntityImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      expenseBigCategoryId:
          (json['expenseBigCategoryId'] as num?)?.toInt() ?? 0,
      month: json['month'] as String,
      price: (json['price'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$BudgetEntityImplToJson(_$BudgetEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'expenseBigCategoryId': instance.expenseBigCategoryId,
      'month': instance.month,
      'price': instance.price,
    };
