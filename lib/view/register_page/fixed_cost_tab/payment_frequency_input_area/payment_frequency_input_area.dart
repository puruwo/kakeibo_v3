import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/view/register_page/fixed_cost_tab/payment_frequency_input_area/initial_payment_date_input_field.dart';
import 'package:kakeibo/view/register_page/fixed_cost_tab/payment_frequency_input_area/payment_frequency_input_field.dart';

class PaymentFrequencyInputArea extends ConsumerStatefulWidget {
  const PaymentFrequencyInputArea({super.key, required this.initialFixedData});

  final FixedCostEntity initialFixedData;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FixedCostPriceInputArea();
}

class _FixedCostPriceInputArea
    extends ConsumerState<PaymentFrequencyInputArea> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MyColors.secondarySystemfill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 支払い頻度入力
            PaymentFrequencyInputField(
              originalPaymentFrequency: PaymentFrequencyValue.fromDB(
                intervalNumber: widget.initialFixedData.intervalNumber,
                intervalUnitNumber: widget.initialFixedData.intervalUnit,
              ),
            ),

            // 区切り線
            const Divider(
              // ウィジェット自体の高さ
              height: 0,
              // 線の太さ
              thickness: 1,
              indent: 0,
              endIndent: 0,
              color: MyColors.separater,
            ),

            // 初回支払い日入力
            InitialPaymentDateInputField(
                originalDate: widget.initialFixedData.firstPaymentDate,
                titleLabel: "初回支払い日"),

            const SizedBox(
              height: 2,
            ),

            // 変動アリナシ トグル
          ],
        ),
      ),
    );
  }
}
