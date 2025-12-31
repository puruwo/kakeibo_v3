// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'daily_expense_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DailyExpenseEntityImpl _$$DailyExpenseEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$DailyExpenseEntityImpl(
      date: DateTime.parse(json['date'] as String),
      totalExpense: (json['totalExpense'] as num?)?.toInt() ?? 0,
      totalIncome: (json['totalIncome'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$DailyExpenseEntityImplToJson(
        _$DailyExpenseEntityImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'totalExpense': instance.totalExpense,
      'totalIncome': instance.totalIncome,
    };
