// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseEntityImpl _$$ExpenseEntityImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseEntityImpl(
      id: (json['id'] as num?)?.toInt() ?? 1,
      date: json['date'] as String,
      price: (json['price'] as num?)?.toInt(),
      paymentCategoryId: (json['paymentCategoryId'] as num?)?.toInt() ?? 0,
      memo: json['memo'] as String? ?? '',
      incomeSourceBigCategory:
          (json['incomeSourceBigCategory'] as num?)?.toInt() ??
          AccountTypeConstants.living,
      fixedCostId: (json['fixedCostId'] as num?)?.toInt(),
      isConfirmed: (json['isConfirmed'] as num?)?.toInt() ?? 1,
      estimatedPrice: (json['estimatedPrice'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ExpenseEntityImplToJson(_$ExpenseEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'price': instance.price,
      'paymentCategoryId': instance.paymentCategoryId,
      'memo': instance.memo,
      'incomeSourceBigCategory': instance.incomeSourceBigCategory,
      'fixedCostId': instance.fixedCostId,
      'isConfirmed': instance.isConfirmed,
      'estimatedPrice': instance.estimatedPrice,
    };
