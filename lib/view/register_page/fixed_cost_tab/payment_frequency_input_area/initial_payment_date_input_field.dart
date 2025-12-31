import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/register_page/common_input_field/const_getter.dart/const_input_page_size_getter.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view_model/state/register_page/input_date_controller/input_date_controller.dart';

/// 初回支払い日入力フィールド（ピル形式）
///
/// UIデザイン: [📅 初回   12/29]
class InitialPaymentDateInputField extends ConsumerStatefulWidget {
  const InitialPaymentDateInputField({
    super.key,
    required this.originalDate,
  });

  /// 初期日付（yyyyMMdd形式）
  final String originalDate;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _InitialPaymentDateInputFieldState();
}

class _InitialPaymentDateInputFieldState
    extends ConsumerState<InitialPaymentDateInputField> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(inputDateControllerNotifierProvider.notifier).setData(
            DateTime.parse(
              '${widget.originalDate.substring(0, 4)}-${widget.originalDate.substring(4, 6)}-${widget.originalDate.substring(6, 8)}',
            ),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final enteredDate = ref.watch(inputDateControllerNotifierProvider);

    return AppInkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () async {
        // 既存のカレンダーピッカーを表示
        final DateTime? picked = await showDatePicker(
          context: context,
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: enteredDate,
          firstDate: DateTime(2020),
          lastDate: DateTime(2040),
        );

        if (picked != null) {
          ref
              .read(inputDateControllerNotifierProvider.notifier)
              .setData(picked);
        }
      },
      child: Container(
        height: InputPageWidgetSize.pillHeight,
        width: InputPageWidgetSize.pillWidth,
        padding: const EdgeInsets.fromLTRB(16, 8, 20, 8),
        decoration: BoxDecoration(
          color: MyColors.secondarySystemfill,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: MyColors.label,
            ),
            const SizedBox(width: 8),
            Text(
              '初回',
              style: RegisterPageStyles.budgetLabel,
            ),
            const Spacer(),
            Text(
              '${enteredDate.month}/${enteredDate.day}',
              style: RegisterPageStyles.dateButton,
            ),
          ],
        ),
      ),
    );
  }
}
