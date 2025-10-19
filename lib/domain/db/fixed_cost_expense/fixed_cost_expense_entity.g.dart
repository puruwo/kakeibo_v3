// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_cost_expense_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FixedCostExpenseEntityImpl _$$FixedCostExpenseEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$FixedCostExpenseEntityImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      fixedCostId: (json['fixedCostId'] as num?)?.toInt() ?? 0,
      fixedCostCategoryId: (json['fixedCostCategoryId'] as num).toInt(),
      date: json['date'] as String,
      price: (json['price'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      confirmedCostType: (json['confirmedCostType'] as num?)?.toInt() ?? 0,
      isConfirmed: (json['isConfirmed'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$FixedCostExpenseEntityImplToJson(
        _$FixedCostExpenseEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fixedCostId': instance.fixedCostId,
      'fixedCostCategoryId': instance.fixedCostCategoryId,
      'date': instance.date,
      'price': instance.price,
      'name': instance.name,
      'confirmedCostType': instance.confirmedCostType,
      'isConfirmed': instance.isConfirmed,
    };
