import 'package:flutter/material.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/util/common_widget/checkable_popup_menu_item.dart';
import 'package:kakeibo/view/register_page/common_input_field/color_getter.dart/color_getter.dart';

/// 支出/収入を切り替えるピルボタン
///
/// 画像デザインの「● 支出 ▼」部分
class TransactionTypePill extends StatelessWidget {
  const TransactionTypePill({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  final TransactionMode currentMode;
  final ValueChanged<TransactionMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    return AppPopupMenu<TransactionMode>(
      onSelected: onModeChanged,
      itemBuilder: (context) => [
        buildCheckableMenuItem(
          value: TransactionMode.expense,
          label: '支出',
          isSelected: currentMode == TransactionMode.expense,
        ),
        buildCheckableMenuItem(
          value: TransactionMode.income,
          label: '収入',
          isSelected: currentMode == TransactionMode.income,
        ),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: getPillBackgroundColor(currentMode),
          border: Border.all(color: getPillColor(currentMode)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ドットインジケーター
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: getPillColor(currentMode),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            // ラベル
            Text(
              _getLabel(currentMode),
              style: TextStyle(
                color: getPillColor(currentMode),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            // ドロップダウン矢印
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: getPillColor(currentMode),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  String _getLabel(TransactionMode mode) {
    return switch (mode) {
      TransactionMode.expense => '支出',
      TransactionMode.income => '収入',
      TransactionMode.fixedCost => '固定費',
    };
  }
}
