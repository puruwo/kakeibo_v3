import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/application/yearly_income_list/yearly_income_list_usecase.dart';
import 'package:kakeibo/domain/core/month_period_value/month_period_value.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/month_accordion_section.dart';
import 'package:kakeibo/view/yearly_income_list_page/yearly_income_card.dart';

/// 収入一覧の月別アコーディオンリスト（追加改修 0828）
///
/// 支出カテゴリー明細と同じ月ヘッダー語彙（月・件数・月計）で表示し、
/// 初期は全月閉じた状態。タップで明細タイルを開閉する。
class YearlyIncomeListArea extends ConsumerStatefulWidget {
  const YearlyIncomeListArea({
    super.key,
    required this.period,
    this.shrinkWrap = false,
    this.physics,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 16),
  });

  final PeriodValue period;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _YearlyIncomeListAreaState();
}

class _YearlyIncomeListAreaState extends ConsumerState<YearlyIncomeListArea> {
  /// 開いている月のラベル集合。初期表示は全月閉じた状態
  final Set<String> _expandedLabels = {};

  @override
  Widget build(BuildContext context) {
    return ref
        .watch(yearlyIncomeListNotifierProvider(widget.period))
        .when(
          data: (incomeList) {
            if (incomeList.monthlyGroups.isEmpty) {
              return Center(
                child: Text(
                  '収入が登録されていません',
                  style: AppTextStyles.listEmptyMessage,
                ),
              );
            }

            // 編集・削除の再集計で消えた月のラベルを掃除する
            final labels = {
              for (final g in incomeList.monthlyGroups) g.monthLabel,
            };
            _expandedLabels.removeWhere((label) => !labels.contains(label));

            return ListView.builder(
              padding: widget.padding,
              shrinkWrap: widget.shrinkWrap,
              physics: widget.physics,
              itemCount: incomeList.monthlyGroups.length,
              itemBuilder: (context, groupIndex) {
                final group = incomeList.monthlyGroups[groupIndex];
                final monthTotal = group.incomes.fold<int>(
                  0,
                  (sum, income) => sum + income.price,
                );

                return MonthAccordionSection(
                  label: group.monthLabel,
                  itemCount: group.incomes.length,
                  totalLabel: yenmarkFormattedPriceGetter(monthTotal),
                  isExpanded: _expandedLabels.contains(group.monthLabel),
                  onToggle: () {
                    setState(() {
                      if (!_expandedLabels.remove(group.monthLabel)) {
                        _expandedLabels.add(group.monthLabel);
                      }
                    });
                  },
                  children: [
                    for (final income in group.incomes)
                      YearlyIncomeCard(value: income),
                  ],
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => const AppErrorState(),
        );
  }
}
