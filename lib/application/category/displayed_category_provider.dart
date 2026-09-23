import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/category/category_selection_provider.dart';
import 'package:kakeibo/application/category/register_grid_category_rule.dart';
import 'package:kakeibo/domain/core/category_entity/i_category_entity.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';

/// 記録モーダルのグリッドに直接出すカテゴリー一覧（KP-032）
///
/// 全件（[categoriesByModeProvider]）から `default_displayed = 1` を表示順の先頭から
/// 最大29件取り出す。全件側が DB 更新で読み直されれば、こちらも追従する。
final displayedCategoriesByModeProvider = FutureProvider.autoDispose
    .family<List<ICategoryEntity>, TransactionMode>((ref, mode) async {
      final all = await ref.watch(categoriesByModeProvider(mode).future);
      return RegisterGridCategoryRule.displayed(all);
    });
