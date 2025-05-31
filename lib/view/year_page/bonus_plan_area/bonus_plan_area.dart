import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/view/budget_home_page/budget_home_page.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_bonus_plan_provider.dart';

class BonusPlanArea extends ConsumerWidget {
  const BonusPlanArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedBonusPlanValueProvider).when(
          data: (bonusPlanValue) {
            return GestureDetector(
              child: Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          child: Text(
                              'ボーナス: ${bonusPlanValue.yearlyBonusExpense .toString()}')),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            child: Text(
                                '利用額: ${bonusPlanValue.yearlyBonusIncome.toString()}'))),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            child: Text(
                                'ボーナス残額: ${bonusPlanValue.lastBonusPrice.toString()}'))),
                  ],
                ),
              ),
              onTap: () {
                // 設定画面にrootのNavigatorで遷移
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BudgetHomePage(),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('$error')),
        );
  }
}
