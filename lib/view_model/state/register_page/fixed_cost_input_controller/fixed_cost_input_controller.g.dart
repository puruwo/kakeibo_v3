// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_cost_input_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$fixedCostRegisterToggleControllerNotifierHash() =>
    r'b96d2d8905965ceb32fdfd80b2337b3f5dc7c39d';

/// 登録・編集シートの固定費グループ専用の入力状態
///
/// v10で固定費タブを廃止し支出タブのトグルへ吸収したため、
/// 旧・固定費タブ専用だった state をこのファイルへ統合した（仕様 §8.2）。
/// 「固定費として登録」トグルの状態
///
/// ONのとき基本グループは拠出元のみに縮み、固定費グループに
/// 名称／初回支払日／頻度／支払い額が毎回変わる の4行が展開する（仕様 §6.1）。
///
/// Copied from [FixedCostRegisterToggleControllerNotifier].
@ProviderFor(FixedCostRegisterToggleControllerNotifier)
final fixedCostRegisterToggleControllerNotifierProvider =
    AutoDisposeNotifierProvider<
      FixedCostRegisterToggleControllerNotifier,
      bool
    >.internal(
      FixedCostRegisterToggleControllerNotifier.new,
      name: r'fixedCostRegisterToggleControllerNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fixedCostRegisterToggleControllerNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FixedCostRegisterToggleControllerNotifier = AutoDisposeNotifier<bool>;
String _$fixedCostVariableSwitchControllerNotifierHash() =>
    r'3c78b899d4de2f3f2c0528823c891c6bab975007';

/// 「支払い額が毎回変わる」スイッチの状態（旧 PriceTypeSwitchControllerNotifier）
///
/// ONのとき金額は入力させず `---` 表示にし、実績は推定額で扱う。
///
/// Copied from [FixedCostVariableSwitchControllerNotifier].
@ProviderFor(FixedCostVariableSwitchControllerNotifier)
final fixedCostVariableSwitchControllerNotifierProvider =
    AutoDisposeNotifierProvider<
      FixedCostVariableSwitchControllerNotifier,
      bool
    >.internal(
      FixedCostVariableSwitchControllerNotifier.new,
      name: r'fixedCostVariableSwitchControllerNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$fixedCostVariableSwitchControllerNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FixedCostVariableSwitchControllerNotifier = AutoDisposeNotifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
