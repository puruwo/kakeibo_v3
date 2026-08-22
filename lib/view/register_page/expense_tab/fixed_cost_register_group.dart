import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view/register_page/common_input_field/payment_frequency_picker.dart';
import 'package:kakeibo/view_model/state/register_page/entered_memo_controller.dart';
import 'package:kakeibo/view_model/state/register_page/fixed_cost_input_controller/fixed_cost_input_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_date_controller/input_date_controller.dart';
import 'package:kakeibo/view_model/state/register_page/payment_frequency_controller/payment_frequency_controller.dart';

/// 登録・編集シートの「固定費」グループ
///
/// トグルOFFのときは「固定費として登録」の1行だけ。ONにすると
/// 名称／初回支払日／頻度／支払い額が毎回変わる の4行が展開する（仕様 §6.1・§6.6）。
class FixedCostRegisterGroup extends ConsumerWidget {
  const FixedCostRegisterGroup({super.key, this.note});

  /// グループの下に添える補足文（通常支出の編集では固定費化の説明を出す）
  final String? note;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFixedCost =
        ref.watch(fixedCostRegisterToggleControllerNotifierProvider);
    final isVariable =
        ref.watch(fixedCostVariableSwitchControllerNotifierProvider);
    final enteredDate = ref.watch(inputDateControllerNotifierProvider);
    final paymentFrequency =
        ref.watch(paymentFrequencyControllerNotifierProvider);

    return AppInsetGroup(
      note: isFixedCost ? null : note,
      children: [
        // 固定費として登録
        AppInsetRow.switchRow(
          icon: Icons.autorenew_rounded,
          label: '固定費として登録',
          switchValue: isFixedCost,
          onSwitchChanged: (value) => _onToggleChanged(ref, value),
        ),

        if (isFixedCost) ...[
          // 名称（メモの値を引き継ぐ）
          AppInsetRow.textField(
            icon: Icons.drive_file_rename_outline_rounded,
            label: '名称',
            controller: ref.watch(enteredFixedCostNameControllerProvider),
            hintText: '未入力',
            maxLength: 20,
          ),

          // 初回支払日（日付の値を引き継ぐ）
          AppInsetRow.navigation(
            icon: Icons.calendar_today_outlined,
            label: '初回支払日',
            value: '${enteredDate.month}/${enteredDate.day}',
            onTap: () => _showDatePicker(context, ref, enteredDate),
          ),

          // 支払い頻度
          AppInsetRow.navigation(
            icon: Icons.repeat_rounded,
            label: '頻度',
            value: paymentFrequency.dateLabel,
            onTap: () async {
              await showDialog(
                context: context,
                builder: (context) {
                  return PaymentFrequencyPicker(
                    originalPaymentFrequency: paymentFrequency,
                  );
                },
              );
            },
          ),

          // 支払い額が毎回変わる（変動型）
          AppInsetRow.switchRow(
            icon: Icons.trending_up_rounded,
            label: '支払い額が毎回変わる',
            switchValue: isVariable,
            onSwitchChanged: (value) {
              ref
                  .read(
                    fixedCostVariableSwitchControllerNotifierProvider.notifier,
                  )
                  .setData(value);
            },
          ),
        ],
      ],
    );
  }

  /// トグル切替時に、入力済みのメモを固定費の名称へ引き継ぐ（仕様 §6.1）
  ///
  /// 名称に既に入力があるときは上書きしない。
  void _onToggleChanged(WidgetRef ref, bool value) {
    if (value) {
      final nameController = ref.read(enteredFixedCostNameControllerProvider);
      if (nameController.text.isEmpty) {
        nameController.text = ref.read(enteredMemoControllerProvider).text;
      }
    }
    ref
        .read(fixedCostRegisterToggleControllerNotifierProvider.notifier)
        .setData(value);
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
