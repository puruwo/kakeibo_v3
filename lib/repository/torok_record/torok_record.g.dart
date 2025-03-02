// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'torok_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TorokRecordImpl _$$TorokRecordImplFromJson(Map<String, dynamic> json) =>
    _$TorokRecordImpl(
      id: (json['id'] as num?)?.toInt() ?? 0,
      date: json['date'] as String,
      price: (json['price'] as num?)?.toInt() ?? 0,
      categoryOrderKey: (json['categoryOrderKey'] as num?)?.toInt() ?? 0,
      memo: json['memo'] as String? ?? '',
    );

Map<String, dynamic> _$$TorokRecordImplToJson(_$TorokRecordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date,
      'price': instance.price,
      'categoryOrderKey': instance.categoryOrderKey,
      'memo': instance.memo,
    };
