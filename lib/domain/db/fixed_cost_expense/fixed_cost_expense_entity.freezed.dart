// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fixed_cost_expense_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FixedCostExpenseEntity _$FixedCostExpenseEntityFromJson(
    Map<String, dynamic> json) {
  return _FixedCostExpenseEntity.fromJson(json);
}

/// @nodoc
mixin _$FixedCostExpenseEntity {
  int get id => throw _privateConstructorUsedError;
  int get fixedCostId => throw _privateConstructorUsedError;
  int get fixedCostCategoryId => throw _privateConstructorUsedError;
  String get date => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  int get confirmedCostType =>
      throw _privateConstructorUsedError; // 0: 金額確定固定費, 1: 金額未確定固定費
  int get isConfirmed => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FixedCostExpenseEntityCopyWith<FixedCostExpenseEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FixedCostExpenseEntityCopyWith<$Res> {
  factory $FixedCostExpenseEntityCopyWith(FixedCostExpenseEntity value,
          $Res Function(FixedCostExpenseEntity) then) =
      _$FixedCostExpenseEntityCopyWithImpl<$Res, FixedCostExpenseEntity>;
  @useResult
  $Res call(
      {int id,
      int fixedCostId,
      int fixedCostCategoryId,
      String date,
      int price,
      String name,
      int confirmedCostType,
      int isConfirmed});
}

/// @nodoc
class _$FixedCostExpenseEntityCopyWithImpl<$Res,
        $Val extends FixedCostExpenseEntity>
    implements $FixedCostExpenseEntityCopyWith<$Res> {
  _$FixedCostExpenseEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fixedCostId = null,
    Object? fixedCostCategoryId = null,
    Object? date = null,
    Object? price = null,
    Object? name = null,
    Object? confirmedCostType = null,
    Object? isConfirmed = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      fixedCostId: null == fixedCostId
          ? _value.fixedCostId
          : fixedCostId // ignore: cast_nullable_to_non_nullable
              as int,
      fixedCostCategoryId: null == fixedCostCategoryId
          ? _value.fixedCostCategoryId
          : fixedCostCategoryId // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      confirmedCostType: null == confirmedCostType
          ? _value.confirmedCostType
          : confirmedCostType // ignore: cast_nullable_to_non_nullable
              as int,
      isConfirmed: null == isConfirmed
          ? _value.isConfirmed
          : isConfirmed // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FixedCostExpenseEntityImplCopyWith<$Res>
    implements $FixedCostExpenseEntityCopyWith<$Res> {
  factory _$$FixedCostExpenseEntityImplCopyWith(
          _$FixedCostExpenseEntityImpl value,
          $Res Function(_$FixedCostExpenseEntityImpl) then) =
      __$$FixedCostExpenseEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int fixedCostId,
      int fixedCostCategoryId,
      String date,
      int price,
      String name,
      int confirmedCostType,
      int isConfirmed});
}

/// @nodoc
class __$$FixedCostExpenseEntityImplCopyWithImpl<$Res>
    extends _$FixedCostExpenseEntityCopyWithImpl<$Res,
        _$FixedCostExpenseEntityImpl>
    implements _$$FixedCostExpenseEntityImplCopyWith<$Res> {
  __$$FixedCostExpenseEntityImplCopyWithImpl(
      _$FixedCostExpenseEntityImpl _value,
      $Res Function(_$FixedCostExpenseEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? fixedCostId = null,
    Object? fixedCostCategoryId = null,
    Object? date = null,
    Object? price = null,
    Object? name = null,
    Object? confirmedCostType = null,
    Object? isConfirmed = null,
  }) {
    return _then(_$FixedCostExpenseEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      fixedCostId: null == fixedCostId
          ? _value.fixedCostId
          : fixedCostId // ignore: cast_nullable_to_non_nullable
              as int,
      fixedCostCategoryId: null == fixedCostCategoryId
          ? _value.fixedCostCategoryId
          : fixedCostCategoryId // ignore: cast_nullable_to_non_nullable
              as int,
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      confirmedCostType: null == confirmedCostType
          ? _value.confirmedCostType
          : confirmedCostType // ignore: cast_nullable_to_non_nullable
              as int,
      isConfirmed: null == isConfirmed
          ? _value.isConfirmed
          : isConfirmed // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$FixedCostExpenseEntityImpl implements _FixedCostExpenseEntity {
  const _$FixedCostExpenseEntityImpl(
      {this.id = 0,
      this.fixedCostId = 0,
      required this.fixedCostCategoryId,
      required this.date,
      this.price = 0,
      this.name = '',
      this.confirmedCostType = 0,
      this.isConfirmed = 1});

  factory _$FixedCostExpenseEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$FixedCostExpenseEntityImplFromJson(json);

  @override
  @JsonKey()
  final int id;
  @override
  @JsonKey()
  final int fixedCostId;
  @override
  final int fixedCostCategoryId;
  @override
  final String date;
  @override
  @JsonKey()
  final int price;
  @override
  @JsonKey()
  final String name;
  @override
  @JsonKey()
  final int confirmedCostType;
// 0: 金額確定固定費, 1: 金額未確定固定費
  @override
  @JsonKey()
  final int isConfirmed;

  @override
  String toString() {
    return 'FixedCostExpenseEntity(id: $id, fixedCostId: $fixedCostId, fixedCostCategoryId: $fixedCostCategoryId, date: $date, price: $price, name: $name, confirmedCostType: $confirmedCostType, isConfirmed: $isConfirmed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FixedCostExpenseEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.fixedCostId, fixedCostId) ||
                other.fixedCostId == fixedCostId) &&
            (identical(other.fixedCostCategoryId, fixedCostCategoryId) ||
                other.fixedCostCategoryId == fixedCostCategoryId) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.confirmedCostType, confirmedCostType) ||
                other.confirmedCostType == confirmedCostType) &&
            (identical(other.isConfirmed, isConfirmed) ||
                other.isConfirmed == isConfirmed));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, fixedCostId,
      fixedCostCategoryId, date, price, name, confirmedCostType, isConfirmed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FixedCostExpenseEntityImplCopyWith<_$FixedCostExpenseEntityImpl>
      get copyWith => __$$FixedCostExpenseEntityImplCopyWithImpl<
          _$FixedCostExpenseEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FixedCostExpenseEntityImplToJson(
      this,
    );
  }
}

abstract class _FixedCostExpenseEntity implements FixedCostExpenseEntity {
  const factory _FixedCostExpenseEntity(
      {final int id,
      final int fixedCostId,
      required final int fixedCostCategoryId,
      required final String date,
      final int price,
      final String name,
      final int confirmedCostType,
      final int isConfirmed}) = _$FixedCostExpenseEntityImpl;

  factory _FixedCostExpenseEntity.fromJson(Map<String, dynamic> json) =
      _$FixedCostExpenseEntityImpl.fromJson;

  @override
  int get id;
  @override
  int get fixedCostId;
  @override
  int get fixedCostCategoryId;
  @override
  String get date;
  @override
  int get price;
  @override
  String get name;
  @override
  int get confirmedCostType;
  @override // 0: 金額確定固定費, 1: 金額未確定固定費
  int get isConfirmed;
  @override
  @JsonKey(ignore: true)
  _$$FixedCostExpenseEntityImplCopyWith<_$FixedCostExpenseEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
