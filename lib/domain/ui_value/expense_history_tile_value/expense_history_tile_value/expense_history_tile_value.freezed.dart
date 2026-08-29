// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense_history_tile_value.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ExpenseHistoryTileValue {
  int get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  int get price => throw _privateConstructorUsedError;
  int get paymentCategoryId => throw _privateConstructorUsedError;
  String get memo => throw _privateConstructorUsedError;
  String get smallCategoryName =>
      throw _privateConstructorUsedError; // 大カテゴリー単位の集計・絞り込みはIDで行う（同名カテゴリーを合算しない）
  int get bigCategoryId => throw _privateConstructorUsedError;
  String get bigCategoryName => throw _privateConstructorUsedError;
  String get colorCode => throw _privateConstructorUsedError;
  String get iconPath => throw _privateConstructorUsedError;
  int get incomeSourceBigCategory =>
      throw _privateConstructorUsedError; // 固定費マスタへの参照。NULL＝通常支出（v10で追加）
  // 明細行に「固定費」チップを出すかの判定に使う（仕様 §7.2）
  int? get fixedCostId =>
      throw _privateConstructorUsedError; // 0=未確定 / 1=確定。通常支出は常に1（v10で追加）
  int get isConfirmed => throw _privateConstructorUsedError;

  /// Create a copy of ExpenseHistoryTileValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpenseHistoryTileValueCopyWith<ExpenseHistoryTileValue> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpenseHistoryTileValueCopyWith<$Res> {
  factory $ExpenseHistoryTileValueCopyWith(
    ExpenseHistoryTileValue value,
    $Res Function(ExpenseHistoryTileValue) then,
  ) = _$ExpenseHistoryTileValueCopyWithImpl<$Res, ExpenseHistoryTileValue>;
  @useResult
  $Res call({
    int id,
    DateTime date,
    int price,
    int paymentCategoryId,
    String memo,
    String smallCategoryName,
    int bigCategoryId,
    String bigCategoryName,
    String colorCode,
    String iconPath,
    int incomeSourceBigCategory,
    int? fixedCostId,
    int isConfirmed,
  });
}

/// @nodoc
class _$ExpenseHistoryTileValueCopyWithImpl<
  $Res,
  $Val extends ExpenseHistoryTileValue
>
    implements $ExpenseHistoryTileValueCopyWith<$Res> {
  _$ExpenseHistoryTileValueCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpenseHistoryTileValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? price = null,
    Object? paymentCategoryId = null,
    Object? memo = null,
    Object? smallCategoryName = null,
    Object? bigCategoryId = null,
    Object? bigCategoryName = null,
    Object? colorCode = null,
    Object? iconPath = null,
    Object? incomeSourceBigCategory = null,
    Object? fixedCostId = freezed,
    Object? isConfirmed = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as int,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            price: null == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as int,
            paymentCategoryId: null == paymentCategoryId
                ? _value.paymentCategoryId
                : paymentCategoryId // ignore: cast_nullable_to_non_nullable
                      as int,
            memo: null == memo
                ? _value.memo
                : memo // ignore: cast_nullable_to_non_nullable
                      as String,
            smallCategoryName: null == smallCategoryName
                ? _value.smallCategoryName
                : smallCategoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            bigCategoryId: null == bigCategoryId
                ? _value.bigCategoryId
                : bigCategoryId // ignore: cast_nullable_to_non_nullable
                      as int,
            bigCategoryName: null == bigCategoryName
                ? _value.bigCategoryName
                : bigCategoryName // ignore: cast_nullable_to_non_nullable
                      as String,
            colorCode: null == colorCode
                ? _value.colorCode
                : colorCode // ignore: cast_nullable_to_non_nullable
                      as String,
            iconPath: null == iconPath
                ? _value.iconPath
                : iconPath // ignore: cast_nullable_to_non_nullable
                      as String,
            incomeSourceBigCategory: null == incomeSourceBigCategory
                ? _value.incomeSourceBigCategory
                : incomeSourceBigCategory // ignore: cast_nullable_to_non_nullable
                      as int,
            fixedCostId: freezed == fixedCostId
                ? _value.fixedCostId
                : fixedCostId // ignore: cast_nullable_to_non_nullable
                      as int?,
            isConfirmed: null == isConfirmed
                ? _value.isConfirmed
                : isConfirmed // ignore: cast_nullable_to_non_nullable
                      as int,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ExpenseHistoryTileValueImplCopyWith<$Res>
    implements $ExpenseHistoryTileValueCopyWith<$Res> {
  factory _$$ExpenseHistoryTileValueImplCopyWith(
    _$ExpenseHistoryTileValueImpl value,
    $Res Function(_$ExpenseHistoryTileValueImpl) then,
  ) = __$$ExpenseHistoryTileValueImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int id,
    DateTime date,
    int price,
    int paymentCategoryId,
    String memo,
    String smallCategoryName,
    int bigCategoryId,
    String bigCategoryName,
    String colorCode,
    String iconPath,
    int incomeSourceBigCategory,
    int? fixedCostId,
    int isConfirmed,
  });
}

/// @nodoc
class __$$ExpenseHistoryTileValueImplCopyWithImpl<$Res>
    extends
        _$ExpenseHistoryTileValueCopyWithImpl<
          $Res,
          _$ExpenseHistoryTileValueImpl
        >
    implements _$$ExpenseHistoryTileValueImplCopyWith<$Res> {
  __$$ExpenseHistoryTileValueImplCopyWithImpl(
    _$ExpenseHistoryTileValueImpl _value,
    $Res Function(_$ExpenseHistoryTileValueImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ExpenseHistoryTileValue
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? price = null,
    Object? paymentCategoryId = null,
    Object? memo = null,
    Object? smallCategoryName = null,
    Object? bigCategoryId = null,
    Object? bigCategoryName = null,
    Object? colorCode = null,
    Object? iconPath = null,
    Object? incomeSourceBigCategory = null,
    Object? fixedCostId = freezed,
    Object? isConfirmed = null,
  }) {
    return _then(
      _$ExpenseHistoryTileValueImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as int,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        price: null == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as int,
        paymentCategoryId: null == paymentCategoryId
            ? _value.paymentCategoryId
            : paymentCategoryId // ignore: cast_nullable_to_non_nullable
                  as int,
        memo: null == memo
            ? _value.memo
            : memo // ignore: cast_nullable_to_non_nullable
                  as String,
        smallCategoryName: null == smallCategoryName
            ? _value.smallCategoryName
            : smallCategoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        bigCategoryId: null == bigCategoryId
            ? _value.bigCategoryId
            : bigCategoryId // ignore: cast_nullable_to_non_nullable
                  as int,
        bigCategoryName: null == bigCategoryName
            ? _value.bigCategoryName
            : bigCategoryName // ignore: cast_nullable_to_non_nullable
                  as String,
        colorCode: null == colorCode
            ? _value.colorCode
            : colorCode // ignore: cast_nullable_to_non_nullable
                  as String,
        iconPath: null == iconPath
            ? _value.iconPath
            : iconPath // ignore: cast_nullable_to_non_nullable
                  as String,
        incomeSourceBigCategory: null == incomeSourceBigCategory
            ? _value.incomeSourceBigCategory
            : incomeSourceBigCategory // ignore: cast_nullable_to_non_nullable
                  as int,
        fixedCostId: freezed == fixedCostId
            ? _value.fixedCostId
            : fixedCostId // ignore: cast_nullable_to_non_nullable
                  as int?,
        isConfirmed: null == isConfirmed
            ? _value.isConfirmed
            : isConfirmed // ignore: cast_nullable_to_non_nullable
                  as int,
      ),
    );
  }
}

/// @nodoc

class _$ExpenseHistoryTileValueImpl implements _ExpenseHistoryTileValue {
  const _$ExpenseHistoryTileValueImpl({
    required this.id,
    required this.date,
    required this.price,
    required this.paymentCategoryId,
    this.memo = '',
    required this.smallCategoryName,
    required this.bigCategoryId,
    required this.bigCategoryName,
    required this.colorCode,
    required this.iconPath,
    required this.incomeSourceBigCategory,
    this.fixedCostId,
    this.isConfirmed = 1,
  });

  @override
  final int id;
  @override
  final DateTime date;
  @override
  final int price;
  @override
  final int paymentCategoryId;
  @override
  @JsonKey()
  final String memo;
  @override
  final String smallCategoryName;
  // 大カテゴリー単位の集計・絞り込みはIDで行う（同名カテゴリーを合算しない）
  @override
  final int bigCategoryId;
  @override
  final String bigCategoryName;
  @override
  final String colorCode;
  @override
  final String iconPath;
  @override
  final int incomeSourceBigCategory;
  // 固定費マスタへの参照。NULL＝通常支出（v10で追加）
  // 明細行に「固定費」チップを出すかの判定に使う（仕様 §7.2）
  @override
  final int? fixedCostId;
  // 0=未確定 / 1=確定。通常支出は常に1（v10で追加）
  @override
  @JsonKey()
  final int isConfirmed;

  @override
  String toString() {
    return 'ExpenseHistoryTileValue(id: $id, date: $date, price: $price, paymentCategoryId: $paymentCategoryId, memo: $memo, smallCategoryName: $smallCategoryName, bigCategoryId: $bigCategoryId, bigCategoryName: $bigCategoryName, colorCode: $colorCode, iconPath: $iconPath, incomeSourceBigCategory: $incomeSourceBigCategory, fixedCostId: $fixedCostId, isConfirmed: $isConfirmed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpenseHistoryTileValueImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.paymentCategoryId, paymentCategoryId) ||
                other.paymentCategoryId == paymentCategoryId) &&
            (identical(other.memo, memo) || other.memo == memo) &&
            (identical(other.smallCategoryName, smallCategoryName) ||
                other.smallCategoryName == smallCategoryName) &&
            (identical(other.bigCategoryId, bigCategoryId) ||
                other.bigCategoryId == bigCategoryId) &&
            (identical(other.bigCategoryName, bigCategoryName) ||
                other.bigCategoryName == bigCategoryName) &&
            (identical(other.colorCode, colorCode) ||
                other.colorCode == colorCode) &&
            (identical(other.iconPath, iconPath) ||
                other.iconPath == iconPath) &&
            (identical(
                  other.incomeSourceBigCategory,
                  incomeSourceBigCategory,
                ) ||
                other.incomeSourceBigCategory == incomeSourceBigCategory) &&
            (identical(other.fixedCostId, fixedCostId) ||
                other.fixedCostId == fixedCostId) &&
            (identical(other.isConfirmed, isConfirmed) ||
                other.isConfirmed == isConfirmed));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    date,
    price,
    paymentCategoryId,
    memo,
    smallCategoryName,
    bigCategoryId,
    bigCategoryName,
    colorCode,
    iconPath,
    incomeSourceBigCategory,
    fixedCostId,
    isConfirmed,
  );

  /// Create a copy of ExpenseHistoryTileValue
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpenseHistoryTileValueImplCopyWith<_$ExpenseHistoryTileValueImpl>
  get copyWith =>
      __$$ExpenseHistoryTileValueImplCopyWithImpl<
        _$ExpenseHistoryTileValueImpl
      >(this, _$identity);
}

abstract class _ExpenseHistoryTileValue implements ExpenseHistoryTileValue {
  const factory _ExpenseHistoryTileValue({
    required final int id,
    required final DateTime date,
    required final int price,
    required final int paymentCategoryId,
    final String memo,
    required final String smallCategoryName,
    required final int bigCategoryId,
    required final String bigCategoryName,
    required final String colorCode,
    required final String iconPath,
    required final int incomeSourceBigCategory,
    final int? fixedCostId,
    final int isConfirmed,
  }) = _$ExpenseHistoryTileValueImpl;

  @override
  int get id;
  @override
  DateTime get date;
  @override
  int get price;
  @override
  int get paymentCategoryId;
  @override
  String get memo;
  @override
  String get smallCategoryName; // 大カテゴリー単位の集計・絞り込みはIDで行う（同名カテゴリーを合算しない）
  @override
  int get bigCategoryId;
  @override
  String get bigCategoryName;
  @override
  String get colorCode;
  @override
  String get iconPath;
  @override
  int get incomeSourceBigCategory; // 固定費マスタへの参照。NULL＝通常支出（v10で追加）
  // 明細行に「固定費」チップを出すかの判定に使う（仕様 §7.2）
  @override
  int? get fixedCostId; // 0=未確定 / 1=確定。通常支出は常に1（v10で追加）
  @override
  int get isConfirmed;

  /// Create a copy of ExpenseHistoryTileValue
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpenseHistoryTileValueImplCopyWith<_$ExpenseHistoryTileValueImpl>
  get copyWith => throw _privateConstructorUsedError;
}
