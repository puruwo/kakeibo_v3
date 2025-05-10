// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'budget_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

BudgetEntity _$BudgetEntityFromJson(Map<String, dynamic> json) {
  return _BudgetEntity.fromJson(json);
}

/// @nodoc
mixin _$BudgetEntity {
  int get id => throw _privateConstructorUsedError;
  int get expenseBigCategoryId => throw _privateConstructorUsedError;
  String get month => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BudgetEntityCopyWith<BudgetEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BudgetEntityCopyWith<$Res> {
  factory $BudgetEntityCopyWith(
          BudgetEntity value, $Res Function(BudgetEntity) then) =
      _$BudgetEntityCopyWithImpl<$Res, BudgetEntity>;
  @useResult
  $Res call({int id, int expenseBigCategoryId, String month, int price});
}

/// @nodoc
class _$BudgetEntityCopyWithImpl<$Res, $Val extends BudgetEntity>
    implements $BudgetEntityCopyWith<$Res> {
  _$BudgetEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? expenseBigCategoryId = null,
    Object? month = null,
    Object? price = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      expenseBigCategoryId: null == expenseBigCategoryId
          ? _value.expenseBigCategoryId
          : expenseBigCategoryId // ignore: cast_nullable_to_non_nullable
              as int,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BudgetEntityImplCopyWith<$Res>
    implements $BudgetEntityCopyWith<$Res> {
  factory _$$BudgetEntityImplCopyWith(
          _$BudgetEntityImpl value, $Res Function(_$BudgetEntityImpl) then) =
      __$$BudgetEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int id, int expenseBigCategoryId, String month, int price});
}

/// @nodoc
class __$$BudgetEntityImplCopyWithImpl<$Res>
    extends _$BudgetEntityCopyWithImpl<$Res, _$BudgetEntityImpl>
    implements _$$BudgetEntityImplCopyWith<$Res> {
  __$$BudgetEntityImplCopyWithImpl(
      _$BudgetEntityImpl _value, $Res Function(_$BudgetEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? expenseBigCategoryId = null,
    Object? month = null,
    Object? price = null,
  }) {
    return _then(_$BudgetEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      expenseBigCategoryId: null == expenseBigCategoryId
          ? _value.expenseBigCategoryId
          : expenseBigCategoryId // ignore: cast_nullable_to_non_nullable
              as int,
      month: null == month
          ? _value.month
          : month // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BudgetEntityImpl implements _BudgetEntity {
  const _$BudgetEntityImpl(
      {this.id = 0,
      this.expenseBigCategoryId = 0,
      required this.month,
      this.price = 0});

  factory _$BudgetEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$BudgetEntityImplFromJson(json);

  @override
  @JsonKey()
  final int id;
  @override
  @JsonKey()
  final int expenseBigCategoryId;
  @override
  final String month;
  @override
  @JsonKey()
  final int price;

  @override
  String toString() {
    return 'BudgetEntity(id: $id, expenseBigCategoryId: $expenseBigCategoryId, month: $month, price: $price)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BudgetEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.expenseBigCategoryId, expenseBigCategoryId) ||
                other.expenseBigCategoryId == expenseBigCategoryId) &&
            (identical(other.month, month) || other.month == month) &&
            (identical(other.price, price) || other.price == price));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, expenseBigCategoryId, month, price);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BudgetEntityImplCopyWith<_$BudgetEntityImpl> get copyWith =>
      __$$BudgetEntityImplCopyWithImpl<_$BudgetEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BudgetEntityImplToJson(
      this,
    );
  }
}

abstract class _BudgetEntity implements BudgetEntity {
  const factory _BudgetEntity(
      {final int id,
      final int expenseBigCategoryId,
      required final String month,
      final int price}) = _$BudgetEntityImpl;

  factory _BudgetEntity.fromJson(Map<String, dynamic> json) =
      _$BudgetEntityImpl.fromJson;

  @override
  int get id;
  @override
  int get expenseBigCategoryId;
  @override
  String get month;
  @override
  int get price;
  @override
  @JsonKey(ignore: true)
  _$$BudgetEntityImplCopyWith<_$BudgetEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
