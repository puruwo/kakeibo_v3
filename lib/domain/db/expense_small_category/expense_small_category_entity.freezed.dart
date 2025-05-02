// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_small_category_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ExpenseSmallCategoryEntity _$ExpenseSmallCategoryEntityFromJson(
    Map<String, dynamic> json) {
  return _SmallCategoryEntity.fromJson(json);
}

/// @nodoc
mixin _$ExpenseSmallCategoryEntity {
  int get id => throw _privateConstructorUsedError;
  int get smallCategoryOrderKey => throw _privateConstructorUsedError;
  int get bigCategoryKey => throw _privateConstructorUsedError;
  int get displayedOrderInBig => throw _privateConstructorUsedError;
  String get smallCategoryName => throw _privateConstructorUsedError;
  int get defaultDisplayed => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExpenseSmallCategoryEntityCopyWith<ExpenseSmallCategoryEntity>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseSmallCategoryEntityCopyWith<$Res> {
  factory $ExpenseSmallCategoryEntityCopyWith(ExpenseSmallCategoryEntity value,
          $Res Function(ExpenseSmallCategoryEntity) then) =
      _$ExpenseSmallCategoryEntityCopyWithImpl<$Res,
          ExpenseSmallCategoryEntity>;
  @useResult
  $Res call(
      {int id,
      int smallCategoryOrderKey,
      int bigCategoryKey,
      int displayedOrderInBig,
      String smallCategoryName,
      int defaultDisplayed});
}

/// @nodoc
class _$ExpenseSmallCategoryEntityCopyWithImpl<$Res,
        $Val extends ExpenseSmallCategoryEntity>
    implements $ExpenseSmallCategoryEntityCopyWith<$Res> {
  _$ExpenseSmallCategoryEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? smallCategoryOrderKey = null,
    Object? bigCategoryKey = null,
    Object? displayedOrderInBig = null,
    Object? smallCategoryName = null,
    Object? defaultDisplayed = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      smallCategoryOrderKey: null == smallCategoryOrderKey
          ? _value.smallCategoryOrderKey
          : smallCategoryOrderKey // ignore: cast_nullable_to_non_nullable
              as int,
      bigCategoryKey: null == bigCategoryKey
          ? _value.bigCategoryKey
          : bigCategoryKey // ignore: cast_nullable_to_non_nullable
              as int,
      displayedOrderInBig: null == displayedOrderInBig
          ? _value.displayedOrderInBig
          : displayedOrderInBig // ignore: cast_nullable_to_non_nullable
              as int,
      smallCategoryName: null == smallCategoryName
          ? _value.smallCategoryName
          : smallCategoryName // ignore: cast_nullable_to_non_nullable
              as String,
      defaultDisplayed: null == defaultDisplayed
          ? _value.defaultDisplayed
          : defaultDisplayed // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SmallCategoryEntityImplCopyWith<$Res>
    implements $ExpenseSmallCategoryEntityCopyWith<$Res> {
  factory _$$SmallCategoryEntityImplCopyWith(_$SmallCategoryEntityImpl value,
          $Res Function(_$SmallCategoryEntityImpl) then) =
      __$$SmallCategoryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      int smallCategoryOrderKey,
      int bigCategoryKey,
      int displayedOrderInBig,
      String smallCategoryName,
      int defaultDisplayed});
}

/// @nodoc
class __$$SmallCategoryEntityImplCopyWithImpl<$Res>
    extends _$ExpenseSmallCategoryEntityCopyWithImpl<$Res,
        _$SmallCategoryEntityImpl>
    implements _$$SmallCategoryEntityImplCopyWith<$Res> {
  __$$SmallCategoryEntityImplCopyWithImpl(_$SmallCategoryEntityImpl _value,
      $Res Function(_$SmallCategoryEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? smallCategoryOrderKey = null,
    Object? bigCategoryKey = null,
    Object? displayedOrderInBig = null,
    Object? smallCategoryName = null,
    Object? defaultDisplayed = null,
  }) {
    return _then(_$SmallCategoryEntityImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      smallCategoryOrderKey: null == smallCategoryOrderKey
          ? _value.smallCategoryOrderKey
          : smallCategoryOrderKey // ignore: cast_nullable_to_non_nullable
              as int,
      bigCategoryKey: null == bigCategoryKey
          ? _value.bigCategoryKey
          : bigCategoryKey // ignore: cast_nullable_to_non_nullable
              as int,
      displayedOrderInBig: null == displayedOrderInBig
          ? _value.displayedOrderInBig
          : displayedOrderInBig // ignore: cast_nullable_to_non_nullable
              as int,
      smallCategoryName: null == smallCategoryName
          ? _value.smallCategoryName
          : smallCategoryName // ignore: cast_nullable_to_non_nullable
              as String,
      defaultDisplayed: null == defaultDisplayed
          ? _value.defaultDisplayed
          : defaultDisplayed // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SmallCategoryEntityImpl extends _SmallCategoryEntity {
  const _$SmallCategoryEntityImpl(
      {required this.id,
      required this.smallCategoryOrderKey,
      required this.bigCategoryKey,
      required this.displayedOrderInBig,
      required this.smallCategoryName,
      required this.defaultDisplayed})
      : super._();

  factory _$SmallCategoryEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$SmallCategoryEntityImplFromJson(json);

  @override
  final int id;
  @override
  final int smallCategoryOrderKey;
  @override
  final int bigCategoryKey;
  @override
  final int displayedOrderInBig;
  @override
  final String smallCategoryName;
  @override
  final int defaultDisplayed;

  @override
  String toString() {
    return 'ExpenseSmallCategoryEntity(id: $id, smallCategoryOrderKey: $smallCategoryOrderKey, bigCategoryKey: $bigCategoryKey, displayedOrderInBig: $displayedOrderInBig, smallCategoryName: $smallCategoryName, defaultDisplayed: $defaultDisplayed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SmallCategoryEntityImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.smallCategoryOrderKey, smallCategoryOrderKey) ||
                other.smallCategoryOrderKey == smallCategoryOrderKey) &&
            (identical(other.bigCategoryKey, bigCategoryKey) ||
                other.bigCategoryKey == bigCategoryKey) &&
            (identical(other.displayedOrderInBig, displayedOrderInBig) ||
                other.displayedOrderInBig == displayedOrderInBig) &&
            (identical(other.smallCategoryName, smallCategoryName) ||
                other.smallCategoryName == smallCategoryName) &&
            (identical(other.defaultDisplayed, defaultDisplayed) ||
                other.defaultDisplayed == defaultDisplayed));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, smallCategoryOrderKey,
      bigCategoryKey, displayedOrderInBig, smallCategoryName, defaultDisplayed);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$SmallCategoryEntityImplCopyWith<_$SmallCategoryEntityImpl> get copyWith =>
      __$$SmallCategoryEntityImplCopyWithImpl<_$SmallCategoryEntityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SmallCategoryEntityImplToJson(
      this,
    );
  }
}

abstract class _SmallCategoryEntity extends ExpenseSmallCategoryEntity {
  const factory _SmallCategoryEntity(
      {required final int id,
      required final int smallCategoryOrderKey,
      required final int bigCategoryKey,
      required final int displayedOrderInBig,
      required final String smallCategoryName,
      required final int defaultDisplayed}) = _$SmallCategoryEntityImpl;
  const _SmallCategoryEntity._() : super._();

  factory _SmallCategoryEntity.fromJson(Map<String, dynamic> json) =
      _$SmallCategoryEntityImpl.fromJson;

  @override
  int get id;
  @override
  int get smallCategoryOrderKey;
  @override
  int get bigCategoryKey;
  @override
  int get displayedOrderInBig;
  @override
  String get smallCategoryName;
  @override
  int get defaultDisplayed;
  @override
  @JsonKey(ignore: true)
  _$$SmallCategoryEntityImplCopyWith<_$SmallCategoryEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
