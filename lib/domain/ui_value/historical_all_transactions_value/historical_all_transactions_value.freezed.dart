// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'historical_all_transactions_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$HistoricalAllTransactionsValue {
  /// 通常支出（ボーナス除く）- 日付でグループ化済み
  List<ExpenseHistoryTileGroupValue> get expenses =>
      throw _privateConstructorUsedError;

  /// ボーナス支出
  List<ExpenseHistoryTileValue> get bonusExpenses =>
      throw _privateConstructorUsedError;

  /// 収入（月次収入）
  List<IncomeHistoryTileValue> get incomes =>
      throw _privateConstructorUsedError;

  /// ボーナス収入
  List<IncomeHistoryTileValue> get bonusIncomes =>
      throw _privateConstructorUsedError;

  /// 固定費（確定）
  List<MonthlyConfirmedFixedCostTileValue> get confirmedFixedCosts =>
      throw _privateConstructorUsedError;

  /// 固定費（未確定）
  List<MonthlyUnconfirmedFixedCostTileValue> get unconfirmedFixedCosts =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $HistoricalAllTransactionsValueCopyWith<HistoricalAllTransactionsValue>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HistoricalAllTransactionsValueCopyWith<$Res> {
  factory $HistoricalAllTransactionsValueCopyWith(
          HistoricalAllTransactionsValue value,
          $Res Function(HistoricalAllTransactionsValue) then) =
      _$HistoricalAllTransactionsValueCopyWithImpl<$Res,
          HistoricalAllTransactionsValue>;
  @useResult
  $Res call(
      {List<ExpenseHistoryTileGroupValue> expenses,
      List<ExpenseHistoryTileValue> bonusExpenses,
      List<IncomeHistoryTileValue> incomes,
      List<IncomeHistoryTileValue> bonusIncomes,
      List<MonthlyConfirmedFixedCostTileValue> confirmedFixedCosts,
      List<MonthlyUnconfirmedFixedCostTileValue> unconfirmedFixedCosts});
}

/// @nodoc
class _$HistoricalAllTransactionsValueCopyWithImpl<$Res,
        $Val extends HistoricalAllTransactionsValue>
    implements $HistoricalAllTransactionsValueCopyWith<$Res> {
  _$HistoricalAllTransactionsValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expenses = null,
    Object? bonusExpenses = null,
    Object? incomes = null,
    Object? bonusIncomes = null,
    Object? confirmedFixedCosts = null,
    Object? unconfirmedFixedCosts = null,
  }) {
    return _then(_value.copyWith(
      expenses: null == expenses
          ? _value.expenses
          : expenses // ignore: cast_nullable_to_non_nullable
              as List<ExpenseHistoryTileGroupValue>,
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
      confirmedFixedCosts: null == confirmedFixedCosts
          ? _value.confirmedFixedCosts
          : confirmedFixedCosts // ignore: cast_nullable_to_non_nullable
              as List<MonthlyConfirmedFixedCostTileValue>,
      unconfirmedFixedCosts: null == unconfirmedFixedCosts
          ? _value.unconfirmedFixedCosts
          : unconfirmedFixedCosts // ignore: cast_nullable_to_non_nullable
              as List<MonthlyUnconfirmedFixedCostTileValue>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$HistoricalAllTransactionsValueImplCopyWith<$Res>
    implements $HistoricalAllTransactionsValueCopyWith<$Res> {
  factory _$$HistoricalAllTransactionsValueImplCopyWith(
          _$HistoricalAllTransactionsValueImpl value,
          $Res Function(_$HistoricalAllTransactionsValueImpl) then) =
      __$$HistoricalAllTransactionsValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ExpenseHistoryTileGroupValue> expenses,
      List<ExpenseHistoryTileValue> bonusExpenses,
      List<IncomeHistoryTileValue> incomes,
      List<IncomeHistoryTileValue> bonusIncomes,
      List<MonthlyConfirmedFixedCostTileValue> confirmedFixedCosts,
      List<MonthlyUnconfirmedFixedCostTileValue> unconfirmedFixedCosts});
}

/// @nodoc
class __$$HistoricalAllTransactionsValueImplCopyWithImpl<$Res>
    extends _$HistoricalAllTransactionsValueCopyWithImpl<$Res,
        _$HistoricalAllTransactionsValueImpl>
    implements _$$HistoricalAllTransactionsValueImplCopyWith<$Res> {
  __$$HistoricalAllTransactionsValueImplCopyWithImpl(
      _$HistoricalAllTransactionsValueImpl _value,
      $Res Function(_$HistoricalAllTransactionsValueImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expenses = null,
    Object? bonusExpenses = null,
    Object? incomes = null,
    Object? bonusIncomes = null,
    Object? confirmedFixedCosts = null,
    Object? unconfirmedFixedCosts = null,
  }) {
    return _then(_$HistoricalAllTransactionsValueImpl(
      expenses: null == expenses
          ? _value._expenses
          : expenses // ignore: cast_nullable_to_non_nullable
              as List<ExpenseHistoryTileGroupValue>,
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
      confirmedFixedCosts: null == confirmedFixedCosts
          ? _value._confirmedFixedCosts
          : confirmedFixedCosts // ignore: cast_nullable_to_non_nullable
              as List<MonthlyConfirmedFixedCostTileValue>,
      unconfirmedFixedCosts: null == unconfirmedFixedCosts
          ? _value._unconfirmedFixedCosts
          : unconfirmedFixedCosts // ignore: cast_nullable_to_non_nullable
              as List<MonthlyUnconfirmedFixedCostTileValue>,
    ));
  }
}

/// @nodoc

class _$HistoricalAllTransactionsValueImpl
    implements _HistoricalAllTransactionsValue {
  const _$HistoricalAllTransactionsValueImpl(
      {required final List<ExpenseHistoryTileGroupValue> expenses,
      required final List<ExpenseHistoryTileValue> bonusExpenses,
      required final List<IncomeHistoryTileValue> incomes,
      required final List<IncomeHistoryTileValue> bonusIncomes,
      required final List<MonthlyConfirmedFixedCostTileValue>
          confirmedFixedCosts,
      required final List<MonthlyUnconfirmedFixedCostTileValue>
          unconfirmedFixedCosts})
      : _expenses = expenses,
        _bonusExpenses = bonusExpenses,
        _incomes = incomes,
        _bonusIncomes = bonusIncomes,
        _confirmedFixedCosts = confirmedFixedCosts,
        _unconfirmedFixedCosts = unconfirmedFixedCosts;

  /// 通常支出（ボーナス除く）- 日付でグループ化済み
  final List<ExpenseHistoryTileGroupValue> _expenses;

  /// 通常支出（ボーナス除く）- 日付でグループ化済み
  @override
  List<ExpenseHistoryTileGroupValue> get expenses {
    if (_expenses is EqualUnmodifiableListView) return _expenses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_expenses);
  }

  /// ボーナス支出
  final List<ExpenseHistoryTileValue> _bonusExpenses;

  /// ボーナス支出
  @override
  List<ExpenseHistoryTileValue> get bonusExpenses {
    if (_bonusExpenses is EqualUnmodifiableListView) return _bonusExpenses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bonusExpenses);
  }

  /// 収入（月次収入）
  final List<IncomeHistoryTileValue> _incomes;

  /// 収入（月次収入）
  @override
  List<IncomeHistoryTileValue> get incomes {
    if (_incomes is EqualUnmodifiableListView) return _incomes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_incomes);
  }

  /// ボーナス収入
  final List<IncomeHistoryTileValue> _bonusIncomes;

  /// ボーナス収入
  @override
  List<IncomeHistoryTileValue> get bonusIncomes {
    if (_bonusIncomes is EqualUnmodifiableListView) return _bonusIncomes;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_bonusIncomes);
  }

  /// 固定費（確定）
  final List<MonthlyConfirmedFixedCostTileValue> _confirmedFixedCosts;

  /// 固定費（確定）
  @override
  List<MonthlyConfirmedFixedCostTileValue> get confirmedFixedCosts {
    if (_confirmedFixedCosts is EqualUnmodifiableListView)
      return _confirmedFixedCosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_confirmedFixedCosts);
  }

  /// 固定費（未確定）
  final List<MonthlyUnconfirmedFixedCostTileValue> _unconfirmedFixedCosts;

  /// 固定費（未確定）
  @override
  List<MonthlyUnconfirmedFixedCostTileValue> get unconfirmedFixedCosts {
    if (_unconfirmedFixedCosts is EqualUnmodifiableListView)
      return _unconfirmedFixedCosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_unconfirmedFixedCosts);
  }

  @override
  String toString() {
    return 'HistoricalAllTransactionsValue(expenses: $expenses, bonusExpenses: $bonusExpenses, incomes: $incomes, bonusIncomes: $bonusIncomes, confirmedFixedCosts: $confirmedFixedCosts, unconfirmedFixedCosts: $unconfirmedFixedCosts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HistoricalAllTransactionsValueImpl &&
            const DeepCollectionEquality().equals(other._expenses, _expenses) &&
            const DeepCollectionEquality()
                .equals(other._bonusExpenses, _bonusExpenses) &&
            const DeepCollectionEquality().equals(other._incomes, _incomes) &&
            const DeepCollectionEquality()
                .equals(other._bonusIncomes, _bonusIncomes) &&
            const DeepCollectionEquality()
                .equals(other._confirmedFixedCosts, _confirmedFixedCosts) &&
            const DeepCollectionEquality()
                .equals(other._unconfirmedFixedCosts, _unconfirmedFixedCosts));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_expenses),
      const DeepCollectionEquality().hash(_bonusExpenses),
      const DeepCollectionEquality().hash(_incomes),
      const DeepCollectionEquality().hash(_bonusIncomes),
      const DeepCollectionEquality().hash(_confirmedFixedCosts),
      const DeepCollectionEquality().hash(_unconfirmedFixedCosts));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$HistoricalAllTransactionsValueImplCopyWith<
          _$HistoricalAllTransactionsValueImpl>
      get copyWith => __$$HistoricalAllTransactionsValueImplCopyWithImpl<
          _$HistoricalAllTransactionsValueImpl>(this, _$identity);
}

abstract class _HistoricalAllTransactionsValue
    implements HistoricalAllTransactionsValue {
  const factory _HistoricalAllTransactionsValue(
      {required final List<ExpenseHistoryTileGroupValue> expenses,
      required final List<ExpenseHistoryTileValue> bonusExpenses,
      required final List<IncomeHistoryTileValue> incomes,
      required final List<IncomeHistoryTileValue> bonusIncomes,
      required final List<MonthlyConfirmedFixedCostTileValue>
          confirmedFixedCosts,
      required final List<MonthlyUnconfirmedFixedCostTileValue>
          unconfirmedFixedCosts}) = _$HistoricalAllTransactionsValueImpl;

  @override

  /// 通常支出（ボーナス除く）- 日付でグループ化済み
  List<ExpenseHistoryTileGroupValue> get expenses;
  @override

  /// ボーナス支出
  List<ExpenseHistoryTileValue> get bonusExpenses;
  @override

  /// 収入（月次収入）
  List<IncomeHistoryTileValue> get incomes;
  @override

  /// ボーナス収入
  List<IncomeHistoryTileValue> get bonusIncomes;
  @override

  /// 固定費（確定）
  List<MonthlyConfirmedFixedCostTileValue> get confirmedFixedCosts;
  @override

  /// 固定費（未確定）
  List<MonthlyUnconfirmedFixedCostTileValue> get unconfirmedFixedCosts;
  @override
  @JsonKey(ignore: true)
  _$$HistoricalAllTransactionsValueImplCopyWith<
          _$HistoricalAllTransactionsValueImpl>
      get copyWith => throw _privateConstructorUsedError;
}
