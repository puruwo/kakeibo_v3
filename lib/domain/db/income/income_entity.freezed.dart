// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'income_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IncomeEntity _$IncomeEntityFromJson(Map<String, dynamic> json) {
  return _IncomeEntity.fromJson(json);
}

/// @nodoc
mixin _$IncomeEntity {
  int get id => throw _privateConstructorUsedError;
  int get categoryId => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;
  String get memo => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IncomeEntityCopyWith<IncomeEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IncomeEntityCopyWith<$Res> {
  factory $IncomeEntityCopyWith(
          IncomeEntity value, $Res Function(IncomeEntity) then) =
      _$IncomeEntityCopyWithImpl<$Res, IncomeEntity>;
  @useResult
  $Res call({int id, int categoryId, String date, int price, String memo});
}

/// @nodoc
class _$IncomeEntityCopyWithImpl<$Res, $Val extends IncomeEntity>
    implements $IncomeEntityCopyWith<$Res> {
  _$IncomeEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = null,
    Object? date = null,
    Object? price = null,
    Object? memo = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      memo: null == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IncomeEntityImplCopyWith<$Res>
    implements $IncomeEntityCopyWith<$Res> {
  factory _$$IncomeEntityImplCopyWith(
          _$IncomeEntityImpl value, $Res Function(_$IncomeEntityImpl) then) =
      __$$IncomeEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, int categoryId, String date, int price, String memo});
}

/// @nodoc
class __$$IncomeEntityImplCopyWithImpl<$Res>
    extends _$IncomeEntityCopyWithImpl<$Res, _$IncomeEntityImpl>
    implements _$$IncomeEntityImplCopyWith<$Res> {
  __$$IncomeEntityImplCopyWithImpl(
      _$IncomeEntityImpl _value, $Res Function(_$IncomeEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? categoryId = null,
    Object? date = null,
    Object? price = null,
    Object? memo = null,
  }) {
    return _then(_$IncomeEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      categoryId: null == categoryId
          ? _value.categoryId
          : categoryId // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      memo: null == memo
          ? _value.memo
          : memo // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$IncomeEntityImpl implements _IncomeEntity {
  const _$IncomeEntityImpl(
      {this.id = 0,
      this.categoryId = IncomeBigCategoryConstants.incomeSourceIdSalary,
      required this.date,
      this.price = 0,
      this.memo = ''});

  factory _$IncomeEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$IncomeEntityImplFromJson(json);

  @override
  @JsonKey()
  final int id;
  @override
  @JsonKey()
  final int categoryId;
  @override
  final String date;
  @override
  @JsonKey()
  final int price;
  @override
  @JsonKey()
  final String memo;

  @override
  String toString() {
    return 'IncomeEntity(id: $id, categoryId: $categoryId, date: $date, price: $price, memo: $memo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IncomeEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.categoryId, categoryId) ||
                other.categoryId == categoryId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.memo, memo) || other.memo == memo));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, categoryId, date, price, memo);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IncomeEntityImplCopyWith<_$IncomeEntityImpl> get copyWith =>
      __$$IncomeEntityImplCopyWithImpl<_$IncomeEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IncomeEntityImplToJson(
      this,
    );
  }
}

abstract class _IncomeEntity implements IncomeEntity {
  const factory _IncomeEntity(
      {final int id,
      final int categoryId,
      required final String date,
      final int price,
      final String memo}) = _$IncomeEntityImpl;

  factory _IncomeEntity.fromJson(Map<String, dynamic> json) =
      _$IncomeEntityImpl.fromJson;

  @override
  int get id;
  @override
  int get categoryId;
  @override
  String get date;
  @override
  int get price;
  @override
  String get memo;
  @override
  @JsonKey(ignore: true)
  _$$IncomeEntityImplCopyWith<_$IncomeEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
