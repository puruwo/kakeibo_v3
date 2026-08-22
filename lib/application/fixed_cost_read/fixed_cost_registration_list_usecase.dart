import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/ui_value/fixed_cost_registration_list_value/fixed_cost_registration_list_entity.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// 固定費登録一覧を取得するユースケース
// グルーピングの単位は支出大カテゴリー（v10で固定費カテゴリーから変更。仕様 §8.4）

final fixedCostRegistrationListNotifierProvider =
    AsyncNotifierProvider<FixedCostRegistrationListUsecaseNotifier,
        FixedCostRegistrationListValue>(
  FixedCostRegistrationListUsecaseNotifier.new,
);

class FixedCostRegistrationListUsecaseNotifier
    extends AsyncNotifier<FixedCostRegistrationListValue> {
  late FixedCostRepository _fixedCostRepo;
  late ExpenseSmallCategoryRepository _smallCategoryRepo;
  late ExpenseBigCategoryRepository _bigCategoryRepo;

  @override
  Future<FixedCostRegistrationListValue> build() async {
    // DBが更新された場合にbuildメソッドを再実行する
    ref.watch(updateDBCountNotifierProvider);

    _fixedCostRepo = ref.read(fixedCostRepositoryProvider);
    _smallCategoryRepo = ref.read(expenseSmallCategoryRepositoryProvider);
    _bigCategoryRepo = ref.read(expensebigCategoryRepositoryProvider);

    // 削除されていない固定費のみを取得
    final allFixedCosts = await _fixedCostRepo.fetchAllActive();

    // 小カテゴリー → 大カテゴリー の対応表を作る
    final smallCategories = await _smallCategoryRepo.fetchAll();
    final smallToBig = <int, int>{
      for (final small in smallCategories) small.id: small.bigCategoryKey,
    };

    // 支出大カテゴリーidごとにグループ化するためのマップ
    final Map<int, List<FixedCostEntity>> categoryMap = {};

    for (var fixedCost in allFixedCosts) {
      final bigCategoryId = smallToBig[fixedCost.expenseSmallCategoryId];
      // 参照先が解決できないマスタは一覧に出せないため除外する
      if (bigCategoryId == null) continue;

      categoryMap.putIfAbsent(bigCategoryId, () => []).add(fixedCost);
    }

    // カテゴリーごとにグループ化したリストを作成（大カテゴリーの表示順に並べる）
    final allCategories = await _bigCategoryRepo.fetchAll();
    final List<FixedCostCategoryGroup> categoryGroups = [];

    for (var category in allCategories) {
      // このカテゴリーに属する固定費があれば追加
      final items = categoryMap[category.id] ?? [];
      if (items.isNotEmpty) {
        categoryGroups.add(
          FixedCostCategoryGroup(
            categoryId: category.id,
            categoryName: category.bigCategoryName,
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
