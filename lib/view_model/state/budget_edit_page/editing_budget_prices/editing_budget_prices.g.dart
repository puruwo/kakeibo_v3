// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'editing_budget_prices.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$editingBudgetPricesNotifierHash() =>
    r'd436071c8aec071e967f52831fb8c36b2c742a55';

/// 予算編集中の金額を一時保持するプロバイダ
/// key: expenseBigCategoryId, value: 入力された金額
/// BudgetPageSummaryAreaがwatchし、リアルタイムでサマリーに反映する
///
/// Copied from [EditingBudgetPricesNotifier].
@ProviderFor(EditingBudgetPricesNotifier)
final editingBudgetPricesNotifierProvider =
    AutoDisposeNotifierProvider<
      EditingBudgetPricesNotifier,
      Map<int, int>
    >.internal(
      EditingBudgetPricesNotifier.new,
      name: r'editingBudgetPricesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$editingBudgetPricesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EditingBudgetPricesNotifier = AutoDisposeNotifier<Map<int, int>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
