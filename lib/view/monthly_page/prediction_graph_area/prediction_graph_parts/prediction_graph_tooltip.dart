import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/domain/ui_value/prediction_graph_value/daily_bar_data.dart';
import 'package:kakeibo/view/monthly_page/prediction_graph_area/prediction_graph_text_styles.dart';

/// ツールチップウィジェット
class GraphTooltip extends StatelessWidget {
  const GraphTooltip({
    super.key,
    required this.date,
    required this.cumulativeExpense,
    required this.totalFixedCostExpense,
    required this.categoryExpenses,
    required this.onClose,
  });

  final DateTime date;
  final int cumulativeExpense;
  final int totalFixedCostExpense;
  final List<CategoryExpense> categoryExpenses;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: IntrinsicWidth(
        child: Container(
          constraints: const BoxConstraints(minWidth: 140),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2E), // ダークグレー背景
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 日付と累計（同じ行）
              Row(
                children: [
                  Text(
                    '${date.month}/${date.day}',
                    style: PredictionGraphTextStyles.tooltipDate,
                  ),
                  const SizedBox(width: 8),
                  const Spacer(),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                          text: '累計 ',
                          style:
                              PredictionGraphTextStyles.tooltipCumulativeLabel,
                        ),
                        TextSpan(
                          text: '¥${_formatNumber(cumulativeExpense)}',
                          style: PredictionGraphTextStyles.tooltipSubtitle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // 固定費（0円の場合は非表示、小さく表示）
              if (totalFixedCostExpense > 0)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '(固定費 ¥${_formatNumber(totalFixedCostExpense)})',
                      style: PredictionGraphTextStyles.tooltipCumulativeLabel,
                    ),
                  ),
                ),
              if (categoryExpenses.isNotEmpty) ...[
                const SizedBox(height: 8),
                const Divider(height: 1, color: Colors.white24),
                const SizedBox(height: 8),
                // カテゴリー別支出（金額の降順でソート）
                ...(List<CategoryExpense>.from(categoryExpenses)
                      ..sort((a, b) => b.price.compareTo(a.price)))
                    .map((expense) => _buildCategoryRow(expense)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryRow(CategoryExpense expense) {
    // 色をパース
    final colorCode = expense.colorCode.replaceAll('#', '');
    int colorValue;
    try {
      colorValue = int.parse(colorCode, radix: 16);
    } catch (e) {
      colorValue = 0xFF888888;
    }
    if (colorCode.length == 6) {
      colorValue = 0xFF000000 | colorValue;
    }
    final color = Color(colorValue);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          // カテゴリーアイコン（カテゴリー色で表示）
          SizedBox(
            width: 16,
            height: 16,
            child: expense.iconPath.isNotEmpty
                ? SvgPicture.asset(
                    expense.iconPath,
                    width: 16,
                    height: 16,
                    colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                  )
                : Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
          const Spacer(),
          // 金額（右揃え）
          Text(
            '¥${_formatNumber(expense.price)}',
            style: PredictionGraphTextStyles.tooltipCategory,
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
