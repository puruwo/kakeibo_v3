import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/register_page/fixed_cost_tab/payment_frequency_input_area/payment_frequency_picker.dart';
import 'package:kakeibo/view_model/state/register_page/payment_frequency_controller/payment_frequency_controller.dart';

// 支出登録ページにおける拠出元の入力部分

class PaymentFrequencyInputField extends ConsumerStatefulWidget {
  const PaymentFrequencyInputField(
      {super.key, required this.originalPaymentFrequency});
  final PaymentFrequencyValue originalPaymentFrequency;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PaymentFrequencyInputField();
}

class _PaymentFrequencyInputField
    extends ConsumerState<PaymentFrequencyInputField> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 拠出元予算カテゴリーの初期値をセット
      ref
          .read(paymentFrequencyControllerNotifierProvider.notifier)
          .setData(widget.originalPaymentFrequency);
    });
  }

  @override
  Widget build(BuildContext context) {
    // コントローラの初期化
    final paymentFrequency =
        ref.watch(paymentFrequencyControllerNotifierProvider);

    return AppInkWell(
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) {
              return PaymentFrequencyPicker(
                  originalPaymentFrequency: paymentFrequency);
            });
      },
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // プレースホルダー
            Text(
              "支払い頻度",
              textAlign: TextAlign.left,
              style: MyFonts.placeHolder,
            ),

            // 選択状態
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 拠出元選択状態
                Text(
                  paymentFrequency.dateLabel,
                  textAlign: TextAlign.right,
                  style: MyFonts.inputText,
                ),
                // テキストとアイコンの間のスペース
                const SizedBox(width: 4),
                // 矢印アイコン
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
    );
  }
}
