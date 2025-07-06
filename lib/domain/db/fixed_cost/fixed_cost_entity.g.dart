// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_cost_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$FixedCostEntityImpl _$$FixedCostEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$FixedCostEntityImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String,
      variable: (json['variable'] as num).toInt(),
      price: (json['price'] as num?)?.toInt(),
      expenseSmallCategoryId: (json['expenseSmallCategoryId'] as num).toInt(),
      intervalNumber: (json['intervalNumber'] as num).toInt(),
      intervalUnit: (json['intervalUnit'] as num).toInt(),
      firstPaymentDate: json['firstPaymentDate'] as String,
      recentPaymentDate: json['recentPaymentDate'] as String?,
      nextPaymentDate: json['nextPaymentDate'] as String?,
      deleteFlag: (json['deleteFlag'] as num).toInt(),
    );

Map<String, dynamic> _$$FixedCostEntityImplToJson(
        _$FixedCostEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'variable': instance.variable,
      'price': instance.price,
      'expenseSmallCategoryId': instance.expenseSmallCategoryId,
      'intervalNumber': instance.intervalNumber,
      'intervalUnit': instance.intervalUnit,
      'firstPaymentDate': instance.firstPaymentDate,
      'recentPaymentDate': instance.recentPaymentDate,
      'nextPaymentDate': instance.nextPaymentDate,
      'deleteFlag': instance.deleteFlag,
    };
