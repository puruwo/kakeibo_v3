import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
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
    // 入力された日付を監視
    final enteredDate = ref.watch(inputDateControllerNotifierProvider);

    return GestureDetector(
      child: Container(
        decoration: const BoxDecoration(
          color: MyColors.secondarySystemfill,
          borderRadius: BorderRadius.all(
            Radius.circular(8),
          ),
        ),
        height: 44,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "日付",
                textAlign: TextAlign.left,
                style: MyFonts.placeHolder,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: Text(
                      '${enteredDate.year}年${enteredDate.month}月${enteredDate.day}日',
                      textAlign: TextAlign.right,
                      style: MyFonts.inputText,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: MyColors.secondaryLabel,
                  )
                ],
              ),
            ],
          ),
        ),
      ),
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
    );
  }
}
