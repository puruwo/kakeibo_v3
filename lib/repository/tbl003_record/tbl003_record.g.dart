// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tbl003_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TBL003RecordImpl _$$TBL003RecordImplFromJson(Map<String, dynamic> json) =>
    _$TBL003RecordImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      date: json['date'] as String,
      bigCategory: (json['bigCategory'] as num).toInt(),
      price: (json['price'] as num).toInt(),
    );

Map<String, dynamic> _$$TBL003RecordImplToJson(_$TBL003RecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'bigCategory': instance.bigCategory,
      'price': instance.price,
    };
