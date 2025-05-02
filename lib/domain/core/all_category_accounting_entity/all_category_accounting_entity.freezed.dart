// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'all_category_accounting_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AllCategoryAccountingEntity _$AllCategoryAccountingEntityFromJson(
    Map<String, dynamic> json) {
  return _AllCategoryAccountingEntity.fromJson(json);
}

/// @nodoc
mixin _$AllCategoryAccountingEntity {
  int get totalExpense => throw _privateConstructorUsedError;
  int get totalBudget => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AllCategoryAccountingEntityCopyWith<AllCategoryAccountingEntity>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllCategoryAccountingEntityCopyWith<$Res> {
  factory $AllCategoryAccountingEntityCopyWith(
          AllCategoryAccountingEntity value,
          $Res Function(AllCategoryAccountingEntity) then) =
      _$AllCategoryAccountingEntityCopyWithImpl<$Res,
          AllCategoryAccountingEntity>;
  @useResult
  $Res call({int totalExpense, int totalBudget});
}

/// @nodoc
class _$AllCategoryAccountingEntityCopyWithImpl<$Res,
        $Val extends AllCategoryAccountingEntity>
    implements $AllCategoryAccountingEntityCopyWith<$Res> {
  _$AllCategoryAccountingEntityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalExpense = null,
    Object? totalBudget = null,
  }) {
    return _then(_value.copyWith(
      totalExpense: null == totalExpense
          ? _value.totalExpense
          : totalExpense // ignore: cast_nullable_to_non_nullable
              as int,
      totalBudget: null == totalBudget
          ? _value.totalBudget
          : totalBudget // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AllCategoryAccountingEntityImplCopyWith<$Res>
    implements $AllCategoryAccountingEntityCopyWith<$Res> {
  factory _$$AllCategoryAccountingEntityImplCopyWith(
          _$AllCategoryAccountingEntityImpl value,
          $Res Function(_$AllCategoryAccountingEntityImpl) then) =
      __$$AllCategoryAccountingEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int totalExpense, int totalBudget});
}

/// @nodoc
class __$$AllCategoryAccountingEntityImplCopyWithImpl<$Res>
    extends _$AllCategoryAccountingEntityCopyWithImpl<$Res,
        _$AllCategoryAccountingEntityImpl>
    implements _$$AllCategoryAccountingEntityImplCopyWith<$Res> {
  __$$AllCategoryAccountingEntityImplCopyWithImpl(
      _$AllCategoryAccountingEntityImpl _value,
      $Res Function(_$AllCategoryAccountingEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalExpense = null,
    Object? totalBudget = null,
  }) {
    return _then(_$AllCategoryAccountingEntityImpl(
      totalExpense: null == totalExpense
          ? _value.totalExpense
          : totalExpense // ignore: cast_nullable_to_non_nullable
              as int,
      totalBudget: null == totalBudget
          ? _value.totalBudget
          : totalBudget // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AllCategoryAccountingEntityImpl
    implements _AllCategoryAccountingEntity {
  const _$AllCategoryAccountingEntityImpl(
      {required this.totalExpense, required this.totalBudget});

  factory _$AllCategoryAccountingEntityImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$AllCategoryAccountingEntityImplFromJson(json);

  @override
  final int totalExpense;
  @override
  final int totalBudget;

  @override
  String toString() {
    return 'AllCategoryAccountingEntity(totalExpense: $totalExpense, totalBudget: $totalBudget)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllCategoryAccountingEntityImpl &&
            (identical(other.totalExpense, totalExpense) ||
                other.totalExpense == totalExpense) &&
            (identical(other.totalBudget, totalBudget) ||
                other.totalBudget == totalBudget));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, totalExpense, totalBudget);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AllCategoryAccountingEntityImplCopyWith<_$AllCategoryAccountingEntityImpl>
      get copyWith => __$$AllCategoryAccountingEntityImplCopyWithImpl<
          _$AllCategoryAccountingEntityImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AllCategoryAccountingEntityImplToJson(
      this,
    );
  }
}

abstract class _AllCategoryAccountingEntity
    implements AllCategoryAccountingEntity {
  const factory _AllCategoryAccountingEntity(
      {required final int totalExpense,
      required final int totalBudget}) = _$AllCategoryAccountingEntityImpl;

  factory _AllCategoryAccountingEntity.fromJson(Map<String, dynamic> json) =
      _$AllCategoryAccountingEntityImpl.fromJson;

  @override
  int get totalExpense;
  @override
  int get totalBudget;
  @override
  @JsonKey(ignore: true)
  _$$AllCategoryAccountingEntityImplCopyWith<_$AllCategoryAccountingEntityImpl>
      get copyWith => throw _privateConstructorUsedError;
}
