// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'y_axis_scale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$YAxisScale {
  double get minValue => throw _privateConstructorUsedError; // 折れ線エリアの下限
  double get maxValue => throw _privateConstructorUsedError; // 折れ線エリアの上限
  double get interval =>
      throw _privateConstructorUsedError; // グリッド間隔（10k/20k/50k/100k...）
  List<double> get gridValues => throw _privateConstructorUsedError;

  /// Create a copy of YAxisScale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $YAxisScaleCopyWith<YAxisScale> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $YAxisScaleCopyWith<$Res> {
  factory $YAxisScaleCopyWith(
    YAxisScale value,
    $Res Function(YAxisScale) then,
  ) = _$YAxisScaleCopyWithImpl<$Res, YAxisScale>;
  @useResult
  $Res call({
    double minValue,
    double maxValue,
    double interval,
    List<double> gridValues,
  });
}

/// @nodoc
class _$YAxisScaleCopyWithImpl<$Res, $Val extends YAxisScale>
    implements $YAxisScaleCopyWith<$Res> {
  _$YAxisScaleCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of YAxisScale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minValue = null,
    Object? maxValue = null,
    Object? interval = null,
    Object? gridValues = null,
  }) {
    return _then(
      _value.copyWith(
            minValue: null == minValue
                ? _value.minValue
                : minValue // ignore: cast_nullable_to_non_nullable
                      as double,
            maxValue: null == maxValue
                ? _value.maxValue
                : maxValue // ignore: cast_nullable_to_non_nullable
                      as double,
            interval: null == interval
                ? _value.interval
                : interval // ignore: cast_nullable_to_non_nullable
                      as double,
            gridValues: null == gridValues
                ? _value.gridValues
                : gridValues // ignore: cast_nullable_to_non_nullable
                      as List<double>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$YAxisScaleImplCopyWith<$Res>
    implements $YAxisScaleCopyWith<$Res> {
  factory _$$YAxisScaleImplCopyWith(
    _$YAxisScaleImpl value,
    $Res Function(_$YAxisScaleImpl) then,
  ) = __$$YAxisScaleImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    double minValue,
    double maxValue,
    double interval,
    List<double> gridValues,
  });
}

/// @nodoc
class __$$YAxisScaleImplCopyWithImpl<$Res>
    extends _$YAxisScaleCopyWithImpl<$Res, _$YAxisScaleImpl>
    implements _$$YAxisScaleImplCopyWith<$Res> {
  __$$YAxisScaleImplCopyWithImpl(
    _$YAxisScaleImpl _value,
    $Res Function(_$YAxisScaleImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of YAxisScale
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? minValue = null,
    Object? maxValue = null,
    Object? interval = null,
    Object? gridValues = null,
  }) {
    return _then(
      _$YAxisScaleImpl(
        minValue: null == minValue
            ? _value.minValue
            : minValue // ignore: cast_nullable_to_non_nullable
                  as double,
        maxValue: null == maxValue
            ? _value.maxValue
            : maxValue // ignore: cast_nullable_to_non_nullable
                  as double,
        interval: null == interval
            ? _value.interval
            : interval // ignore: cast_nullable_to_non_nullable
                  as double,
        gridValues: null == gridValues
            ? _value._gridValues
            : gridValues // ignore: cast_nullable_to_non_nullable
                  as List<double>,
      ),
    );
  }
}

/// @nodoc

class _$YAxisScaleImpl implements _YAxisScale {
  const _$YAxisScaleImpl({
    required this.minValue,
    required this.maxValue,
    required this.interval,
    required final List<double> gridValues,
  }) : _gridValues = gridValues;

  @override
  final double minValue;
  // 折れ線エリアの下限
  @override
  final double maxValue;
  // 折れ線エリアの上限
  @override
  final double interval;
  // グリッド間隔（10k/20k/50k/100k...）
  final List<double> _gridValues;
  // グリッド間隔（10k/20k/50k/100k...）
  @override
  List<double> get gridValues {
    if (_gridValues is EqualUnmodifiableListView) return _gridValues;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gridValues);
  }

  @override
  String toString() {
    return 'YAxisScale(minValue: $minValue, maxValue: $maxValue, interval: $interval, gridValues: $gridValues)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$YAxisScaleImpl &&
            (identical(other.minValue, minValue) ||
                other.minValue == minValue) &&
            (identical(other.maxValue, maxValue) ||
                other.maxValue == maxValue) &&
            (identical(other.interval, interval) ||
                other.interval == interval) &&
            const DeepCollectionEquality().equals(
              other._gridValues,
              _gridValues,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    minValue,
    maxValue,
    interval,
    const DeepCollectionEquality().hash(_gridValues),
  );

  /// Create a copy of YAxisScale
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$YAxisScaleImplCopyWith<_$YAxisScaleImpl> get copyWith =>
      __$$YAxisScaleImplCopyWithImpl<_$YAxisScaleImpl>(this, _$identity);
}

abstract class _YAxisScale implements YAxisScale {
  const factory _YAxisScale({
    required final double minValue,
    required final double maxValue,
    required final double interval,
    required final List<double> gridValues,
  }) = _$YAxisScaleImpl;

  @override
  double get minValue; // 折れ線エリアの下限
  @override
  double get maxValue; // 折れ線エリアの上限
  @override
  double get interval; // グリッド間隔（10k/20k/50k/100k...）
  @override
  List<double> get gridValues;

  /// Create a copy of YAxisScale
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$YAxisScaleImplCopyWith<_$YAxisScaleImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
