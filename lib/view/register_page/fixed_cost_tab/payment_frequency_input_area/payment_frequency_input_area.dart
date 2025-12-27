import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/domain/core/payment_frequency_value/payment_frequency_value.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/view/register_page/fixed_cost_tab/payment_frequency_input_area/initial_payment_date_input_field.dart';
import 'package:kakeibo/view/register_page/fixed_cost_tab/payment_frequency_input_area/payment_frequency_input_field.dart';

/// 支払い頻度と初回支払い日を横並びで表示するエリア
///
/// UIデザイン: [📅 初回 12/29] [🔄 頻度 毎月]
class PaymentFrequencyInputArea extends ConsumerWidget {
  const PaymentFrequencyInputArea({super.key, required this.initialFixedData});

  final FixedCostEntity initialFixedData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // 初回支払い日ピル
        Expanded(
          flex: 1,
          child: InitialPaymentDateInputField(
            originalDate: initialFixedData.firstPaymentDate,
          ),
        ),

        const SizedBox(width: 16),

        // 支払い頻度ピル
        Expanded(
          flex: 1,
          child: PaymentFrequencyInputField(
            originalPaymentFrequency: PaymentFrequencyValue.fromDB(
              intervalNumber: initialFixedData.intervalNumber,
              intervalUnitNumber: initialFixedData.intervalUnit,
            ),
          ),
        ),
      ],
    );
  }
}
