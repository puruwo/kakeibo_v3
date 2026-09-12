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
/// 初期は全月閉じた状態（[initiallyExpandAll] で全月開いた状態にもできる）。
/// タップで明細タイルを開閉する。
class YearlyIncomeListArea extends ConsumerStatefulWidget {
  const YearlyIncomeListArea({
    super.key,
    required this.period,
    this.shrinkWrap = false,
    this.physics,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 16),
    this.initiallyExpandAll = false,
  });

  final PeriodValue period;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry padding;

  /// 初回表示で全月を開いた状態にするか。
  /// 単月（集計月）で開く月間分析からの遷移では true、年間タブからは false。
  final bool initiallyExpandAll;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _YearlyIncomeListAreaState();
}

class _YearlyIncomeListAreaState extends ConsumerState<YearlyIncomeListArea> {
  /// 開いている月のラベル集合。初期表示は全月閉じた状態
  final Set<String> _expandedLabels = {};

  /// [YearlyIncomeListArea.initiallyExpandAll] を初回のデータ到着時に1度だけ適用したか
  bool _initialExpandApplied = false;

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
                  style: context.textStyles.listEmptyMessage,
                ),
              );
            }

            final labels = {
              for (final g in incomeList.monthlyGroups) g.monthLabel,
            };

            // 初回のデータ到着時のみ全月を開く（以後の開閉はユーザー操作に任せる）
            if (widget.initiallyExpandAll && !_initialExpandApplied) {
              _initialExpandApplied = true;
              _expandedLabels.addAll(labels);
            }

            // 編集・削除の再集計で消えた月のラベルを掃除する
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
