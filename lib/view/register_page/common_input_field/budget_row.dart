import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/common_widget/checkable_popup_menu_item.dart';
import 'package:kakeibo/view/register_page/common_input_field/const_getter.dart/const_input_page_size_getter.dart';
import 'package:kakeibo/view/register_page/common_input_field/const_getter.dart/register_page_styles.dart';
import 'package:kakeibo/view_model/state/register_page/entered_income_source_controller/entered_income_source_controller.dart';

/// 予算行（「予算」ラベルと拠出元選択）
///
/// 画像デザインの「📊 予算 | 給料 ▼」部分
class BudgetRow extends ConsumerStatefulWidget {
  const BudgetRow({
    super.key,
    required this.originalIncomeSourceBigCategory,
  });

  final int originalIncomeSourceBigCategory;

  @override
  ConsumerState<BudgetRow> createState() => _BudgetRowState();
}

class _BudgetRowState extends ConsumerState<BudgetRow> {
  // 拠出元のラベルリスト
  static const incomeSourceLabels = [
    '生活収支',
    'ボーナス',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(enteredIncomeSourceControllerNotifierProvider.notifier)
          .setData(widget.originalIncomeSourceBigCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex =
        ref.watch(enteredIncomeSourceControllerNotifierProvider);
    final selectedLabel = selectedIndex < incomeSourceLabels.length
        ? incomeSourceLabels[selectedIndex]
        : incomeSourceLabels[0];

    return AppPopupMenu(
      onSelected: (index) {
        ref
            .read(enteredIncomeSourceControllerNotifierProvider.notifier)
            .setData(index);
      },
      itemBuilder: (context) => incomeSourceLabels
          .asMap()
          .entries
          .map(
            (entry) => buildCheckableMenuItem(
              value: entry.key,
              label: entry.value,
              isSelected: selectedIndex == entry.key,
            ),
          )
          .toList(),
      child: Container(
        height: InputPageWidgetSize.pillHeight,
        decoration: BoxDecoration(
          color: MyColors.secondarySystemfill,
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18,
                  color: MyColors.label,
                ),
                SizedBox(width: 8),
                Text(
                  '予算',
                  style: RegisterPageStyles.budgetLabel,
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedLabel,
                  style: RegisterPageStyles.budgetValue,
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: MyColors.secondaryLabel,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
