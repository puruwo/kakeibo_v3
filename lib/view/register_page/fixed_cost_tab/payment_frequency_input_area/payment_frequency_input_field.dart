import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/register_page/common_input_field/const_getter.dart/const_input_page_size_getter.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/register_page/fixed_cost_tab/payment_frequency_input_area/payment_frequency_picker.dart';
import 'package:kakeibo/view_model/state/register_page/payment_frequency_controller/payment_frequency_controller.dart';

/// 支払い頻度入力フィールド（ピル形式）
///
/// UIデザイン: [🔄 頻度   毎月]
class PaymentFrequencyInputField extends ConsumerStatefulWidget {
  const PaymentFrequencyInputField({
    super.key,
    required this.originalPaymentFrequency,
  });

  final PaymentFrequencyValue originalPaymentFrequency;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PaymentFrequencyInputFieldState();
}

class _PaymentFrequencyInputFieldState
    extends ConsumerState<PaymentFrequencyInputField> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(paymentFrequencyControllerNotifierProvider.notifier)
          .setData(widget.originalPaymentFrequency);
    });
  }

  @override
  Widget build(BuildContext context) {
    final paymentFrequency =
        ref.watch(paymentFrequencyControllerNotifierProvider);

    return AppInkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: () {
        // 既存のダイアログピッカーを表示
        showDialog(
          context: context,
          builder: (context) {
            return PaymentFrequencyPicker(
              originalPaymentFrequency: paymentFrequency,
            );
          },
        );
      },
      child: Container(
        height: InputPageWidgetSize.pillHeight,
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
              Icons.autorenew_rounded,
              size: 18,
              color: MyColors.label,
            ),
            const SizedBox(width: 8),
            const Text(
              '頻度',
              style: RegisterPageStyles.budgetLabel,
            ),
            const Spacer(),
            Text(
              paymentFrequency.dateLabel,
              style: RegisterPageStyles.budgetValue,
            ),
          ],
        ),
      ),
    );
  }
}
