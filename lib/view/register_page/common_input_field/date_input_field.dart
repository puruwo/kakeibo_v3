import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view_model/state/register_page/input_date_controller/input_date_controller.dart';

class DateInputField extends ConsumerStatefulWidget {
  const DateInputField(
      {super.key, required this.originalDate, this.titleLabel = "日付"});
  final String originalDate;
  final String titleLabel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends ConsumerState<DateInputField> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inputDateControllerNotifierProvider.notifier).setData(DateTime.parse(
          '${widget.originalDate.substring(0, 4)}-${widget.originalDate.substring(4, 6)}-${widget.originalDate.substring(6, 8)}'));
    });
  }

  @override
  Widget build(BuildContext context) {
    // 入力された日付を監視
    final enteredDate = ref.watch(inputDateControllerNotifierProvider);

    return AppInkWell(
      color: MyColors.secondarySystemfill,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 5),
        child: SizedBox(
          height: 34,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.titleLabel,
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
    );
  }
}
