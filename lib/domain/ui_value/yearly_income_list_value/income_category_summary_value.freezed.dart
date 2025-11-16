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
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$IncomeCategorySummaryValue {
  String get categoryName => throw _privateConstructorUsedError;
  String get colorCode => throw _privateConstructorUsedError;
  String get iconPath => throw _privateConstructorUsedError;
  int get totalAmount => throw _privateConstructorUsedError;
  double get percentage => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $IncomeCategorySummaryValueCopyWith<IncomeCategorySummaryValue>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IncomeCategorySummaryValueCopyWith<$Res> {
  factory $IncomeCategorySummaryValueCopyWith(IncomeCategorySummaryValue value,
          $Res Function(IncomeCategorySummaryValue) then) =
      _$IncomeCategorySummaryValueCopyWithImpl<$Res,
          IncomeCategorySummaryValue>;
  @useResult
  $Res call(
      {String categoryName,
      String colorCode,
      String iconPath,
      int totalAmount,
      double percentage});
}

/// @nodoc
class _$IncomeCategorySummaryValueCopyWithImpl<$Res,
        $Val extends IncomeCategorySummaryValue>
    implements $IncomeCategorySummaryValueCopyWith<$Res> {
  _$IncomeCategorySummaryValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryName = null,
    Object? colorCode = null,
    Object? iconPath = null,
    Object? totalAmount = null,
    Object? percentage = null,
  }) {
    return _then(_value.copyWith(
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
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$IncomeCategorySummaryValueImplCopyWith<$Res>
    implements $IncomeCategorySummaryValueCopyWith<$Res> {
  factory _$$IncomeCategorySummaryValueImplCopyWith(
          _$IncomeCategorySummaryValueImpl value,
          $Res Function(_$IncomeCategorySummaryValueImpl) then) =
      __$$IncomeCategorySummaryValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String categoryName,
      String colorCode,
      String iconPath,
      int totalAmount,
      double percentage});
}

/// @nodoc
class __$$IncomeCategorySummaryValueImplCopyWithImpl<$Res>
    extends _$IncomeCategorySummaryValueCopyWithImpl<$Res,
        _$IncomeCategorySummaryValueImpl>
    implements _$$IncomeCategorySummaryValueImplCopyWith<$Res> {
  __$$IncomeCategorySummaryValueImplCopyWithImpl(
      _$IncomeCategorySummaryValueImpl _value,
      $Res Function(_$IncomeCategorySummaryValueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryName = null,
    Object? colorCode = null,
    Object? iconPath = null,
    Object? totalAmount = null,
    Object? percentage = null,
  }) {
    return _then(_$IncomeCategorySummaryValueImpl(
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
    ));
  }
}

/// @nodoc

class _$IncomeCategorySummaryValueImpl implements _IncomeCategorySummaryValue {
  const _$IncomeCategorySummaryValueImpl(
      {required this.categoryName,
      required this.colorCode,
      required this.iconPath,
      required this.totalAmount,
      required this.percentage});

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

  @override
  String toString() {
    return 'IncomeCategorySummaryValue(categoryName: $categoryName, colorCode: $colorCode, iconPath: $iconPath, totalAmount: $totalAmount, percentage: $percentage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$IncomeCategorySummaryValueImpl &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.colorCode, colorCode) ||
                other.colorCode == colorCode) &&
            (identical(other.iconPath, iconPath) ||
                other.iconPath == iconPath) &&
            (identical(other.totalAmount, totalAmount) ||
                other.totalAmount == totalAmount) &&
            (identical(other.percentage, percentage) ||
                other.percentage == percentage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, categoryName, colorCode, iconPath, totalAmount, percentage);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$IncomeCategorySummaryValueImplCopyWith<_$IncomeCategorySummaryValueImpl>
      get copyWith => __$$IncomeCategorySummaryValueImplCopyWithImpl<
          _$IncomeCategorySummaryValueImpl>(this, _$identity);
}

abstract class _IncomeCategorySummaryValue
    implements IncomeCategorySummaryValue {
  const factory _IncomeCategorySummaryValue(
      {required final String categoryName,
      required final String colorCode,
      required final String iconPath,
      required final int totalAmount,
      required final double percentage}) = _$IncomeCategorySummaryValueImpl;

  @override
  String get categoryName;
  @override
  String get colorCode;
  @override
  String get iconPath;
  @override
  int get totalAmount;
  @override
  double get percentage;
  @override
  @JsonKey(ignore: true)
  _$$IncomeCategorySummaryValueImplCopyWith<_$IncomeCategorySummaryValueImpl>
      get copyWith => throw _privateConstructorUsedError;
}
