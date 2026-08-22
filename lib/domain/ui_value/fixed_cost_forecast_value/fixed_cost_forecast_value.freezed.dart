// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fixed_cost_forecast_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$FixedCostForecastValue {
  /// 大カテゴリー別の見込み（見込み0円のカテゴリーは含まない）
  List<FixedCostForecastByCategory> get byBigCategory =>
      throw _privateConstructorUsedError;

  /// 対象期間の見込み合計
  int get total => throw _privateConstructorUsedError;

  /// Create a copy of FixedCostForecastValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FixedCostForecastValueCopyWith<FixedCostForecastValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FixedCostForecastValueCopyWith<$Res> {
  factory $FixedCostForecastValueCopyWith(
    FixedCostForecastValue value,
    $Res Function(FixedCostForecastValue) then,
  ) = _$FixedCostForecastValueCopyWithImpl<$Res, FixedCostForecastValue>;
  @useResult
  $Res call({List<FixedCostForecastByCategory> byBigCategory, int total});
}

/// @nodoc
class _$FixedCostForecastValueCopyWithImpl<
  $Res,
  $Val extends FixedCostForecastValue
>
    implements $FixedCostForecastValueCopyWith<$Res> {
  _$FixedCostForecastValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FixedCostForecastValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? byBigCategory = null, Object? total = null}) {
    return _then(
      _value.copyWith(
            byBigCategory: null == byBigCategory
                ? _value.byBigCategory
                : byBigCategory // ignore: cast_nullable_to_non_nullable
                      as List<FixedCostForecastByCategory>,
            total: null == total
                ? _value.total
                : total // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FixedCostForecastValueImplCopyWith<$Res>
    implements $FixedCostForecastValueCopyWith<$Res> {
  factory _$$FixedCostForecastValueImplCopyWith(
    _$FixedCostForecastValueImpl value,
    $Res Function(_$FixedCostForecastValueImpl) then,
  ) = __$$FixedCostForecastValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<FixedCostForecastByCategory> byBigCategory, int total});
}

/// @nodoc
class __$$FixedCostForecastValueImplCopyWithImpl<$Res>
    extends
        _$FixedCostForecastValueCopyWithImpl<$Res, _$FixedCostForecastValueImpl>
    implements _$$FixedCostForecastValueImplCopyWith<$Res> {
  __$$FixedCostForecastValueImplCopyWithImpl(
    _$FixedCostForecastValueImpl _value,
    $Res Function(_$FixedCostForecastValueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FixedCostForecastValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? byBigCategory = null, Object? total = null}) {
    return _then(
      _$FixedCostForecastValueImpl(
        byBigCategory: null == byBigCategory
            ? _value._byBigCategory
            : byBigCategory // ignore: cast_nullable_to_non_nullable
                  as List<FixedCostForecastByCategory>,
        total: null == total
            ? _value.total
            : total // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$FixedCostForecastValueImpl extends _FixedCostForecastValue {
  const _$FixedCostForecastValueImpl({
    required final List<FixedCostForecastByCategory> byBigCategory,
    required this.total,
  }) : _byBigCategory = byBigCategory,
       super._();

  /// 大カテゴリー別の見込み（見込み0円のカテゴリーは含まない）
  final List<FixedCostForecastByCategory> _byBigCategory;

  /// 大カテゴリー別の見込み（見込み0円のカテゴリーは含まない）
  @override
  List<FixedCostForecastByCategory> get byBigCategory {
    if (_byBigCategory is EqualUnmodifiableListView) return _byBigCategory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_byBigCategory);
  }

  /// 対象期間の見込み合計
  @override
  final int total;

  @override
  String toString() {
    return 'FixedCostForecastValue(byBigCategory: $byBigCategory, total: $total)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FixedCostForecastValueImpl &&
            const DeepCollectionEquality().equals(
              other._byBigCategory,
              _byBigCategory,
            ) &&
            (identical(other.total, total) || other.total == total));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_byBigCategory),
    total,
  );

  /// Create a copy of FixedCostForecastValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FixedCostForecastValueImplCopyWith<_$FixedCostForecastValueImpl>
  get copyWith =>
      __$$FixedCostForecastValueImplCopyWithImpl<_$FixedCostForecastValueImpl>(
        this,
        _$identity,
      );
}

abstract class _FixedCostForecastValue extends FixedCostForecastValue {
  const factory _FixedCostForecastValue({
    required final List<FixedCostForecastByCategory> byBigCategory,
    required final int total,
  }) = _$FixedCostForecastValueImpl;
  const _FixedCostForecastValue._() : super._();

  /// 大カテゴリー別の見込み（見込み0円のカテゴリーは含まない）
  @override
  List<FixedCostForecastByCategory> get byBigCategory;

  /// 対象期間の見込み合計
  @override
  int get total;

  /// Create a copy of FixedCostForecastValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FixedCostForecastValueImplCopyWith<_$FixedCostForecastValueImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$FixedCostForecastByCategory {
  int get expenseBigCategoryId => throw _privateConstructorUsedError;
  String get bigCategoryName => throw _privateConstructorUsedError;
  int get amount => throw _privateConstructorUsedError;

  /// Create a copy of FixedCostForecastByCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FixedCostForecastByCategoryCopyWith<FixedCostForecastByCategory>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FixedCostForecastByCategoryCopyWith<$Res> {
  factory $FixedCostForecastByCategoryCopyWith(
    FixedCostForecastByCategory value,
    $Res Function(FixedCostForecastByCategory) then,
  ) =
      _$FixedCostForecastByCategoryCopyWithImpl<
        $Res,
        FixedCostForecastByCategory
      >;
  @useResult
  $Res call({int expenseBigCategoryId, String bigCategoryName, int amount});
}

/// @nodoc
class _$FixedCostForecastByCategoryCopyWithImpl<
  $Res,
  $Val extends FixedCostForecastByCategory
>
    implements $FixedCostForecastByCategoryCopyWith<$Res> {
  _$FixedCostForecastByCategoryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FixedCostForecastByCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expenseBigCategoryId = null,
    Object? bigCategoryName = null,
    Object? amount = null,
  }) {
    return _then(
      _value.copyWith(
            expenseBigCategoryId: null == expenseBigCategoryId
                ? _value.expenseBigCategoryId
                : expenseBigCategoryId // ignore: cast_nullable_to_non_nullable
                      as int,
            bigCategoryName: null == bigCategoryName
                ? _value.bigCategoryName
                : bigCategoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            amount: null == amount
                ? _value.amount
                : amount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FixedCostForecastByCategoryImplCopyWith<$Res>
    implements $FixedCostForecastByCategoryCopyWith<$Res> {
  factory _$$FixedCostForecastByCategoryImplCopyWith(
    _$FixedCostForecastByCategoryImpl value,
    $Res Function(_$FixedCostForecastByCategoryImpl) then,
  ) = __$$FixedCostForecastByCategoryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int expenseBigCategoryId, String bigCategoryName, int amount});
}

/// @nodoc
class __$$FixedCostForecastByCategoryImplCopyWithImpl<$Res>
    extends
        _$FixedCostForecastByCategoryCopyWithImpl<
          $Res,
          _$FixedCostForecastByCategoryImpl
        >
    implements _$$FixedCostForecastByCategoryImplCopyWith<$Res> {
  __$$FixedCostForecastByCategoryImplCopyWithImpl(
    _$FixedCostForecastByCategoryImpl _value,
    $Res Function(_$FixedCostForecastByCategoryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FixedCostForecastByCategory
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expenseBigCategoryId = null,
    Object? bigCategoryName = null,
    Object? amount = null,
  }) {
    return _then(
      _$FixedCostForecastByCategoryImpl(
        expenseBigCategoryId: null == expenseBigCategoryId
            ? _value.expenseBigCategoryId
            : expenseBigCategoryId // ignore: cast_nullable_to_non_nullable
                  as int,
        bigCategoryName: null == bigCategoryName
            ? _value.bigCategoryName
            : bigCategoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        amount: null == amount
            ? _value.amount
            : amount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$FixedCostForecastByCategoryImpl
    implements _FixedCostForecastByCategory {
  const _$FixedCostForecastByCategoryImpl({
    required this.expenseBigCategoryId,
    required this.bigCategoryName,
    required this.amount,
  });

  @override
  final int expenseBigCategoryId;
  @override
  final String bigCategoryName;
  @override
  final int amount;

  @override
  String toString() {
    return 'FixedCostForecastByCategory(expenseBigCategoryId: $expenseBigCategoryId, bigCategoryName: $bigCategoryName, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FixedCostForecastByCategoryImpl &&
            (identical(other.expenseBigCategoryId, expenseBigCategoryId) ||
                other.expenseBigCategoryId == expenseBigCategoryId) &&
            (identical(other.bigCategoryName, bigCategoryName) ||
                other.bigCategoryName == bigCategoryName) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, expenseBigCategoryId, bigCategoryName, amount);

  /// Create a copy of FixedCostForecastByCategory
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FixedCostForecastByCategoryImplCopyWith<_$FixedCostForecastByCategoryImpl>
  get copyWith =>
      __$$FixedCostForecastByCategoryImplCopyWithImpl<
        _$FixedCostForecastByCategoryImpl
      >(this, _$identity);
}

abstract class _FixedCostForecastByCategory
    implements FixedCostForecastByCategory {
  const factory _FixedCostForecastByCategory({
    required final int expenseBigCategoryId,
    required final String bigCategoryName,
    required final int amount,
  }) = _$FixedCostForecastByCategoryImpl;

  @override
  int get expenseBigCategoryId;
  @override
  String get bigCategoryName;
  @override
  int get amount;

  /// Create a copy of FixedCostForecastByCategory
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FixedCostForecastByCategoryImplCopyWith<_$FixedCostForecastByCategoryImpl>
  get copyWith => throw _privateConstructorUsedError;
}
