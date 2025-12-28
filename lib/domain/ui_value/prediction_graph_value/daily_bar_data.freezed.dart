// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'daily_bar_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DailyBarData {
  DateTime get date => throw _privateConstructorUsedError;
  bool get isFutureDate => throw _privateConstructorUsedError;
  List<CategoryExpense> get categoryExpenses =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $DailyBarDataCopyWith<DailyBarData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DailyBarDataCopyWith<$Res> {
  factory $DailyBarDataCopyWith(
          DailyBarData value, $Res Function(DailyBarData) then) =
      _$DailyBarDataCopyWithImpl<$Res, DailyBarData>;
  @useResult
  $Res call(
      {DateTime date,
      bool isFutureDate,
      List<CategoryExpense> categoryExpenses});
}

/// @nodoc
class _$DailyBarDataCopyWithImpl<$Res, $Val extends DailyBarData>
    implements $DailyBarDataCopyWith<$Res> {
  _$DailyBarDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? isFutureDate = null,
    Object? categoryExpenses = null,
  }) {
    return _then(_value.copyWith(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFutureDate: null == isFutureDate
          ? _value.isFutureDate
          : isFutureDate // ignore: cast_nullable_to_non_nullable
              as bool,
      categoryExpenses: null == categoryExpenses
          ? _value.categoryExpenses
          : categoryExpenses // ignore: cast_nullable_to_non_nullable
              as List<CategoryExpense>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DailyBarDataImplCopyWith<$Res>
    implements $DailyBarDataCopyWith<$Res> {
  factory _$$DailyBarDataImplCopyWith(
          _$DailyBarDataImpl value, $Res Function(_$DailyBarDataImpl) then) =
      __$$DailyBarDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {DateTime date,
      bool isFutureDate,
      List<CategoryExpense> categoryExpenses});
}

/// @nodoc
class __$$DailyBarDataImplCopyWithImpl<$Res>
    extends _$DailyBarDataCopyWithImpl<$Res, _$DailyBarDataImpl>
    implements _$$DailyBarDataImplCopyWith<$Res> {
  __$$DailyBarDataImplCopyWithImpl(
      _$DailyBarDataImpl _value, $Res Function(_$DailyBarDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? date = null,
    Object? isFutureDate = null,
    Object? categoryExpenses = null,
  }) {
    return _then(_$DailyBarDataImpl(
      date: null == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isFutureDate: null == isFutureDate
          ? _value.isFutureDate
          : isFutureDate // ignore: cast_nullable_to_non_nullable
              as bool,
      categoryExpenses: null == categoryExpenses
          ? _value._categoryExpenses
          : categoryExpenses // ignore: cast_nullable_to_non_nullable
              as List<CategoryExpense>,
    ));
  }
}

/// @nodoc

class _$DailyBarDataImpl implements _DailyBarData {
  const _$DailyBarDataImpl(
      {required this.date,
      required this.isFutureDate,
      required final List<CategoryExpense> categoryExpenses})
      : _categoryExpenses = categoryExpenses;

  @override
  final DateTime date;
  @override
  final bool isFutureDate;
  final List<CategoryExpense> _categoryExpenses;
  @override
  List<CategoryExpense> get categoryExpenses {
    if (_categoryExpenses is EqualUnmodifiableListView)
      return _categoryExpenses;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_categoryExpenses);
  }

  @override
  String toString() {
    return 'DailyBarData(date: $date, isFutureDate: $isFutureDate, categoryExpenses: $categoryExpenses)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DailyBarDataImpl &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.isFutureDate, isFutureDate) ||
                other.isFutureDate == isFutureDate) &&
            const DeepCollectionEquality()
                .equals(other._categoryExpenses, _categoryExpenses));
  }

  @override
  int get hashCode => Object.hash(runtimeType, date, isFutureDate,
      const DeepCollectionEquality().hash(_categoryExpenses));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DailyBarDataImplCopyWith<_$DailyBarDataImpl> get copyWith =>
      __$$DailyBarDataImplCopyWithImpl<_$DailyBarDataImpl>(this, _$identity);
}

abstract class _DailyBarData implements DailyBarData {
  const factory _DailyBarData(
          {required final DateTime date,
          required final bool isFutureDate,
          required final List<CategoryExpense> categoryExpenses}) =
      _$DailyBarDataImpl;

  @override
  DateTime get date;
  @override
  bool get isFutureDate;
  @override
  List<CategoryExpense> get categoryExpenses;
  @override
  @JsonKey(ignore: true)
  _$$DailyBarDataImplCopyWith<_$DailyBarDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CategoryExpense {
  int get bigCategoryId => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;
  String get colorCode => throw _privateConstructorUsedError;
  String get iconPath => throw _privateConstructorUsedError;
  String get categoryName => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CategoryExpenseCopyWith<CategoryExpense> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryExpenseCopyWith<$Res> {
  factory $CategoryExpenseCopyWith(
          CategoryExpense value, $Res Function(CategoryExpense) then) =
      _$CategoryExpenseCopyWithImpl<$Res, CategoryExpense>;
  @useResult
  $Res call(
      {int bigCategoryId,
      int price,
      String colorCode,
      String iconPath,
      String categoryName});
}

/// @nodoc
class _$CategoryExpenseCopyWithImpl<$Res, $Val extends CategoryExpense>
    implements $CategoryExpenseCopyWith<$Res> {
  _$CategoryExpenseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bigCategoryId = null,
    Object? price = null,
    Object? colorCode = null,
    Object? iconPath = null,
    Object? categoryName = null,
  }) {
    return _then(_value.copyWith(
      bigCategoryId: null == bigCategoryId
          ? _value.bigCategoryId
          : bigCategoryId // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      colorCode: null == colorCode
          ? _value.colorCode
          : colorCode // ignore: cast_nullable_to_non_nullable
              as String,
      iconPath: null == iconPath
          ? _value.iconPath
          : iconPath // ignore: cast_nullable_to_non_nullable
              as String,
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CategoryExpenseImplCopyWith<$Res>
    implements $CategoryExpenseCopyWith<$Res> {
  factory _$$CategoryExpenseImplCopyWith(_$CategoryExpenseImpl value,
          $Res Function(_$CategoryExpenseImpl) then) =
      __$$CategoryExpenseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int bigCategoryId,
      int price,
      String colorCode,
      String iconPath,
      String categoryName});
}

/// @nodoc
class __$$CategoryExpenseImplCopyWithImpl<$Res>
    extends _$CategoryExpenseCopyWithImpl<$Res, _$CategoryExpenseImpl>
    implements _$$CategoryExpenseImplCopyWith<$Res> {
  __$$CategoryExpenseImplCopyWithImpl(
      _$CategoryExpenseImpl _value, $Res Function(_$CategoryExpenseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bigCategoryId = null,
    Object? price = null,
    Object? colorCode = null,
    Object? iconPath = null,
    Object? categoryName = null,
  }) {
    return _then(_$CategoryExpenseImpl(
      bigCategoryId: null == bigCategoryId
          ? _value.bigCategoryId
          : bigCategoryId // ignore: cast_nullable_to_non_nullable
              as int,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as int,
      colorCode: null == colorCode
          ? _value.colorCode
          : colorCode // ignore: cast_nullable_to_non_nullable
              as String,
      iconPath: null == iconPath
          ? _value.iconPath
          : iconPath // ignore: cast_nullable_to_non_nullable
              as String,
      categoryName: null == categoryName
          ? _value.categoryName
          : categoryName // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$CategoryExpenseImpl implements _CategoryExpense {
  const _$CategoryExpenseImpl(
      {required this.bigCategoryId,
      required this.price,
      required this.colorCode,
      required this.iconPath,
      required this.categoryName});

  @override
  final int bigCategoryId;
  @override
  final int price;
  @override
  final String colorCode;
  @override
  final String iconPath;
  @override
  final String categoryName;

  @override
  String toString() {
    return 'CategoryExpense(bigCategoryId: $bigCategoryId, price: $price, colorCode: $colorCode, iconPath: $iconPath, categoryName: $categoryName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CategoryExpenseImpl &&
            (identical(other.bigCategoryId, bigCategoryId) ||
                other.bigCategoryId == bigCategoryId) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.colorCode, colorCode) ||
                other.colorCode == colorCode) &&
            (identical(other.iconPath, iconPath) ||
                other.iconPath == iconPath) &&
            (identical(other.categoryName, categoryName) ||
                other.categoryName == categoryName));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, bigCategoryId, price, colorCode, iconPath, categoryName);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CategoryExpenseImplCopyWith<_$CategoryExpenseImpl> get copyWith =>
      __$$CategoryExpenseImplCopyWithImpl<_$CategoryExpenseImpl>(
          this, _$identity);
}

abstract class _CategoryExpense implements CategoryExpense {
  const factory _CategoryExpense(
      {required final int bigCategoryId,
      required final int price,
      required final String colorCode,
      required final String iconPath,
      required final String categoryName}) = _$CategoryExpenseImpl;

  @override
  int get bigCategoryId;
  @override
  int get price;
  @override
  String get colorCode;
  @override
  String get iconPath;
  @override
  String get categoryName;
  @override
  @JsonKey(ignore: true)
  _$$CategoryExpenseImplCopyWith<_$CategoryExpenseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
