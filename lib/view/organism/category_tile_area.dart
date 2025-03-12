import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/view/organism/category_sum_tile.dart';
import 'package:kakeibo/application/usecase/category_tile/category_tile_provider.dart';

class CategoryTileArea extends ConsumerWidget {
  const CategoryTileArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(categoryTileEntityProvider).when(
          data: (categoryTileEntities) {
            return ListView.builder(
              shrinkWrap: true,
              itemCount: categoryTileEntities.length,
              itemBuilder: (BuildContext context, int index) {
                return CategoryTile(
                    categoryTile: categoryTileEntities[index]);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('$error')),
        );
  }
}
