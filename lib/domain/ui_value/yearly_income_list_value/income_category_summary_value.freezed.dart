// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'income_category_summary_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$IncomeCategorySummaryValue {
  int get bigCategoryId => throw _privateConstructorUsedError; // 大カテゴリー名
  String get categoryName => throw _privateConstructorUsedError;
  String get colorCode => throw _privateConstructorUsedError;
  String get iconPath => throw _privateConstructorUsedError;
  int get totalAmount => throw _privateConstructorUsedError;
  double get percentage =>
      throw _privateConstructorUsedError; // この大カテゴリーに属する小カテゴリー別の内訳（金額降順）
  List<IncomeSmallCategorySummaryValue> get smallCategories =>
      throw _privateConstructorUsedError;

  /// Create a copy of IncomeCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IncomeCategorySummaryValueCopyWith<IncomeCategorySummaryValue>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IncomeCategorySummaryValueCopyWith<$Res> {
  factory $IncomeCategorySummaryValueCopyWith(
    IncomeCategorySummaryValue value,
    $Res Function(IncomeCategorySummaryValue) then,
  ) =
      _$IncomeCategorySummaryValueCopyWithImpl<
        $Res,
        IncomeCategorySummaryValue
      >;
  @useResult
  $Res call({
    int bigCategoryId,
    String categoryName,
    String colorCode,
    String iconPath,
    int totalAmount,
    double percentage,
    List<IncomeSmallCategorySummaryValue> smallCategories,
  });
}

/// @nodoc
class _$IncomeCategorySummaryValueCopyWithImpl<
  $Res,
  $Val extends IncomeCategorySummaryValue
>
    implements $IncomeCategorySummaryValueCopyWith<$Res> {
  _$IncomeCategorySummaryValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IncomeCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bigCategoryId = null,
    Object? categoryName = null,
    Object? colorCode = null,
    Object? iconPath = null,
    Object? totalAmount = null,
    Object? percentage = null,
    Object? smallCategories = null,
  }) {
    return _then(
      _value.copyWith(
            bigCategoryId: null == bigCategoryId
                ? _value.bigCategoryId
                : bigCategoryId // ignore: cast_nullable_to_non_nullable
                      as int,
            categoryName: null == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            colorCode: null == colorCode
                ? _value.colorCode
                : colorCode // ignore: cast_nullable_to_non_nullable
                      as String,
            iconPath: null == iconPath
                ? _value.iconPath
                : iconPath // ignore: cast_nullable_to_non_nullable
                      as String,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            percentage: null == percentage
                ? _value.percentage
                : percentage // ignore: cast_nullable_to_non_nullable
                      as double,
            smallCategories: null == smallCategories
                ? _value.smallCategories
                : smallCategories // ignore: cast_nullable_to_non_nullable
                      as List<IncomeSmallCategorySummaryValue>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IncomeCategorySummaryValueImplCopyWith<$Res>
    implements $IncomeCategorySummaryValueCopyWith<$Res> {
  factory _$$IncomeCategorySummaryValueImplCopyWith(
    _$IncomeCategorySummaryValueImpl value,
    $Res Function(_$IncomeCategorySummaryValueImpl) then,
  ) = __$$IncomeCategorySummaryValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int bigCategoryId,
    String categoryName,
    String colorCode,
    String iconPath,
    int totalAmount,
    double percentage,
    List<IncomeSmallCategorySummaryValue> smallCategories,
  });
}

/// @nodoc
class __$$IncomeCategorySummaryValueImplCopyWithImpl<$Res>
    extends
        _$IncomeCategorySummaryValueCopyWithImpl<
          $Res,
          _$IncomeCategorySummaryValueImpl
        >
    implements _$$IncomeCategorySummaryValueImplCopyWith<$Res> {
  __$$IncomeCategorySummaryValueImplCopyWithImpl(
    _$IncomeCategorySummaryValueImpl _value,
    $Res Function(_$IncomeCategorySummaryValueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IncomeCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bigCategoryId = null,
    Object? categoryName = null,
    Object? colorCode = null,
    Object? iconPath = null,
    Object? totalAmount = null,
    Object? percentage = null,
    Object? smallCategories = null,
  }) {
    return _then(
      _$IncomeCategorySummaryValueImpl(
        bigCategoryId: null == bigCategoryId
            ? _value.bigCategoryId
            : bigCategoryId // ignore: cast_nullable_to_non_nullable
                  as int,
        categoryName: null == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        colorCode: null == colorCode
            ? _value.colorCode
            : colorCode // ignore: cast_nullable_to_non_nullable
                  as String,
        iconPath: null == iconPath
            ? _value.iconPath
            : iconPath // ignore: cast_nullable_to_non_nullable
                  as String,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        percentage: null == percentage
            ? _value.percentage
            : percentage // ignore: cast_nullable_to_non_nullable
                  as double,
        smallCategories: null == smallCategories
            ? _value._smallCategories
            : smallCategories // ignore: cast_nullable_to_non_nullable
                  as List<IncomeSmallCategorySummaryValue>,
      ),
    );
  }
}

/// @nodoc

class _$IncomeCategorySummaryValueImpl implements _IncomeCategorySummaryValue {
  const _$IncomeCategorySummaryValueImpl({
    required this.bigCategoryId,
    required this.categoryName,
    required this.colorCode,
    required this.iconPath,
    required this.totalAmount,
    required this.percentage,
    final List<IncomeSmallCategorySummaryValue> smallCategories = const [],
  }) : _smallCategories = smallCategories;

  @override
  final int bigCategoryId;
  // 大カテゴリー名
  @override
  final String categoryName;
  @override
  final String colorCode;
  @override
  final String iconPath;
  @override
  final int totalAmount;
  @override
  final double percentage;
  // この大カテゴリーに属する小カテゴリー別の内訳（金額降順）
  final List<IncomeSmallCategorySummaryValue> _smallCategories;
  // この大カテゴリーに属する小カテゴリー別の内訳（金額降順）
  @override
  @JsonKey()
  List<IncomeSmallCategorySummaryValue> get smallCategories {
    if (_smallCategories is EqualUnmodifiableListView) return _smallCategories;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_smallCategories);
  }

  @override
  String toString() {
    return 'IncomeCategorySummaryValue(bigCategoryId: $bigCategoryId, categoryName: $categoryName, colorCode: $colorCode, iconPath: $iconPath, totalAmount: $totalAmount, percentage: $percentage, smallCategories: $smallCategories)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IncomeCategorySummaryValueImpl &&
            (identical(other.bigCategoryId, bigCategoryId) ||
                other.bigCategoryId == bigCategoryId) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.colorCode, colorCode) ||
                other.colorCode == colorCode) &&
            (identical(other.iconPath, iconPath) ||
                other.iconPath == iconPath) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage) &&
            const DeepCollectionEquality().equals(
              other._smallCategories,
              _smallCategories,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    bigCategoryId,
    categoryName,
    colorCode,
    iconPath,
    totalAmount,
    percentage,
    const DeepCollectionEquality().hash(_smallCategories),
  );

  /// Create a copy of IncomeCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IncomeCategorySummaryValueImplCopyWith<_$IncomeCategorySummaryValueImpl>
  get copyWith =>
      __$$IncomeCategorySummaryValueImplCopyWithImpl<
        _$IncomeCategorySummaryValueImpl
      >(this, _$identity);
}

abstract class _IncomeCategorySummaryValue
    implements IncomeCategorySummaryValue {
  const factory _IncomeCategorySummaryValue({
    required final int bigCategoryId,
    required final String categoryName,
    required final String colorCode,
    required final String iconPath,
    required final int totalAmount,
    required final double percentage,
    final List<IncomeSmallCategorySummaryValue> smallCategories,
  }) = _$IncomeCategorySummaryValueImpl;

  @override
  int get bigCategoryId; // 大カテゴリー名
  @override
  String get categoryName;
  @override
  String get colorCode;
  @override
  String get iconPath;
  @override
  int get totalAmount;
  @override
  double get percentage; // この大カテゴリーに属する小カテゴリー別の内訳（金額降順）
  @override
  List<IncomeSmallCategorySummaryValue> get smallCategories;

  /// Create a copy of IncomeCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IncomeCategorySummaryValueImplCopyWith<_$IncomeCategorySummaryValueImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$IncomeSmallCategorySummaryValue {
  String get smallCategoryName => throw _privateConstructorUsedError;
  int get totalAmount =>
      throw _privateConstructorUsedError; // 大カテゴリー合計に対する割合（0〜100）
  double get percentage => throw _privateConstructorUsedError;

  /// Create a copy of IncomeSmallCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $IncomeSmallCategorySummaryValueCopyWith<IncomeSmallCategorySummaryValue>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IncomeSmallCategorySummaryValueCopyWith<$Res> {
  factory $IncomeSmallCategorySummaryValueCopyWith(
    IncomeSmallCategorySummaryValue value,
    $Res Function(IncomeSmallCategorySummaryValue) then,
  ) =
      _$IncomeSmallCategorySummaryValueCopyWithImpl<
        $Res,
        IncomeSmallCategorySummaryValue
      >;
  @useResult
  $Res call({String smallCategoryName, int totalAmount, double percentage});
}

/// @nodoc
class _$IncomeSmallCategorySummaryValueCopyWithImpl<
  $Res,
  $Val extends IncomeSmallCategorySummaryValue
>
    implements $IncomeSmallCategorySummaryValueCopyWith<$Res> {
  _$IncomeSmallCategorySummaryValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of IncomeSmallCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? smallCategoryName = null,
    Object? totalAmount = null,
    Object? percentage = null,
  }) {
    return _then(
      _value.copyWith(
            smallCategoryName: null == smallCategoryName
                ? _value.smallCategoryName
                : smallCategoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            totalAmount: null == totalAmount
                ? _value.totalAmount
                : totalAmount // ignore: cast_nullable_to_non_nullable
                      as int,
            percentage: null == percentage
                ? _value.percentage
                : percentage // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$IncomeSmallCategorySummaryValueImplCopyWith<$Res>
    implements $IncomeSmallCategorySummaryValueCopyWith<$Res> {
  factory _$$IncomeSmallCategorySummaryValueImplCopyWith(
    _$IncomeSmallCategorySummaryValueImpl value,
    $Res Function(_$IncomeSmallCategorySummaryValueImpl) then,
  ) = __$$IncomeSmallCategorySummaryValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String smallCategoryName, int totalAmount, double percentage});
}

/// @nodoc
class __$$IncomeSmallCategorySummaryValueImplCopyWithImpl<$Res>
    extends
        _$IncomeSmallCategorySummaryValueCopyWithImpl<
          $Res,
          _$IncomeSmallCategorySummaryValueImpl
        >
    implements _$$IncomeSmallCategorySummaryValueImplCopyWith<$Res> {
  __$$IncomeSmallCategorySummaryValueImplCopyWithImpl(
    _$IncomeSmallCategorySummaryValueImpl _value,
    $Res Function(_$IncomeSmallCategorySummaryValueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of IncomeSmallCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? smallCategoryName = null,
    Object? totalAmount = null,
    Object? percentage = null,
  }) {
    return _then(
      _$IncomeSmallCategorySummaryValueImpl(
        smallCategoryName: null == smallCategoryName
            ? _value.smallCategoryName
            : smallCategoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        totalAmount: null == totalAmount
            ? _value.totalAmount
            : totalAmount // ignore: cast_nullable_to_non_nullable
                  as int,
        percentage: null == percentage
            ? _value.percentage
            : percentage // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc

class _$IncomeSmallCategorySummaryValueImpl
    implements _IncomeSmallCategorySummaryValue {
  const _$IncomeSmallCategorySummaryValueImpl({
    required this.smallCategoryName,
    required this.totalAmount,
    required this.percentage,
  });

  @override
  final String smallCategoryName;
  @override
  final int totalAmount;
  // 大カテゴリー合計に対する割合（0〜100）
  @override
  final double percentage;

  @override
  String toString() {
    return 'IncomeSmallCategorySummaryValue(smallCategoryName: $smallCategoryName, totalAmount: $totalAmount, percentage: $percentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IncomeSmallCategorySummaryValueImpl &&
            (identical(other.smallCategoryName, smallCategoryName) ||
                other.smallCategoryName == smallCategoryName) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, smallCategoryName, totalAmount, percentage);

  /// Create a copy of IncomeSmallCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$IncomeSmallCategorySummaryValueImplCopyWith<
    _$IncomeSmallCategorySummaryValueImpl
  >
  get copyWith =>
      __$$IncomeSmallCategorySummaryValueImplCopyWithImpl<
        _$IncomeSmallCategorySummaryValueImpl
      >(this, _$identity);
}

abstract class _IncomeSmallCategorySummaryValue
    implements IncomeSmallCategorySummaryValue {
  const factory _IncomeSmallCategorySummaryValue({
    required final String smallCategoryName,
    required final int totalAmount,
    required final double percentage,
  }) = _$IncomeSmallCategorySummaryValueImpl;

  @override
  String get smallCategoryName;
  @override
  int get totalAmount; // 大カテゴリー合計に対する割合（0〜100）
  @override
  double get percentage;

  /// Create a copy of IncomeSmallCategorySummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$IncomeSmallCategorySummaryValueImplCopyWith<
    _$IncomeSmallCategorySummaryValueImpl
  >
  get copyWith => throw _privateConstructorUsedError;
}
