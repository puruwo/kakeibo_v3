import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/application/yearly_income_list/yearly_income_list_usecase.dart';
import 'package:kakeibo/domain/core/date_scope_entity/date_scope_entity.dart';
import 'package:kakeibo/view/yearly_income_list_page/yearly_income_card.dart';

class YearlyIncomeListArea extends ConsumerStatefulWidget {
  const YearlyIncomeListArea({super.key, required this.dateScope});

  final DateScopeEntity dateScope;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _YearlyIncomeListAreaState();
}

class _YearlyIncomeListAreaState extends ConsumerState<YearlyIncomeListArea> {
  @override
  Widget build(BuildContext context) {
    return ref.watch(yearlyIncomeListNotifierProvider(widget.dateScope)).when(
          data: (incomeList) {
            if (incomeList.monthlyGroups.isEmpty) {
              return Center(
                child: Text(
                  '収入が登録されていません',
                  style: YearlyIncomeListStyles.noDataMessage,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              itemCount: incomeList.monthlyGroups.length,
              itemBuilder: (context, groupIndex) {
                final group = incomeList.monthlyGroups[groupIndex];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 月のヘッダー
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 4, bottom: 8, top: 8),
                      child: Text(
                        group.monthLabel,
                        style: YearlyIncomeListStyles.listMonthHeader,
                      ),
                    ),
                    const Divider(
                      height: 0,
                      thickness: 1,
                    ),

                    const SizedBox(height: 8),
                    // 収入のリスト
                    ...group.incomes.map((income) {
                      return YearlyIncomeCard(value: income);
                    }).toList(),
                    const SizedBox(height: 8),
                  ],
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (error, stack) => Center(
            child: Text(
              'エラーが発生しました: $error',
              style: YearlyIncomeListStyles.errorMessage,
            ),
          ),
        );
  }
}
