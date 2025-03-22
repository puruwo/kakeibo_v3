import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/view/organism/third_page/category_sum_tile.dart';
import 'package:kakeibo/application/usecase/category_tile/category_tile_provider.dart';

class CategoryTileArea extends ConsumerWidget {
  const CategoryTileArea({Key? key}) : super(key: key);

  // カード間の間隔
  static const double cardSpacing = 8.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(categoryTileEntityProvider).when(
          data: (categoryTileEntities) {
            return Column(
              children: List.generate(
                categoryTileEntities.length,
                (index) => Padding(
                  // カード間の間隔
                  padding: const EdgeInsets.only(bottom:cardSpacing),
                  child: CategoryTile(categoryTile: categoryTileEntities[index]),
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('$error')),
        );
  }
}