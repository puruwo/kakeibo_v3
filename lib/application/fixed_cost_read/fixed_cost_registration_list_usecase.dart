import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost_category/fixed_cost_category_repository.dart';
import 'package:kakeibo/domain/ui_value/fixed_cost_registration_list_value/fixed_cost_registration_list_entity.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// 固定費登録一覧を取得するユースケース

final fixedCostRegistrationListNotifierProvider =
    AsyncNotifierProvider<FixedCostRegistrationListUsecaseNotifier,
        FixedCostRegistrationListValue>(
  FixedCostRegistrationListUsecaseNotifier.new,
);

class FixedCostRegistrationListUsecaseNotifier
    extends AsyncNotifier<FixedCostRegistrationListValue> {
  late FixedCostRepository _fixedCostRepo;
  late FixedCostCategoryRepository _fixedCostCategoryRepo;

  @override
  Future<FixedCostRegistrationListValue> build() async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _fixedCostRepo = ref.read(fixedCostRepositoryProvider);
    _fixedCostCategoryRepo = ref.read(fixedCostCategoryRepositoryProvider);

    // 削除されていない固定費のみを取得
    final allFixedCosts = await _fixedCostRepo.fetchAllActive();

    // 全てのカテゴリーを取得
    final allCategories = await _fixedCostCategoryRepo.fetchAll();

    // カテゴリーIDごとにグループ化するためのマップ
    final Map<int, List<FixedCostEntity>> categoryMap = {};

    for (var fixedCost in allFixedCosts) {
      final categoryId = fixedCost.fixedCostCategoryId;

      // カテゴリーマップに初期化
      if (!categoryMap.containsKey(categoryId)) {
        categoryMap[categoryId] = [];
      }

      categoryMap[categoryId]!.add(fixedCost);
    }

    // カテゴリーごとにグループ化したリストを作成
    final List<FixedCostCategoryGroup> categoryGroups = [];

    for (var category in allCategories) {
      // このカテゴリーに属する固定費があれば追加
      final items = categoryMap[category.id] ?? [];
      if (items.isNotEmpty) {
        categoryGroups.add(
          FixedCostCategoryGroup(
            categoryId: category.id,
            categoryName: category.categoryName,
            categoryIconPath: category.resourcePath,
            categoryColorCode: category.colorCode,
            items: items,
          ),
        );
      }
    }

    return FixedCostRegistrationListValue(
      categoryGroups: categoryGroups,
    );
  }
}
