import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/view/monthly_page/category_tile/category_sum_tile.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_category_tile_entity_provider.dart';

class CategorySumTileList extends ConsumerWidget {
  const CategorySumTileList({Key? key}) : super(key: key);

  // カード間の間隔
  static const double cardSpacing = 8.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedAllCategoryTileEntityProvider).when(
          data: (categoryTileEntities) {
            return Column(
              children: List.generate(
                categoryTileEntities.length,
                (index) => Padding(
                  // カード間の間隔
                  padding: const EdgeInsets.only(bottom:cardSpacing),
                  child: CategorySumTile(categoryTile: categoryTileEntities[index]),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('$error')),
        );
  }
}