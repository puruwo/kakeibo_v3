import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/view/monthly_page/tile/all_category_sum_tile.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_all_category_tile_entity_provider.dart';

class AllCategoryTileArea extends ConsumerWidget {
  const AllCategoryTileArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
   
    return ref.watch(resolvedAllCategoryTileEntityProvider)
                .when(
                  data: (allCategoryCardEntity) {
                    return AllCategorySumTile(
                        allCategoryTileEntity: allCategoryCardEntity);
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(child: Text('$error')),
                );
  }
}
