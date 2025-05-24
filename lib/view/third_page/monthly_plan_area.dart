import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/view/budget_home_page/budget_home_page.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_monthly_plan_provider.dart';

class MonthlyPlanArea extends ConsumerWidget {
  const MonthlyPlanArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedMonthlyPlanValueProvider).when(
          data: (monthlyPlanValue) {
            return GestureDetector(
              child: Container(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                          child: Text(
                              '月の収入: ${monthlyPlanValue.monthlyIncome.toString()}')),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            child: Text(
                                '月の予算: ${monthlyPlanValue.monthlyBudget.toString()}'))),
                    Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            child: Text(
                                '予想貯金: ${monthlyPlanValue.expectedSavings.toString()}'))),
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
