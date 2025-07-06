// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'batch_history_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BatchHistoryEntityImpl _$$BatchHistoryEntityImplFromJson(
        Map<String, dynamic> json) =>
    _$BatchHistoryEntityImpl(
      id: (json['id'] as num?)?.toInt(),
      startDate: json['startDate'] as String,
      endDate: json['endDate'] as String,
      status: (json['status'] as num).toInt(),
    );

Map<String, dynamic> _$$BatchHistoryEntityImplToJson(
        _$BatchHistoryEntityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'startDate': instance.startDate,
      'endDate': instance.endDate,
      'status': instance.status,
    };
