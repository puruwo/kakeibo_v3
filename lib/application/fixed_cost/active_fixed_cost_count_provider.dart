import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

/// 有効な固定費（削除されていない固定費）の件数を提供するプロバイダー
final activeFixedCostCountProvider = FutureProvider<int>((ref) async {
  // DBが更新された場合にリビルドする
  ref.watch(updateDBCountNotifierProvider);

  final fixedCostRepo = ref.read(fixedCostRepositoryProvider);
  final activeFixedCosts = await fixedCostRepo.fetchAllActive();

  return activeFixedCosts.length;
});
