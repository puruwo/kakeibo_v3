import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view_model/state/register_page/entered_memo_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_date_controller/input_date_controller.dart';

/// 収入の登録・編集シートの「基本」グループ（日付／メモ）
///
/// 支出タブの ExpenseBasicGroup と同じインセットグループに揃える（仕様 §6.9）。
/// 収入には拠出元が無いため、行は日付・メモの2行のみ。
class IncomeBasicGroup extends ConsumerWidget {
  const IncomeBasicGroup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enteredDate = ref.watch(inputDateControllerNotifierProvider);

    return AppInsetGroup(
      children: [
        // 日付
        AppInsetRow.navigation(
          icon: Icons.calendar_today_outlined,
          label: '日付',
          value: '${enteredDate.month}/${enteredDate.day}',
          onTap: () => _showDatePicker(context, ref, enteredDate),
        ),

        // メモ
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
