import 'package:flutter/material.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_selection/category_selection_types.dart';

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
    return PopupMenuButton<TransactionMode>(
      offset: const Offset(0, 40),
      color: MyColors.tertiarySystemBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      onSelected: onModeChanged,
      itemBuilder: (context) => [
        _buildMenuItem(TransactionMode.expense, '支出'),
        _buildMenuItem(TransactionMode.income, '収入'),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _getPillColor(currentMode),
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
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            // ラベル
            Text(
              _getLabel(currentMode),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            // ドロップダウン矢印
            const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<TransactionMode> _buildMenuItem(
      TransactionMode mode, String label) {
    return PopupMenuItem<TransactionMode>(
      value: mode,
      child: Row(
        children: [
          if (currentMode == mode)
            Icon(Icons.check, color: MyColors.themeColor, size: 20)
          else
            const SizedBox(width: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: MyColors.white,
              fontWeight:
                  currentMode == mode ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPillColor(TransactionMode mode) {
    return switch (mode) {
      TransactionMode.expense => MyColors.themeColor,
      TransactionMode.income => Colors.green,
      TransactionMode.fixedCost => Colors.blue,
    };
  }

  String _getLabel(TransactionMode mode) {
    return switch (mode) {
      TransactionMode.expense => '支出',
      TransactionMode.income => '収入',
      TransactionMode.fixedCost => '固定費',
    };
  }
}
