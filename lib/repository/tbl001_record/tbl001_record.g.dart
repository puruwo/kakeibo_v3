// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tbl001_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TBL001RecordImpl _$$TBL001RecordImplFromJson(Map<String, dynamic> json) =>
    _$TBL001RecordImpl(
      id: json['id'] as int? ?? 0,
      date: json['date'] as String,
      price: json['price'] as int? ?? 0,
      category: json['category'] as int? ?? 0,
      memo: json['memo'] as String? ?? '',
    );

Map<String, dynamic> _$$TBL001RecordImplToJson(_$TBL001RecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'price': instance.price,
      'category': instance.category,
      'memo': instance.memo,
    };
