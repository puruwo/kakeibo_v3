import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view_model/state/register_page/input_date_controller/input_date_controller.dart';
import 'package:kakeibo/view_model/state/register_page/original_expense_entity/original_expense_entity.dart';

class DateInputField extends ConsumerStatefulWidget {
  const DateInputField({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends ConsumerState<DateInputField> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final originalExpenseEntity =
          ref.read(originalExpenseEntityNotifierProvider);
      ref.read(inputDateControllerNotifierProvider.notifier).setData(DateTime.parse(
          '${originalExpenseEntity.date.substring(0, 4)}-${originalExpenseEntity.date.substring(4, 6)}-${originalExpenseEntity.date.substring(6, 8)}'));
    });
  }

  @override
  Widget build(BuildContext context) {
    // 画面の倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final screenHorizontalMagnification = context.screenHorizontalMagnification;

    // 入力された日付を監視
    final enteredDate = ref.watch(inputDateControllerNotifierProvider);

    return GestureDetector(
      onTap: () async {
        //カレンダーピッカーで日付を選択し取得
        final DateTime? picked = await showDatePicker(
          context: context,
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: enteredDate, // 最初に表示する日付
          firstDate: DateTime(2020), // 選択できる日付の最小値
          lastDate: DateTime(2040), // 選択できる日付の最大値
        );

        //notifierを取得
        final notifier = ref.read(inputDateControllerNotifierProvider.notifier);
        //nullじゃなければcontrollerを更新
        if (picked != null) notifier.setData(picked);
      },
      child: Container(
        decoration: const BoxDecoration(
          color: MyColors.secondarySystemfill,
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        width: 343 * screenHorizontalMagnification,
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Text(
                '${enteredDate.year}年${enteredDate.month}月${enteredDate.day}日',
                textAlign: TextAlign.right,
                style: const TextStyle(color: MyColors.white, fontSize: 17),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 16.0),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: MyColors.secondaryLabel,
              ),
            )
          ],
        ),
      ),
    );
  }
}
