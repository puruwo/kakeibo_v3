import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/view/organism/all_category_sum_tile.dart';
import 'package:kakeibo/application/usecase/all_category_tile/all_category_tile_provider.dart';

class AllCategoryTileArea extends ConsumerWidget {
  const AllCategoryTileArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef 
  ref) {
    return ref.watch(allCategoryTileEntityProvider).when(
          data: (allCategoryTileEntity) {
            return AllCategorySumTile(allCategoryTileEntity: allCategoryTileEntity);
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('$error')),
        );
  }
}
