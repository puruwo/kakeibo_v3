// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_history_tile_group_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ExpenseHistoryTileGroupValue {
  DateTime get date => throw _privateConstructorUsedError;
  List<ExpenseHistoryTileValue> get expenseHistoryTileValueList =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ExpenseHistoryTileGroupValueCopyWith<ExpenseHistoryTileGroupValue>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseHistoryTileGroupValueCopyWith<$Res> {
  factory $ExpenseHistoryTileGroupValueCopyWith(
          ExpenseHistoryTileGroupValue value,
          $Res Function(ExpenseHistoryTileGroupValue) then) =
      _$ExpenseHistoryTileGroupValueCopyWithImpl<$Res,
          ExpenseHistoryTileGroupValue>;
  @useResult
  $Res call(
      {DateTime date,
      List<ExpenseHistoryTileValue> expenseHistoryTileValueList});
}

/// @nodoc
class _$ExpenseHistoryTileGroupValueCopyWithImpl<$Res,
        $Val extends ExpenseHistoryTileGroupValue>
    implements $ExpenseHistoryTileGroupValueCopyWith<$Res> {
  _$ExpenseHistoryTileGroupValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? expenseHistoryTileValueList = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expenseHistoryTileValueList: null == expenseHistoryTileValueList
          ? _value.expenseHistoryTileValueList
          : expenseHistoryTileValueList // ignore: cast_nullable_to_non_nullable
              as List<ExpenseHistoryTileValue>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExpenseHistoryTileGroupValueImplCopyWith<$Res>
    implements $ExpenseHistoryTileGroupValueCopyWith<$Res> {
  factory _$$ExpenseHistoryTileGroupValueImplCopyWith(
          _$ExpenseHistoryTileGroupValueImpl value,
          $Res Function(_$ExpenseHistoryTileGroupValueImpl) then) =
      __$$ExpenseHistoryTileGroupValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      List<ExpenseHistoryTileValue> expenseHistoryTileValueList});
}

/// @nodoc
class __$$ExpenseHistoryTileGroupValueImplCopyWithImpl<$Res>
    extends _$ExpenseHistoryTileGroupValueCopyWithImpl<$Res,
        _$ExpenseHistoryTileGroupValueImpl>
    implements _$$ExpenseHistoryTileGroupValueImplCopyWith<$Res> {
  __$$ExpenseHistoryTileGroupValueImplCopyWithImpl(
      _$ExpenseHistoryTileGroupValueImpl _value,
      $Res Function(_$ExpenseHistoryTileGroupValueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? expenseHistoryTileValueList = null,
  }) {
    return _then(_$ExpenseHistoryTileGroupValueImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expenseHistoryTileValueList: null == expenseHistoryTileValueList
          ? _value._expenseHistoryTileValueList
          : expenseHistoryTileValueList // ignore: cast_nullable_to_non_nullable
              as List<ExpenseHistoryTileValue>,
    ));
  }
}

/// @nodoc

class _$ExpenseHistoryTileGroupValueImpl
    implements _ExpenseHistoryTileGroupValue {
  const _$ExpenseHistoryTileGroupValueImpl(
      {required this.date,
      required final List<ExpenseHistoryTileValue> expenseHistoryTileValueList})
      : _expenseHistoryTileValueList = expenseHistoryTileValueList;

  @override
  final DateTime date;
  final List<ExpenseHistoryTileValue> _expenseHistoryTileValueList;
  @override
  List<ExpenseHistoryTileValue> get expenseHistoryTileValueList {
    if (_expenseHistoryTileValueList is EqualUnmodifiableListView)
      return _expenseHistoryTileValueList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_expenseHistoryTileValueList);
  }

  @override
  String toString() {
    return 'ExpenseHistoryTileGroupValue(date: $date, expenseHistoryTileValueList: $expenseHistoryTileValueList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseHistoryTileGroupValueImpl &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(
                other._expenseHistoryTileValueList,
                _expenseHistoryTileValueList));
  }

  @override
  int get hashCode => Object.hash(runtimeType, date,
      const DeepCollectionEquality().hash(_expenseHistoryTileValueList));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseHistoryTileGroupValueImplCopyWith<
          _$ExpenseHistoryTileGroupValueImpl>
      get copyWith => __$$ExpenseHistoryTileGroupValueImplCopyWithImpl<
          _$ExpenseHistoryTileGroupValueImpl>(this, _$identity);
}

abstract class _ExpenseHistoryTileGroupValue
    implements ExpenseHistoryTileGroupValue {
  const factory _ExpenseHistoryTileGroupValue(
      {required final DateTime date,
      required final List<ExpenseHistoryTileValue>
          expenseHistoryTileValueList}) = _$ExpenseHistoryTileGroupValueImpl;

  @override
  DateTime get date;
  @override
  List<ExpenseHistoryTileValue> get expenseHistoryTileValueList;
  @override
  @JsonKey(ignore: true)
  _$$ExpenseHistoryTileGroupValueImplCopyWith<
          _$ExpenseHistoryTileGroupValueImpl>
      get copyWith => throw _privateConstructorUsedError;
}
