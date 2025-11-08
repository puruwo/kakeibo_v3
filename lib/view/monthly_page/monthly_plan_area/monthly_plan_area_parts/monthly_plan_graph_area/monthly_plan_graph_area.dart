import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/all_category_card_value/all_category_card_entity.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_area_parts/monthly_plan_graph_area/monthly_plan_graph_parts.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_all_category_tile_entity_provider.dart';

class MnothlyPlanGraphArea extends HookConsumerWidget {
  const MnothlyPlanGraphArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedAllCategoryCardModelProvider).when(
          data: (allCategoryCardEntity) {
            return allCategoryCardEntity.cardStatusType !=
                    AllCategoryCardStatusType.noData
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                    child: LayoutBuilder(
                      builder: (context, constraints) => MnothlyPlanGraph(
                          maxGraphWidth: constraints.maxWidth,
                          allCategoryCardEntity: allCategoryCardEntity),
                    ),
                  )
                : Container();
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('$error')),
        );
  }
}
