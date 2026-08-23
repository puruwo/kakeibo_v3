// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_fixed_cost_big_category_summary_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MonthlyFixedCostBigCategorySummaryValue {
  /// 支出大カテゴリーid（v10で固定費カテゴリーから移行）
  int get expenseBigCategoryId => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  String get colorCode => throw _privateConstructorUsedError;
  String get resourcePath => throw _privateConstructorUsedError;

  /// 全て確定している場合はtrue
  bool get isAllConfirmed => throw _privateConstructorUsedError;

  /// カテゴリー内の確定済み固定費の合計
  int get totalAmount => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyFixedCostBigCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyFixedCostBigCategorySummaryValueCopyWith<
    MonthlyFixedCostBigCategorySummaryValue
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyFixedCostBigCategorySummaryValueCopyWith<$Res> {
  factory $MonthlyFixedCostBigCategorySummaryValueCopyWith(
    MonthlyFixedCostBigCategorySummaryValue value,
    $Res Function(MonthlyFixedCostBigCategorySummaryValue) then,
  ) =
      _$MonthlyFixedCostBigCategorySummaryValueCopyWithImpl<
        $Res,
        MonthlyFixedCostBigCategorySummaryValue
      >;
  @useResult
  $Res call({
    int expenseBigCategoryId,
    String categoryName,
    String colorCode,
    String resourcePath,
    bool isAllConfirmed,
    int totalAmount,
  });
}

/// @nodoc
class _$MonthlyFixedCostBigCategorySummaryValueCopyWithImpl<
  $Res,
  $Val extends MonthlyFixedCostBigCategorySummaryValue
>
    implements $MonthlyFixedCostBigCategorySummaryValueCopyWith<$Res> {
  _$MonthlyFixedCostBigCategorySummaryValueCopyWithImpl(
    this._value,
    this._then,
  );

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyFixedCostBigCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expenseBigCategoryId = null,
    Object? categoryName = null,
    Object? colorCode = null,
    Object? resourcePath = null,
    Object? isAllConfirmed = null,
    Object? totalAmount = null,
  }) {
    return _then(
      _value.copyWith(
            expenseBigCategoryId: null == expenseBigCategoryId
                ? _value.expenseBigCategoryId
                : expenseBigCategoryId // ignore: cast_nullable_to_non_nullable
                      as int,
            categoryName: null == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            colorCode: null == colorCode
                ? _value.colorCode
                : colorCode // ignore: cast_nullable_to_non_nullable
                      as String,
            resourcePath: null == resourcePath
                ? _value.resourcePath
                : resourcePath // ignore: cast_nullable_to_non_nullable
                      as String,
            isAllConfirmed: null == isAllConfirmed
                ? _value.isAllConfirmed
                : isAllConfirmed // ignore: cast_nullable_to_non_nullable
                      as bool,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MonthlyFixedCostBigCategorySummaryValueImplCopyWith<$Res>
    implements $MonthlyFixedCostBigCategorySummaryValueCopyWith<$Res> {
  factory _$$MonthlyFixedCostBigCategorySummaryValueImplCopyWith(
    _$MonthlyFixedCostBigCategorySummaryValueImpl value,
    $Res Function(_$MonthlyFixedCostBigCategorySummaryValueImpl) then,
  ) = __$$MonthlyFixedCostBigCategorySummaryValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int expenseBigCategoryId,
    String categoryName,
    String colorCode,
    String resourcePath,
    bool isAllConfirmed,
    int totalAmount,
  });
}

/// @nodoc
class __$$MonthlyFixedCostBigCategorySummaryValueImplCopyWithImpl<$Res>
    extends
        _$MonthlyFixedCostBigCategorySummaryValueCopyWithImpl<
          $Res,
          _$MonthlyFixedCostBigCategorySummaryValueImpl
        >
    implements _$$MonthlyFixedCostBigCategorySummaryValueImplCopyWith<$Res> {
  __$$MonthlyFixedCostBigCategorySummaryValueImplCopyWithImpl(
    _$MonthlyFixedCostBigCategorySummaryValueImpl _value,
    $Res Function(_$MonthlyFixedCostBigCategorySummaryValueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthlyFixedCostBigCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expenseBigCategoryId = null,
    Object? categoryName = null,
    Object? colorCode = null,
    Object? resourcePath = null,
    Object? isAllConfirmed = null,
    Object? totalAmount = null,
  }) {
    return _then(
      _$MonthlyFixedCostBigCategorySummaryValueImpl(
        expenseBigCategoryId: null == expenseBigCategoryId
            ? _value.expenseBigCategoryId
            : expenseBigCategoryId // ignore: cast_nullable_to_non_nullable
                  as int,
        categoryName: null == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        colorCode: null == colorCode
            ? _value.colorCode
            : colorCode // ignore: cast_nullable_to_non_nullable
                  as String,
        resourcePath: null == resourcePath
            ? _value.resourcePath
            : resourcePath // ignore: cast_nullable_to_non_nullable
                  as String,
        isAllConfirmed: null == isAllConfirmed
            ? _value.isAllConfirmed
            : isAllConfirmed // ignore: cast_nullable_to_non_nullable
                  as bool,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$MonthlyFixedCostBigCategorySummaryValueImpl
    implements _MonthlyFixedCostBigCategorySummaryValue {
  const _$MonthlyFixedCostBigCategorySummaryValueImpl({
    required this.expenseBigCategoryId,
    required this.categoryName,
    required this.colorCode,
    required this.resourcePath,
    required this.isAllConfirmed,
    required this.totalAmount,
  });

  /// 支出大カテゴリーid（v10で固定費カテゴリーから移行）
  @override
  final int expenseBigCategoryId;
  @override
  final String categoryName;
  @override
  final String colorCode;
  @override
  final String resourcePath;

  /// 全て確定している場合はtrue
  @override
  final bool isAllConfirmed;

  /// カテゴリー内の確定済み固定費の合計
  @override
  final int totalAmount;

  @override
  String toString() {
    return 'MonthlyFixedCostBigCategorySummaryValue(expenseBigCategoryId: $expenseBigCategoryId, categoryName: $categoryName, colorCode: $colorCode, resourcePath: $resourcePath, isAllConfirmed: $isAllConfirmed, totalAmount: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyFixedCostBigCategorySummaryValueImpl &&
            (identical(other.expenseBigCategoryId, expenseBigCategoryId) ||
                other.expenseBigCategoryId == expenseBigCategoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.colorCode, colorCode) ||
                other.colorCode == colorCode) &&
            (identical(other.resourcePath, resourcePath) ||
                other.resourcePath == resourcePath) &&
            (identical(other.isAllConfirmed, isAllConfirmed) ||
                other.isAllConfirmed == isAllConfirmed) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    expenseBigCategoryId,
    categoryName,
    colorCode,
    resourcePath,
    isAllConfirmed,
    totalAmount,
  );

  /// Create a copy of MonthlyFixedCostBigCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyFixedCostBigCategorySummaryValueImplCopyWith<
    _$MonthlyFixedCostBigCategorySummaryValueImpl
  >
  get copyWith =>
      __$$MonthlyFixedCostBigCategorySummaryValueImplCopyWithImpl<
        _$MonthlyFixedCostBigCategorySummaryValueImpl
      >(this, _$identity);
}

abstract class _MonthlyFixedCostBigCategorySummaryValue
    implements MonthlyFixedCostBigCategorySummaryValue {
  const factory _MonthlyFixedCostBigCategorySummaryValue({
    required final int expenseBigCategoryId,
    required final String categoryName,
    required final String colorCode,
    required final String resourcePath,
    required final bool isAllConfirmed,
    required final int totalAmount,
  }) = _$MonthlyFixedCostBigCategorySummaryValueImpl;

  /// 支出大カテゴリーid（v10で固定費カテゴリーから移行）
  @override
  int get expenseBigCategoryId;
  @override
  String get categoryName;
  @override
  String get colorCode;
  @override
  String get resourcePath;

  /// 全て確定している場合はtrue
  @override
  bool get isAllConfirmed;

  /// カテゴリー内の確定済み固定費の合計
  @override
  int get totalAmount;

  /// Create a copy of MonthlyFixedCostBigCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyFixedCostBigCategorySummaryValueImplCopyWith<
    _$MonthlyFixedCostBigCategorySummaryValueImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
