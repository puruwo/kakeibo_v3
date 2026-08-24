import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_entity.dart';
import 'package:kakeibo/domain/db/expense_big_ctegory/expense_big_category_repository.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_entity.dart';
import 'package:kakeibo/domain/db/expense_small_category/expense_small_category_repository.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_repository.dart';
import 'package:kakeibo/domain/ui_value/fixed_cost_registration_list_value/fixed_cost_registration_list_entity.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

// 固定費登録一覧を取得するユースケース
// グルーピングの単位は支出大カテゴリー（v10で固定費カテゴリーから変更。仕様 §8.4）

final fixedCostRegistrationListNotifierProvider =
    AsyncNotifierProvider<
      FixedCostRegistrationListUsecaseNotifier,
      FixedCostRegistrationListValue
    >(FixedCostRegistrationListUsecaseNotifier.new);

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

    // 3クエリは互いに依存しないため並行取得する（トップのローディング時間短縮）
    final results = await Future.wait([
      // 削除されていない固定費のみを取得
      _fixedCostRepo.fetchAllActive(),
      _smallCategoryRepo.fetchAll(),
      _bigCategoryRepo.fetchAll(),
    ]);
    final allFixedCosts = results[0] as List<FixedCostEntity>;
    final smallCategories = results[1] as List<ExpenseSmallCategoryEntity>;
    final allCategories = results[2] as List<ExpenseBigCategoryEntity>;

    // 小カテゴリー → 大カテゴリー の対応表を作る
    final smallToBig = <int, int>{
      for (final small in smallCategories) small.id: small.bigCategoryKey,
    };

    // 支出大カテゴリーidごとにグループ化するためのマップ
    final Map<int, List<FixedCostEntity>> categoryMap = {};
    // 参照先の小カテゴリーが解決できないマスタ（削除・移行漏れ等）の受け皿
    final List<FixedCostEntity> unresolvedItems = [];

    for (var fixedCost in allFixedCosts) {
      final bigCategoryId = smallToBig[fixedCost.expenseSmallCategoryId];
      if (bigCategoryId == null) {
        // 除外すると登録済みなのに空状態と誤判定されるため、末尾グループに出す
        unresolvedItems.add(fixedCost);
        continue;
      }

      categoryMap.putIfAbsent(bigCategoryId, () => []).add(fixedCost);
    }

    // カテゴリーごとにグループ化したリストを作成（大カテゴリーの表示順に並べる）
    final List<ExpenseBigCategoryGroup> categoryGroups = [];

    for (var category in allCategories) {
      // このカテゴリーに属する固定費があれば追加
      final items = categoryMap[category.id] ?? [];
      if (items.isNotEmpty) {
        categoryGroups.add(
          ExpenseBigCategoryGroup(
            categoryId: category.id,
            categoryName: category.bigCategoryName,
            categoryIconPath: category.resourcePath,
            categoryColorCode: category.colorCode,
            items: items,
          ),
        );
      }
    }

    // カテゴリー未解決のマスタは「その他」相当の末尾グループとして提示する
    if (unresolvedItems.isNotEmpty) {
      categoryGroups.add(
        ExpenseBigCategoryGroup(
          categoryId: -1,
          categoryName: 'カテゴリー未設定',
          categoryIconPath: 'assets/images/icon_others.svg',
          categoryColorCode: '8E8E93',
          items: unresolvedItems,
        ),
      );
    }

    return FixedCostRegistrationListValue(categoryGroups: categoryGroups);
  }
}
