import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/sqf_constants.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/checkable_popup_menu_item.dart';
import 'package:kakeibo/view/component/app_pill_container.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view_model/state/register_page/entered_income_source_controller/entered_income_source_controller.dart';

/// 予算行（「予算」ラベルと拠出元選択）
///
/// 画像デザインの「📊 予算 | 給料 ▼」部分
class BudgetRow extends ConsumerStatefulWidget {
  const BudgetRow({super.key, required this.originalIncomeSourceBigCategory});

  final int originalIncomeSourceBigCategory;

  @override
  ConsumerState<BudgetRow> createState() => _BudgetRowState();
}

enum IncomeSourceBigCategory {
  living('生活収支', IncomeBigCategoryConstants.incomeSourceIdSalary),
  bonus('ボーナス', IncomeBigCategoryConstants.incomeSourceIdBonus);

  const IncomeSourceBigCategory(this.label, this.value);

  final String label;
  final int value;
}

class _BudgetRowState extends ConsumerState<BudgetRow> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(enteredIncomeSourceControllerNotifierProvider.notifier)
          .setData(widget.originalIncomeSourceBigCategory);
    });
  }

  /// 選択されたvalueからenumを取得
  IncomeSourceBigCategory _getEnumByValue(int value) {
    return IncomeSourceBigCategory.values.firstWhere(
      (e) => e.value == value,
      orElse: () => IncomeSourceBigCategory.living,
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedValue = ref.watch(
      enteredIncomeSourceControllerNotifierProvider,
    );
    final selectedEnum = _getEnumByValue(selectedValue);

    return AppPopupMenu(
      onSelected: (IncomeSourceBigCategory selected) {
        ref
            .read(enteredIncomeSourceControllerNotifierProvider.notifier)
            .setData(selected.value);
      },
      itemBuilder: (context) => IncomeSourceBigCategory.values
          .map(
            (category) => buildCheckableMenuItem(
              value: category,
              label: category.label,
              isSelected: selectedEnum == category,
            ),
          )
          .toList(),
      child: AppPillContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 18,
                  color: context.colors.text,
                ),
                const SizedBox(width: 8),
                Text('予算', style: RegisterPageStyles.placeHolder),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(selectedEnum.label, style: RegisterPageStyles.inputText),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: context.colors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
