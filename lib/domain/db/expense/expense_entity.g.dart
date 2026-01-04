// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ExpenseEntityImpl _$$ExpenseEntityImplFromJson(Map<String, dynamic> json) =>
    _$ExpenseEntityImpl(
      id: (json['id'] as num?)?.toInt() ?? 1,
      date: json['date'] as String,
      price: (json['price'] as num?)?.toInt() ?? 0,
      paymentCategoryId: (json['paymentCategoryId'] as num?)?.toInt() ?? 0,
      memo: json['memo'] as String? ?? '',
      incomeSourceBigCategory:
          (json['incomeSourceBigCategory'] as num?)?.toInt() ??
              IncomeBigCategoryConstants.incomeSourceIdSalary,
    );

Map<String, dynamic> _$$ExpenseEntityImplToJson(_$ExpenseEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'price': instance.price,
      'paymentCategoryId': instance.paymentCategoryId,
      'memo': instance.memo,
      'incomeSourceBigCategory': instance.incomeSourceBigCategory,
    };
