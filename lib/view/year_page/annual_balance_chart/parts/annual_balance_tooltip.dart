import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/styles/graph_text_styles.dart';
import 'package:kakeibo/domain/ui_value/annual_balance_chart_value/monthly_balance_value/monthly_balance_value.dart';

/// 生活収支グラフのツールチップ。
/// 月/収入/支出/収支を表示し、本体タップで analyze タブへ遷移する。
class AnnualBalanceTooltip extends StatelessWidget {
  const AnnualBalanceTooltip({
    super.key,
    required this.value,
    required this.onTap,
  });

  final MonthlyBalanceValue value;
  final VoidCallback onTap;

  static final NumberFormat _numberFormat = NumberFormat('#,###');

  @override
  Widget build(BuildContext context) {
    final isSurplus = value.savings >= 0;
    final savingsColor = isSurplus ? MyColors.incomeEmerald : MyColors.pink;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minWidth: 140),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${value.month}月', style: GraphTextStyles.tooltipDate),
            const SizedBox(height: 6),
            const Divider(height: 1, color: Colors.white24),
            const SizedBox(height: 6),
            _row(label: '収入', amount: value.monthlyIncome, color: MyColors.incomeEmerald),
            const SizedBox(height: 2),
            _row(label: '支出', amount: value.monthlyExpense, color: MyColors.pink),
            const SizedBox(height: 2),
            _row(label: '収支', amount: value.savings, color: savingsColor),
          ],
        ),
      ),
    );
  }

  Widget _row({required String label, required int amount, required Color color}) {
    return Row(
      children: [
        Text(label, style: GraphTextStyles.tooltipCumulativeLabel),
        const Spacer(),
        Text(
          '¥${_numberFormat.format(amount)}',
          style: GraphTextStyles.tooltipSubtitle.copyWith(color: color),
        ),
      ],
    );
  }
}
