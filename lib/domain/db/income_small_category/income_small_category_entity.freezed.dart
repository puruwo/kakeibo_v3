// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'income_small_category_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

IncomeSmallCategoryEntity _$IncomeSmallCategoryEntityFromJson(
    Map<String, dynamic> json) {
  return _IncomeSmallCategoryEntity.fromJson(json);
}

/// @nodoc
mixin _$IncomeSmallCategoryEntity {
  int get id => throw _privateConstructorUsedError;
  int get smallCategoryOrderKey => throw _privateConstructorUsedError;
  int get bigCategoryKey => throw _privateConstructorUsedError;
  int get displayedOrderInBig => throw _privateConstructorUsedError;
  String get smallCategoryName => throw _privateConstructorUsedError;
  int get defaultDisplayed => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $IncomeSmallCategoryEntityCopyWith<IncomeSmallCategoryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IncomeSmallCategoryEntityCopyWith<$Res> {
  factory $IncomeSmallCategoryEntityCopyWith(IncomeSmallCategoryEntity value,
          $Res Function(IncomeSmallCategoryEntity) then) =
      _$IncomeSmallCategoryEntityCopyWithImpl<$Res, IncomeSmallCategoryEntity>;
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
class _$IncomeSmallCategoryEntityCopyWithImpl<$Res,
        $Val extends IncomeSmallCategoryEntity>
    implements $IncomeSmallCategoryEntityCopyWith<$Res> {
  _$IncomeSmallCategoryEntityCopyWithImpl(this._value, this._then);

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
abstract class _$$IncomeSmallCategoryEntityImplCopyWith<$Res>
    implements $IncomeSmallCategoryEntityCopyWith<$Res> {
  factory _$$IncomeSmallCategoryEntityImplCopyWith(
          _$IncomeSmallCategoryEntityImpl value,
          $Res Function(_$IncomeSmallCategoryEntityImpl) then) =
      __$$IncomeSmallCategoryEntityImplCopyWithImpl<$Res>;
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
class __$$IncomeSmallCategoryEntityImplCopyWithImpl<$Res>
    extends _$IncomeSmallCategoryEntityCopyWithImpl<$Res,
        _$IncomeSmallCategoryEntityImpl>
    implements _$$IncomeSmallCategoryEntityImplCopyWith<$Res> {
  __$$IncomeSmallCategoryEntityImplCopyWithImpl(
      _$IncomeSmallCategoryEntityImpl _value,
      $Res Function(_$IncomeSmallCategoryEntityImpl) _then)
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
    return _then(_$IncomeSmallCategoryEntityImpl(
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
class _$IncomeSmallCategoryEntityImpl extends _IncomeSmallCategoryEntity {
  const _$IncomeSmallCategoryEntityImpl(
      {required this.id,
      required this.smallCategoryOrderKey,
      required this.bigCategoryKey,
      required this.displayedOrderInBig,
      required this.smallCategoryName,
      required this.defaultDisplayed})
      : super._();

  factory _$IncomeSmallCategoryEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$IncomeSmallCategoryEntityImplFromJson(json);

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
    return 'IncomeSmallCategoryEntity(id: $id, smallCategoryOrderKey: $smallCategoryOrderKey, bigCategoryKey: $bigCategoryKey, displayedOrderInBig: $displayedOrderInBig, smallCategoryName: $smallCategoryName, defaultDisplayed: $defaultDisplayed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IncomeSmallCategoryEntityImpl &&
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
  _$$IncomeSmallCategoryEntityImplCopyWith<_$IncomeSmallCategoryEntityImpl>
      get copyWith => __$$IncomeSmallCategoryEntityImplCopyWithImpl<
          _$IncomeSmallCategoryEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$IncomeSmallCategoryEntityImplToJson(
      this,
    );
  }
}

abstract class _IncomeSmallCategoryEntity extends IncomeSmallCategoryEntity {
  const factory _IncomeSmallCategoryEntity(
      {required final int id,
      required final int smallCategoryOrderKey,
      required final int bigCategoryKey,
      required final int displayedOrderInBig,
      required final String smallCategoryName,
      required final int defaultDisplayed}) = _$IncomeSmallCategoryEntityImpl;
  const _IncomeSmallCategoryEntity._() : super._();

  factory _IncomeSmallCategoryEntity.fromJson(Map<String, dynamic> json) =
      _$IncomeSmallCategoryEntityImpl.fromJson;

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
  _$$IncomeSmallCategoryEntityImplCopyWith<_$IncomeSmallCategoryEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
