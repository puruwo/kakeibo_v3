import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/common_widget/checkable_popup_menu_item.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view/register_page/common_input_field/budget_row.dart';
import 'package:kakeibo/view_model/state/register_page/entered_income_source_controller/entered_income_source_controller.dart';
import 'package:kakeibo/view_model/state/register_page/entered_memo_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_date_controller/input_date_controller.dart';

/// 登録・編集シートの「基本」グループ（拠出元／日付／メモ）
///
/// 固定費トグルON時は拠出元のみに縮む（日付は初回支払日、メモは名称へ引き継ぐ。仕様 §6.1）。
/// 固定費行の編集では日付を出さない（マスタの支払日が正のため。仕様 §6.6）。
class ExpenseBasicGroup extends ConsumerWidget {
  const ExpenseBasicGroup({
    super.key,
    this.showDate = true,
    this.showMemo = true,
  });

  /// 日付行を表示するか
  final bool showDate;

  /// メモ行を表示するか
  final bool showMemo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSource =
        ref.watch(enteredIncomeSourceControllerNotifierProvider);
    final selectedEnum = IncomeSourceBigCategory.values.firstWhere(
      (e) => e.value == selectedSource,
      orElse: () => IncomeSourceBigCategory.living,
    );
    final enteredDate = ref.watch(inputDateControllerNotifierProvider);

    return AppInsetGroup(
      children: [
        // 拠出元（会計種別）
        AppPopupMenu<IncomeSourceBigCategory>(
          onSelected: (selected) {
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
                  selectedColor: context.colors.primary,
                ),
              )
              .toList(),
          child: AppInsetRow.display(
            icon: Icons.account_balance_wallet_outlined,
            label: '拠出元',
            value: selectedEnum.label,
          ),
        ),

        // 日付
        if (showDate)
          AppInsetRow.navigation(
            icon: Icons.calendar_today_outlined,
            label: '日付',
            value: '${enteredDate.month}/${enteredDate.day}',
            onTap: () => _showDatePicker(context, ref, enteredDate),
          ),

        // メモ
        if (showMemo)
          AppInsetRow.textField(
            icon: Icons.notes_rounded,
            label: 'メモ',
            controller: ref.watch(enteredMemoControllerProvider),
            hintText: '未入力',
            maxLength: 20,
          ),
      ],
    );
  }

  Future<void> _showDatePicker(
    BuildContext context,
    WidgetRef ref,
    DateTime currentDate,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2040),
    );

    if (picked != null) {
      ref.read(inputDateControllerNotifierProvider.notifier).setData(picked);
    }
  }
}
