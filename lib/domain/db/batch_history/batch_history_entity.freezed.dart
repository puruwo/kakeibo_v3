// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'batch_history_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BatchHistoryEntity _$BatchHistoryEntityFromJson(Map<String, dynamic> json) {
  return _BatchHistoryEntity.fromJson(json);
}

/// @nodoc
mixin _$BatchHistoryEntity {
  int? get id => throw _privateConstructorUsedError;
  String get startDate => throw _privateConstructorUsedError;
  String get endDate => throw _privateConstructorUsedError;
  int get status => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BatchHistoryEntityCopyWith<BatchHistoryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BatchHistoryEntityCopyWith<$Res> {
  factory $BatchHistoryEntityCopyWith(
          BatchHistoryEntity value, $Res Function(BatchHistoryEntity) then) =
      _$BatchHistoryEntityCopyWithImpl<$Res, BatchHistoryEntity>;
  @useResult
  $Res call({int? id, String startDate, String endDate, int status});
}

/// @nodoc
class _$BatchHistoryEntityCopyWithImpl<$Res, $Val extends BatchHistoryEntity>
    implements $BatchHistoryEntityCopyWith<$Res> {
  _$BatchHistoryEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? startDate = null,
    Object? endDate = null,
    Object? status = null,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BatchHistoryEntityImplCopyWith<$Res>
    implements $BatchHistoryEntityCopyWith<$Res> {
  factory _$$BatchHistoryEntityImplCopyWith(_$BatchHistoryEntityImpl value,
          $Res Function(_$BatchHistoryEntityImpl) then) =
      __$$BatchHistoryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int? id, String startDate, String endDate, int status});
}

/// @nodoc
class __$$BatchHistoryEntityImplCopyWithImpl<$Res>
    extends _$BatchHistoryEntityCopyWithImpl<$Res, _$BatchHistoryEntityImpl>
    implements _$$BatchHistoryEntityImplCopyWith<$Res> {
  __$$BatchHistoryEntityImplCopyWithImpl(_$BatchHistoryEntityImpl _value,
      $Res Function(_$BatchHistoryEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? startDate = null,
    Object? endDate = null,
    Object? status = null,
  }) {
    return _then(_$BatchHistoryEntityImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int?,
      startDate: null == startDate
          ? _value.startDate
          : startDate // ignore: cast_nullable_to_non_nullable
              as String,
      endDate: null == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as String,
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BatchHistoryEntityImpl implements _BatchHistoryEntity {
  const _$BatchHistoryEntityImpl(
      {this.id,
      required this.startDate,
      required this.endDate,
      required this.status});

  factory _$BatchHistoryEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$BatchHistoryEntityImplFromJson(json);

  @override
  final int? id;
  @override
  final String startDate;
  @override
  final String endDate;
  @override
  final int status;

  @override
  String toString() {
    return 'BatchHistoryEntity(id: $id, startDate: $startDate, endDate: $endDate, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BatchHistoryEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startDate, startDate) ||
                other.startDate == startDate) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, startDate, endDate, status);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BatchHistoryEntityImplCopyWith<_$BatchHistoryEntityImpl> get copyWith =>
      __$$BatchHistoryEntityImplCopyWithImpl<_$BatchHistoryEntityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BatchHistoryEntityImplToJson(
      this,
    );
  }
}

abstract class _BatchHistoryEntity implements BatchHistoryEntity {
  const factory _BatchHistoryEntity(
      {final int? id,
      required final String startDate,
      required final String endDate,
      required final int status}) = _$BatchHistoryEntityImpl;

  factory _BatchHistoryEntity.fromJson(Map<String, dynamic> json) =
      _$BatchHistoryEntityImpl.fromJson;

  @override
  int? get id;
  @override
  String get startDate;
  @override
  String get endDate;
  @override
  int get status;
  @override
  @JsonKey(ignore: true)
  _$$BatchHistoryEntityImplCopyWith<_$BatchHistoryEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
