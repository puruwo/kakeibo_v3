// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_transaction_group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DailyTransactionGroup {
  DateTime get date => throw _privateConstructorUsedError;

  /// 支出（固定費行も含む。固定費かどうかは fixedCostId で判定する）
  List<ExpenseHistoryTileValue> get expenses =>
      throw _privateConstructorUsedError;
  List<ExpenseHistoryTileValue> get bonusExpenses =>
      throw _privateConstructorUsedError;
  List<IncomeHistoryTileValue> get incomes =>
      throw _privateConstructorUsedError;
  List<IncomeHistoryTileValue> get bonusIncomes =>
      throw _privateConstructorUsedError;

  /// Create a copy of DailyTransactionGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyTransactionGroupCopyWith<DailyTransactionGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyTransactionGroupCopyWith<$Res> {
  factory $DailyTransactionGroupCopyWith(
    DailyTransactionGroup value,
    $Res Function(DailyTransactionGroup) then,
  ) = _$DailyTransactionGroupCopyWithImpl<$Res, DailyTransactionGroup>;
  @useResult
  $Res call({
    DateTime date,
    List<ExpenseHistoryTileValue> expenses,
    List<ExpenseHistoryTileValue> bonusExpenses,
    List<IncomeHistoryTileValue> incomes,
    List<IncomeHistoryTileValue> bonusIncomes,
  });
}

/// @nodoc
class _$DailyTransactionGroupCopyWithImpl<
  $Res,
  $Val extends DailyTransactionGroup
>
    implements $DailyTransactionGroupCopyWith<$Res> {
  _$DailyTransactionGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyTransactionGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? expenses = null,
    Object? bonusExpenses = null,
    Object? incomes = null,
    Object? bonusIncomes = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expenses: null == expenses
                ? _value.expenses
                : expenses // ignore: cast_nullable_to_non_nullable
                      as List<ExpenseHistoryTileValue>,
            bonusExpenses: null == bonusExpenses
                ? _value.bonusExpenses
                : bonusExpenses // ignore: cast_nullable_to_non_nullable
                      as List<ExpenseHistoryTileValue>,
            incomes: null == incomes
                ? _value.incomes
                : incomes // ignore: cast_nullable_to_non_nullable
                      as List<IncomeHistoryTileValue>,
            bonusIncomes: null == bonusIncomes
                ? _value.bonusIncomes
                : bonusIncomes // ignore: cast_nullable_to_non_nullable
                      as List<IncomeHistoryTileValue>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyTransactionGroupImplCopyWith<$Res>
    implements $DailyTransactionGroupCopyWith<$Res> {
  factory _$$DailyTransactionGroupImplCopyWith(
    _$DailyTransactionGroupImpl value,
    $Res Function(_$DailyTransactionGroupImpl) then,
  ) = __$$DailyTransactionGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime date,
    List<ExpenseHistoryTileValue> expenses,
    List<ExpenseHistoryTileValue> bonusExpenses,
    List<IncomeHistoryTileValue> incomes,
    List<IncomeHistoryTileValue> bonusIncomes,
  });
}

/// @nodoc
class __$$DailyTransactionGroupImplCopyWithImpl<$Res>
    extends
        _$DailyTransactionGroupCopyWithImpl<$Res, _$DailyTransactionGroupImpl>
    implements _$$DailyTransactionGroupImplCopyWith<$Res> {
  __$$DailyTransactionGroupImplCopyWithImpl(
    _$DailyTransactionGroupImpl _value,
    $Res Function(_$DailyTransactionGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyTransactionGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? expenses = null,
    Object? bonusExpenses = null,
    Object? incomes = null,
    Object? bonusIncomes = null,
  }) {
    return _then(
      _$DailyTransactionGroupImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expenses: null == expenses
            ? _value._expenses
            : expenses // ignore: cast_nullable_to_non_nullable
                  as List<ExpenseHistoryTileValue>,
        bonusExpenses: null == bonusExpenses
            ? _value._bonusExpenses
            : bonusExpenses // ignore: cast_nullable_to_non_nullable
                  as List<ExpenseHistoryTileValue>,
        incomes: null == incomes
            ? _value._incomes
            : incomes // ignore: cast_nullable_to_non_nullable
                  as List<IncomeHistoryTileValue>,
        bonusIncomes: null == bonusIncomes
            ? _value._bonusIncomes
            : bonusIncomes // ignore: cast_nullable_to_non_nullable
                  as List<IncomeHistoryTileValue>,
      ),
    );
  }
}

/// @nodoc

class _$DailyTransactionGroupImpl implements _DailyTransactionGroup {
  const _$DailyTransactionGroupImpl({
    required this.date,
    final List<ExpenseHistoryTileValue> expenses = const [],
    final List<ExpenseHistoryTileValue> bonusExpenses = const [],
    final List<IncomeHistoryTileValue> incomes = const [],
    final List<IncomeHistoryTileValue> bonusIncomes = const [],
  }) : _expenses = expenses,
       _bonusExpenses = bonusExpenses,
       _incomes = incomes,
       _bonusIncomes = bonusIncomes;

  @override
  final DateTime date;

  /// 支出（固定費行も含む。固定費かどうかは fixedCostId で判定する）
  final List<ExpenseHistoryTileValue> _expenses;

  /// 支出（固定費行も含む。固定費かどうかは fixedCostId で判定する）
  @override
  @JsonKey()
  List<ExpenseHistoryTileValue> get expenses {
    if (_expenses is EqualUnmodifiableListView) return _expenses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_expenses);
  }

  final List<ExpenseHistoryTileValue> _bonusExpenses;
  @override
  @JsonKey()
  List<ExpenseHistoryTileValue> get bonusExpenses {
    if (_bonusExpenses is EqualUnmodifiableListView) return _bonusExpenses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bonusExpenses);
  }

  final List<IncomeHistoryTileValue> _incomes;
  @override
  @JsonKey()
  List<IncomeHistoryTileValue> get incomes {
    if (_incomes is EqualUnmodifiableListView) return _incomes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_incomes);
  }

  final List<IncomeHistoryTileValue> _bonusIncomes;
  @override
  @JsonKey()
  List<IncomeHistoryTileValue> get bonusIncomes {
    if (_bonusIncomes is EqualUnmodifiableListView) return _bonusIncomes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bonusIncomes);
  }

  @override
  String toString() {
    return 'DailyTransactionGroup(date: $date, expenses: $expenses, bonusExpenses: $bonusExpenses, incomes: $incomes, bonusIncomes: $bonusIncomes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyTransactionGroupImpl &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(other._expenses, _expenses) &&
            const DeepCollectionEquality().equals(
              other._bonusExpenses,
              _bonusExpenses,
            ) &&
            const DeepCollectionEquality().equals(other._incomes, _incomes) &&
            const DeepCollectionEquality().equals(
              other._bonusIncomes,
              _bonusIncomes,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    const DeepCollectionEquality().hash(_expenses),
    const DeepCollectionEquality().hash(_bonusExpenses),
    const DeepCollectionEquality().hash(_incomes),
    const DeepCollectionEquality().hash(_bonusIncomes),
  );

  /// Create a copy of DailyTransactionGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyTransactionGroupImplCopyWith<_$DailyTransactionGroupImpl>
  get copyWith =>
      __$$DailyTransactionGroupImplCopyWithImpl<_$DailyTransactionGroupImpl>(
        this,
        _$identity,
      );
}

abstract class _DailyTransactionGroup implements DailyTransactionGroup {
  const factory _DailyTransactionGroup({
    required final DateTime date,
    final List<ExpenseHistoryTileValue> expenses,
    final List<ExpenseHistoryTileValue> bonusExpenses,
    final List<IncomeHistoryTileValue> incomes,
    final List<IncomeHistoryTileValue> bonusIncomes,
  }) = _$DailyTransactionGroupImpl;

  @override
  DateTime get date;

  /// 支出（固定費行も含む。固定費かどうかは fixedCostId で判定する）
  @override
  List<ExpenseHistoryTileValue> get expenses;
  @override
  List<ExpenseHistoryTileValue> get bonusExpenses;
  @override
  List<IncomeHistoryTileValue> get incomes;
  @override
  List<IncomeHistoryTileValue> get bonusIncomes;

  /// Create a copy of DailyTransactionGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyTransactionGroupImplCopyWith<_$DailyTransactionGroupImpl>
  get copyWith => throw _privateConstructorUsedError;
}
