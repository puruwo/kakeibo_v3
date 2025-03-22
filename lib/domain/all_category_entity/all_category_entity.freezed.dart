// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'all_category_entity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AllCategoryEntity _$AllCategoryEntityFromJson(Map<String, dynamic> json) {
  return _AllCategoryEntity.fromJson(json);
}

/// @nodoc
mixin _$AllCategoryEntity {
  int get totalExpense => throw _privateConstructorUsedError;
  int get totalBudget => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AllCategoryEntityCopyWith<AllCategoryEntity> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AllCategoryEntityCopyWith<$Res> {
  factory $AllCategoryEntityCopyWith(
          AllCategoryEntity value, $Res Function(AllCategoryEntity) then) =
      _$AllCategoryEntityCopyWithImpl<$Res, AllCategoryEntity>;
  @useResult
  $Res call({int totalExpense, int totalBudget});
}

/// @nodoc
class _$AllCategoryEntityCopyWithImpl<$Res, $Val extends AllCategoryEntity>
    implements $AllCategoryEntityCopyWith<$Res> {
  _$AllCategoryEntityCopyWithImpl(this._value, this._then);

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
abstract class _$$AllCategoryEntityImplCopyWith<$Res>
    implements $AllCategoryEntityCopyWith<$Res> {
  factory _$$AllCategoryEntityImplCopyWith(_$AllCategoryEntityImpl value,
          $Res Function(_$AllCategoryEntityImpl) then) =
      __$$AllCategoryEntityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int totalExpense, int totalBudget});
}

/// @nodoc
class __$$AllCategoryEntityImplCopyWithImpl<$Res>
    extends _$AllCategoryEntityCopyWithImpl<$Res, _$AllCategoryEntityImpl>
    implements _$$AllCategoryEntityImplCopyWith<$Res> {
  __$$AllCategoryEntityImplCopyWithImpl(_$AllCategoryEntityImpl _value,
      $Res Function(_$AllCategoryEntityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalExpense = null,
    Object? totalBudget = null,
  }) {
    return _then(_$AllCategoryEntityImpl(
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
class _$AllCategoryEntityImpl implements _AllCategoryEntity {
  const _$AllCategoryEntityImpl(
      {required this.totalExpense, required this.totalBudget});

  factory _$AllCategoryEntityImpl.fromJson(Map<String, dynamic> json) =>
      _$$AllCategoryEntityImplFromJson(json);

  @override
  final int totalExpense;
  @override
  final int totalBudget;

  @override
  String toString() {
    return 'AllCategoryEntity(totalExpense: $totalExpense, totalBudget: $totalBudget)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AllCategoryEntityImpl &&
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
  _$$AllCategoryEntityImplCopyWith<_$AllCategoryEntityImpl> get copyWith =>
      __$$AllCategoryEntityImplCopyWithImpl<_$AllCategoryEntityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AllCategoryEntityImplToJson(
      this,
    );
  }
}

abstract class _AllCategoryEntity implements AllCategoryEntity {
  const factory _AllCategoryEntity(
      {required final int totalExpense,
      required final int totalBudget}) = _$AllCategoryEntityImpl;

  factory _AllCategoryEntity.fromJson(Map<String, dynamic> json) =
      _$AllCategoryEntityImpl.fromJson;

  @override
  int get totalExpense;
  @override
  int get totalBudget;
  @override
  @JsonKey(ignore: true)
  _$$AllCategoryEntityImplCopyWith<_$AllCategoryEntityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
