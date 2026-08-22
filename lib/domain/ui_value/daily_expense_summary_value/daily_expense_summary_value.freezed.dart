// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_expense_summary_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$DailyExpenseSummaryValue {
  /// 対象日
  DateTime get date => throw _privateConstructorUsedError;

  /// カテゴリー別にグループ化された支出（固定費行も含む）
  List<ExpenseCategoryGroup> get expensesByCategory =>
      throw _privateConstructorUsedError;

  /// 変動費（固定費以外の支出）合計
  int get variableExpenseTotal => throw _privateConstructorUsedError;

  /// 固定費合計（未確定は予想額で計上）
  int get fixedCostTotal => throw _privateConstructorUsedError;

  /// 固定費のうち未確定分の合計
  int get unconfirmedFixedCostTotal => throw _privateConstructorUsedError;

  /// 総支出
  int get totalExpense => throw _privateConstructorUsedError;

  /// データがない場合true
  bool get hasNoData => throw _privateConstructorUsedError;

  /// グラフ用カテゴリーサマリー
  List<CategorySummary> get categorySummaries =>
      throw _privateConstructorUsedError;

  /// Create a copy of DailyExpenseSummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DailyExpenseSummaryValueCopyWith<DailyExpenseSummaryValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyExpenseSummaryValueCopyWith<$Res> {
  factory $DailyExpenseSummaryValueCopyWith(
    DailyExpenseSummaryValue value,
    $Res Function(DailyExpenseSummaryValue) then,
  ) = _$DailyExpenseSummaryValueCopyWithImpl<$Res, DailyExpenseSummaryValue>;
  @useResult
  $Res call({
    DateTime date,
    List<ExpenseCategoryGroup> expensesByCategory,
    int variableExpenseTotal,
    int fixedCostTotal,
    int unconfirmedFixedCostTotal,
    int totalExpense,
    bool hasNoData,
    List<CategorySummary> categorySummaries,
  });
}

/// @nodoc
class _$DailyExpenseSummaryValueCopyWithImpl<
  $Res,
  $Val extends DailyExpenseSummaryValue
>
    implements $DailyExpenseSummaryValueCopyWith<$Res> {
  _$DailyExpenseSummaryValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DailyExpenseSummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? expensesByCategory = null,
    Object? variableExpenseTotal = null,
    Object? fixedCostTotal = null,
    Object? unconfirmedFixedCostTotal = null,
    Object? totalExpense = null,
    Object? hasNoData = null,
    Object? categorySummaries = null,
  }) {
    return _then(
      _value.copyWith(
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            expensesByCategory: null == expensesByCategory
                ? _value.expensesByCategory
                : expensesByCategory // ignore: cast_nullable_to_non_nullable
                      as List<ExpenseCategoryGroup>,
            variableExpenseTotal: null == variableExpenseTotal
                ? _value.variableExpenseTotal
                : variableExpenseTotal // ignore: cast_nullable_to_non_nullable
                      as int,
            fixedCostTotal: null == fixedCostTotal
                ? _value.fixedCostTotal
                : fixedCostTotal // ignore: cast_nullable_to_non_nullable
                      as int,
            unconfirmedFixedCostTotal: null == unconfirmedFixedCostTotal
                ? _value.unconfirmedFixedCostTotal
                : unconfirmedFixedCostTotal // ignore: cast_nullable_to_non_nullable
                      as int,
            totalExpense: null == totalExpense
                ? _value.totalExpense
                : totalExpense // ignore: cast_nullable_to_non_nullable
                      as int,
            hasNoData: null == hasNoData
                ? _value.hasNoData
                : hasNoData // ignore: cast_nullable_to_non_nullable
                      as bool,
            categorySummaries: null == categorySummaries
                ? _value.categorySummaries
                : categorySummaries // ignore: cast_nullable_to_non_nullable
                      as List<CategorySummary>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DailyExpenseSummaryValueImplCopyWith<$Res>
    implements $DailyExpenseSummaryValueCopyWith<$Res> {
  factory _$$DailyExpenseSummaryValueImplCopyWith(
    _$DailyExpenseSummaryValueImpl value,
    $Res Function(_$DailyExpenseSummaryValueImpl) then,
  ) = __$$DailyExpenseSummaryValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    DateTime date,
    List<ExpenseCategoryGroup> expensesByCategory,
    int variableExpenseTotal,
    int fixedCostTotal,
    int unconfirmedFixedCostTotal,
    int totalExpense,
    bool hasNoData,
    List<CategorySummary> categorySummaries,
  });
}

/// @nodoc
class __$$DailyExpenseSummaryValueImplCopyWithImpl<$Res>
    extends
        _$DailyExpenseSummaryValueCopyWithImpl<
          $Res,
          _$DailyExpenseSummaryValueImpl
        >
    implements _$$DailyExpenseSummaryValueImplCopyWith<$Res> {
  __$$DailyExpenseSummaryValueImplCopyWithImpl(
    _$DailyExpenseSummaryValueImpl _value,
    $Res Function(_$DailyExpenseSummaryValueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DailyExpenseSummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? expensesByCategory = null,
    Object? variableExpenseTotal = null,
    Object? fixedCostTotal = null,
    Object? unconfirmedFixedCostTotal = null,
    Object? totalExpense = null,
    Object? hasNoData = null,
    Object? categorySummaries = null,
  }) {
    return _then(
      _$DailyExpenseSummaryValueImpl(
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        expensesByCategory: null == expensesByCategory
            ? _value._expensesByCategory
            : expensesByCategory // ignore: cast_nullable_to_non_nullable
                  as List<ExpenseCategoryGroup>,
        variableExpenseTotal: null == variableExpenseTotal
            ? _value.variableExpenseTotal
            : variableExpenseTotal // ignore: cast_nullable_to_non_nullable
                  as int,
        fixedCostTotal: null == fixedCostTotal
            ? _value.fixedCostTotal
            : fixedCostTotal // ignore: cast_nullable_to_non_nullable
                  as int,
        unconfirmedFixedCostTotal: null == unconfirmedFixedCostTotal
            ? _value.unconfirmedFixedCostTotal
            : unconfirmedFixedCostTotal // ignore: cast_nullable_to_non_nullable
                  as int,
        totalExpense: null == totalExpense
            ? _value.totalExpense
            : totalExpense // ignore: cast_nullable_to_non_nullable
                  as int,
        hasNoData: null == hasNoData
            ? _value.hasNoData
            : hasNoData // ignore: cast_nullable_to_non_nullable
                  as bool,
        categorySummaries: null == categorySummaries
            ? _value._categorySummaries
            : categorySummaries // ignore: cast_nullable_to_non_nullable
                  as List<CategorySummary>,
      ),
    );
  }
}

/// @nodoc

class _$DailyExpenseSummaryValueImpl implements _DailyExpenseSummaryValue {
  _$DailyExpenseSummaryValueImpl({
    required this.date,
    required final List<ExpenseCategoryGroup> expensesByCategory,
    required this.variableExpenseTotal,
    required this.fixedCostTotal,
    required this.unconfirmedFixedCostTotal,
    required this.totalExpense,
    required this.hasNoData,
    required final List<CategorySummary> categorySummaries,
  }) : _expensesByCategory = expensesByCategory,
       _categorySummaries = categorySummaries;

  /// 対象日
  @override
  final DateTime date;

  /// カテゴリー別にグループ化された支出（固定費行も含む）
  final List<ExpenseCategoryGroup> _expensesByCategory;

  /// カテゴリー別にグループ化された支出（固定費行も含む）
  @override
  List<ExpenseCategoryGroup> get expensesByCategory {
    if (_expensesByCategory is EqualUnmodifiableListView)
      return _expensesByCategory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_expensesByCategory);
  }

  /// 変動費（固定費以外の支出）合計
  @override
  final int variableExpenseTotal;

  /// 固定費合計（未確定は予想額で計上）
  @override
  final int fixedCostTotal;

  /// 固定費のうち未確定分の合計
  @override
  final int unconfirmedFixedCostTotal;

  /// 総支出
  @override
  final int totalExpense;

  /// データがない場合true
  @override
  final bool hasNoData;

  /// グラフ用カテゴリーサマリー
  final List<CategorySummary> _categorySummaries;

  /// グラフ用カテゴリーサマリー
  @override
  List<CategorySummary> get categorySummaries {
    if (_categorySummaries is EqualUnmodifiableListView)
      return _categorySummaries;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categorySummaries);
  }

  @override
  String toString() {
    return 'DailyExpenseSummaryValue(date: $date, expensesByCategory: $expensesByCategory, variableExpenseTotal: $variableExpenseTotal, fixedCostTotal: $fixedCostTotal, unconfirmedFixedCostTotal: $unconfirmedFixedCostTotal, totalExpense: $totalExpense, hasNoData: $hasNoData, categorySummaries: $categorySummaries)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyExpenseSummaryValueImpl &&
            (identical(other.date, date) || other.date == date) &&
            const DeepCollectionEquality().equals(
              other._expensesByCategory,
              _expensesByCategory,
            ) &&
            (identical(other.variableExpenseTotal, variableExpenseTotal) ||
                other.variableExpenseTotal == variableExpenseTotal) &&
            (identical(other.fixedCostTotal, fixedCostTotal) ||
                other.fixedCostTotal == fixedCostTotal) &&
            (identical(
                  other.unconfirmedFixedCostTotal,
                  unconfirmedFixedCostTotal,
                ) ||
                other.unconfirmedFixedCostTotal == unconfirmedFixedCostTotal) &&
            (identical(other.totalExpense, totalExpense) ||
                other.totalExpense == totalExpense) &&
            (identical(other.hasNoData, hasNoData) ||
                other.hasNoData == hasNoData) &&
            const DeepCollectionEquality().equals(
              other._categorySummaries,
              _categorySummaries,
            ));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    date,
    const DeepCollectionEquality().hash(_expensesByCategory),
    variableExpenseTotal,
    fixedCostTotal,
    unconfirmedFixedCostTotal,
    totalExpense,
    hasNoData,
    const DeepCollectionEquality().hash(_categorySummaries),
  );

  /// Create a copy of DailyExpenseSummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyExpenseSummaryValueImplCopyWith<_$DailyExpenseSummaryValueImpl>
  get copyWith =>
      __$$DailyExpenseSummaryValueImplCopyWithImpl<
        _$DailyExpenseSummaryValueImpl
      >(this, _$identity);
}

abstract class _DailyExpenseSummaryValue implements DailyExpenseSummaryValue {
  factory _DailyExpenseSummaryValue({
    required final DateTime date,
    required final List<ExpenseCategoryGroup> expensesByCategory,
    required final int variableExpenseTotal,
    required final int fixedCostTotal,
    required final int unconfirmedFixedCostTotal,
    required final int totalExpense,
    required final bool hasNoData,
    required final List<CategorySummary> categorySummaries,
  }) = _$DailyExpenseSummaryValueImpl;

  /// 対象日
  @override
  DateTime get date;

  /// カテゴリー別にグループ化された支出（固定費行も含む）
  @override
  List<ExpenseCategoryGroup> get expensesByCategory;

  /// 変動費（固定費以外の支出）合計
  @override
  int get variableExpenseTotal;

  /// 固定費合計（未確定は予想額で計上）
  @override
  int get fixedCostTotal;

  /// 固定費のうち未確定分の合計
  @override
  int get unconfirmedFixedCostTotal;

  /// 総支出
  @override
  int get totalExpense;

  /// データがない場合true
  @override
  bool get hasNoData;

  /// グラフ用カテゴリーサマリー
  @override
  List<CategorySummary> get categorySummaries;

  /// Create a copy of DailyExpenseSummaryValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DailyExpenseSummaryValueImplCopyWith<_$DailyExpenseSummaryValueImpl>
  get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ExpenseCategoryGroup {
  /// カテゴリー名（大カテゴリー）
  String get categoryName => throw _privateConstructorUsedError;

  /// カテゴリーアイコンパス
  String get iconPath => throw _privateConstructorUsedError;

  /// カテゴリー色コード
  String get colorCode => throw _privateConstructorUsedError;

  /// このカテゴリーに属する支出リスト（固定費行も含む）
  List<ExpenseHistoryTileValue> get expenses =>
      throw _privateConstructorUsedError;

  /// カテゴリー内の支出合計
  int get categoryTotal => throw _privateConstructorUsedError;

  /// Create a copy of ExpenseCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseCategoryGroupCopyWith<ExpenseCategoryGroup> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseCategoryGroupCopyWith<$Res> {
  factory $ExpenseCategoryGroupCopyWith(
    ExpenseCategoryGroup value,
    $Res Function(ExpenseCategoryGroup) then,
  ) = _$ExpenseCategoryGroupCopyWithImpl<$Res, ExpenseCategoryGroup>;
  @useResult
  $Res call({
    String categoryName,
    String iconPath,
    String colorCode,
    List<ExpenseHistoryTileValue> expenses,
    int categoryTotal,
  });
}

/// @nodoc
class _$ExpenseCategoryGroupCopyWithImpl<
  $Res,
  $Val extends ExpenseCategoryGroup
>
    implements $ExpenseCategoryGroupCopyWith<$Res> {
  _$ExpenseCategoryGroupCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpenseCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryName = null,
    Object? iconPath = null,
    Object? colorCode = null,
    Object? expenses = null,
    Object? categoryTotal = null,
  }) {
    return _then(
      _value.copyWith(
            categoryName: null == categoryName
                ? _value.categoryName
                : categoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            iconPath: null == iconPath
                ? _value.iconPath
                : iconPath // ignore: cast_nullable_to_non_nullable
                      as String,
            colorCode: null == colorCode
                ? _value.colorCode
                : colorCode // ignore: cast_nullable_to_non_nullable
                      as String,
            expenses: null == expenses
                ? _value.expenses
                : expenses // ignore: cast_nullable_to_non_nullable
                      as List<ExpenseHistoryTileValue>,
            categoryTotal: null == categoryTotal
                ? _value.categoryTotal
                : categoryTotal // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExpenseCategoryGroupImplCopyWith<$Res>
    implements $ExpenseCategoryGroupCopyWith<$Res> {
  factory _$$ExpenseCategoryGroupImplCopyWith(
    _$ExpenseCategoryGroupImpl value,
    $Res Function(_$ExpenseCategoryGroupImpl) then,
  ) = __$$ExpenseCategoryGroupImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String categoryName,
    String iconPath,
    String colorCode,
    List<ExpenseHistoryTileValue> expenses,
    int categoryTotal,
  });
}

/// @nodoc
class __$$ExpenseCategoryGroupImplCopyWithImpl<$Res>
    extends _$ExpenseCategoryGroupCopyWithImpl<$Res, _$ExpenseCategoryGroupImpl>
    implements _$$ExpenseCategoryGroupImplCopyWith<$Res> {
  __$$ExpenseCategoryGroupImplCopyWithImpl(
    _$ExpenseCategoryGroupImpl _value,
    $Res Function(_$ExpenseCategoryGroupImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExpenseCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? categoryName = null,
    Object? iconPath = null,
    Object? colorCode = null,
    Object? expenses = null,
    Object? categoryTotal = null,
  }) {
    return _then(
      _$ExpenseCategoryGroupImpl(
        categoryName: null == categoryName
            ? _value.categoryName
            : categoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        iconPath: null == iconPath
            ? _value.iconPath
            : iconPath // ignore: cast_nullable_to_non_nullable
                  as String,
        colorCode: null == colorCode
            ? _value.colorCode
            : colorCode // ignore: cast_nullable_to_non_nullable
                  as String,
        expenses: null == expenses
            ? _value._expenses
            : expenses // ignore: cast_nullable_to_non_nullable
                  as List<ExpenseHistoryTileValue>,
        categoryTotal: null == categoryTotal
            ? _value.categoryTotal
            : categoryTotal // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ExpenseCategoryGroupImpl implements _ExpenseCategoryGroup {
  _$ExpenseCategoryGroupImpl({
    required this.categoryName,
    required this.iconPath,
    required this.colorCode,
    required final List<ExpenseHistoryTileValue> expenses,
    required this.categoryTotal,
  }) : _expenses = expenses;

  /// カテゴリー名（大カテゴリー）
  @override
  final String categoryName;

  /// カテゴリーアイコンパス
  @override
  final String iconPath;

  /// カテゴリー色コード
  @override
  final String colorCode;

  /// このカテゴリーに属する支出リスト（固定費行も含む）
  final List<ExpenseHistoryTileValue> _expenses;

  /// このカテゴリーに属する支出リスト（固定費行も含む）
  @override
  List<ExpenseHistoryTileValue> get expenses {
    if (_expenses is EqualUnmodifiableListView) return _expenses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_expenses);
  }

  /// カテゴリー内の支出合計
  @override
  final int categoryTotal;

  @override
  String toString() {
    return 'ExpenseCategoryGroup(categoryName: $categoryName, iconPath: $iconPath, colorCode: $colorCode, expenses: $expenses, categoryTotal: $categoryTotal)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseCategoryGroupImpl &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName) &&
            (identical(other.iconPath, iconPath) ||
                other.iconPath == iconPath) &&
            (identical(other.colorCode, colorCode) ||
                other.colorCode == colorCode) &&
            const DeepCollectionEquality().equals(other._expenses, _expenses) &&
            (identical(other.categoryTotal, categoryTotal) ||
                other.categoryTotal == categoryTotal));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    categoryName,
    iconPath,
    colorCode,
    const DeepCollectionEquality().hash(_expenses),
    categoryTotal,
  );

  /// Create a copy of ExpenseCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseCategoryGroupImplCopyWith<_$ExpenseCategoryGroupImpl>
  get copyWith =>
      __$$ExpenseCategoryGroupImplCopyWithImpl<_$ExpenseCategoryGroupImpl>(
        this,
        _$identity,
      );
}

abstract class _ExpenseCategoryGroup implements ExpenseCategoryGroup {
  factory _ExpenseCategoryGroup({
    required final String categoryName,
    required final String iconPath,
    required final String colorCode,
    required final List<ExpenseHistoryTileValue> expenses,
    required final int categoryTotal,
  }) = _$ExpenseCategoryGroupImpl;

  /// カテゴリー名（大カテゴリー）
  @override
  String get categoryName;

  /// カテゴリーアイコンパス
  @override
  String get iconPath;

  /// カテゴリー色コード
  @override
  String get colorCode;

  /// このカテゴリーに属する支出リスト（固定費行も含む）
  @override
  List<ExpenseHistoryTileValue> get expenses;

  /// カテゴリー内の支出合計
  @override
  int get categoryTotal;

  /// Create a copy of ExpenseCategoryGroup
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseCategoryGroupImplCopyWith<_$ExpenseCategoryGroupImpl>
  get copyWith => throw _privateConstructorUsedError;
}
