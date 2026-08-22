// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'monthly_fixed_cost_category_summary_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$MonthlyFixedCostCategorySummaryValue {
  /// 支出大カテゴリーid（v10で固定費カテゴリーから移行）
  int get expenseBigCategoryId => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;
  String get colorCode => throw _privateConstructorUsedError;
  String get resourcePath => throw _privateConstructorUsedError;

  /// 全て確定している場合はtrue
  bool get isAllConfirmed => throw _privateConstructorUsedError;

  /// カテゴリー内の確定済み固定費の合計
  int get totalAmount => throw _privateConstructorUsedError;

  /// Create a copy of MonthlyFixedCostCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MonthlyFixedCostCategorySummaryValueCopyWith<
    MonthlyFixedCostCategorySummaryValue
  >
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MonthlyFixedCostCategorySummaryValueCopyWith<$Res> {
  factory $MonthlyFixedCostCategorySummaryValueCopyWith(
    MonthlyFixedCostCategorySummaryValue value,
    $Res Function(MonthlyFixedCostCategorySummaryValue) then,
  ) =
      _$MonthlyFixedCostCategorySummaryValueCopyWithImpl<
        $Res,
        MonthlyFixedCostCategorySummaryValue
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
class _$MonthlyFixedCostCategorySummaryValueCopyWithImpl<
  $Res,
  $Val extends MonthlyFixedCostCategorySummaryValue
>
    implements $MonthlyFixedCostCategorySummaryValueCopyWith<$Res> {
  _$MonthlyFixedCostCategorySummaryValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MonthlyFixedCostCategorySummaryValue
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
abstract class _$$MonthlyFixedCostCategorySummaryValueImplCopyWith<$Res>
    implements $MonthlyFixedCostCategorySummaryValueCopyWith<$Res> {
  factory _$$MonthlyFixedCostCategorySummaryValueImplCopyWith(
    _$MonthlyFixedCostCategorySummaryValueImpl value,
    $Res Function(_$MonthlyFixedCostCategorySummaryValueImpl) then,
  ) = __$$MonthlyFixedCostCategorySummaryValueImplCopyWithImpl<$Res>;
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
class __$$MonthlyFixedCostCategorySummaryValueImplCopyWithImpl<$Res>
    extends
        _$MonthlyFixedCostCategorySummaryValueCopyWithImpl<
          $Res,
          _$MonthlyFixedCostCategorySummaryValueImpl
        >
    implements _$$MonthlyFixedCostCategorySummaryValueImplCopyWith<$Res> {
  __$$MonthlyFixedCostCategorySummaryValueImplCopyWithImpl(
    _$MonthlyFixedCostCategorySummaryValueImpl _value,
    $Res Function(_$MonthlyFixedCostCategorySummaryValueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MonthlyFixedCostCategorySummaryValue
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
      _$MonthlyFixedCostCategorySummaryValueImpl(
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

class _$MonthlyFixedCostCategorySummaryValueImpl
    implements _MonthlyFixedCostCategorySummaryValue {
  const _$MonthlyFixedCostCategorySummaryValueImpl({
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
    return 'MonthlyFixedCostCategorySummaryValue(expenseBigCategoryId: $expenseBigCategoryId, categoryName: $categoryName, colorCode: $colorCode, resourcePath: $resourcePath, isAllConfirmed: $isAllConfirmed, totalAmount: $totalAmount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MonthlyFixedCostCategorySummaryValueImpl &&
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

  /// Create a copy of MonthlyFixedCostCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MonthlyFixedCostCategorySummaryValueImplCopyWith<
    _$MonthlyFixedCostCategorySummaryValueImpl
  >
  get copyWith =>
      __$$MonthlyFixedCostCategorySummaryValueImplCopyWithImpl<
        _$MonthlyFixedCostCategorySummaryValueImpl
      >(this, _$identity);
}

abstract class _MonthlyFixedCostCategorySummaryValue
    implements MonthlyFixedCostCategorySummaryValue {
  const factory _MonthlyFixedCostCategorySummaryValue({
    required final int expenseBigCategoryId,
    required final String categoryName,
    required final String colorCode,
    required final String resourcePath,
    required final bool isAllConfirmed,
    required final int totalAmount,
  }) = _$MonthlyFixedCostCategorySummaryValueImpl;

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

  /// Create a copy of MonthlyFixedCostCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MonthlyFixedCostCategorySummaryValueImplCopyWith<
    _$MonthlyFixedCostCategorySummaryValueImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
