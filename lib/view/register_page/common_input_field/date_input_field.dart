import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/register_page/common_input_field/const_getter.dart/const_input_page_size_getter.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view_model/state/register_page/input_date_controller/input_date_controller.dart';
import 'package:kakeibo/view_model/state/register_page/input_initialized_controller.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

/// コンパクトな日付入力ボタン
///
/// 画像デザイン: [📅 2/29] ダークボタン形式
class DateInputField extends ConsumerStatefulWidget {
  const DateInputField({super.key, required this.originalDate});

  /// 初期日付（yyyyMMdd形式）
  final String originalDate;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DateInputFieldState();
}

class _DateInputFieldState extends ConsumerState<DateInputField> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 追加モードで既に初期化済みの場合は、入力値を保持するためスキップ
      final isInitialized = ref.read(inputInitializedControllerProvider);
      final mode = ref.read(registerScreenModeNotifierProvider);
      if (mode == RegisterScreenMode.add && isInitialized) {
        return;
      }
      ref
          .read(inputDateControllerNotifierProvider.notifier)
          .setData(
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
      onTap: () => _showDatePicker(context, enteredDate),
      child: Container(
        height: InputPageWidgetSize.pillHeight,
        width: InputPageWidgetSize.pillWidth,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              '${enteredDate.month}/${enteredDate.day}',
              style: RegisterPageStyles.inputText,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(
    BuildContext context,
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
