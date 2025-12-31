import 'package:flutter/material.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';
import 'package:kakeibo/util/common_widget/checkable_popup_menu_item.dart';
import 'package:kakeibo/view/register_page/common_input_field/const_getter.dart/color_getter.dart';
import 'package:kakeibo/view/register_page/common_input_field/const_getter.dart/const_input_page_size_getter.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

/// 支出/収入を切り替えるピルボタン
///
/// 画像デザインの「● 支出 ▼」部分
class TransactionTypePill extends StatelessWidget {
  const TransactionTypePill({
    super.key,
    required this.mode,
    required this.currentMode,
    required this.onModeChanged,
  });

  final RegisterScreenMode mode;
  final TransactionMode currentMode;
  final ValueChanged<TransactionMode> onModeChanged;

  @override
  Widget build(BuildContext context) {
    final enabled = mode == RegisterScreenMode.add &&
        currentMode != TransactionMode.fixedCost;
    return AppPopupMenu<TransactionMode>(
      enabled: enabled,
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
        height: InputPageWidgetSize.pillHeight,
        width: InputPageWidgetSize.pillWidth,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: getPillBackgroundColor(currentMode),
          border: Border.all(color: getPillColor(currentMode)),
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
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
              style: RegisterPageStyles.pillLabel(getPillColor(currentMode)),
            ),
            const SizedBox(width: 6),
            // ドロップダウン矢印
            Visibility(
              visible: enabled,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: getPillColor(currentMode),
                size: 14,
              ),
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
