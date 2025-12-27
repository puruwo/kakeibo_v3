import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/view/register_page/common_input_field/price_input_row/large_price_display.dart';
import 'package:kakeibo/view/register_page/common_input_field/transaction_type_pill.dart';
import 'package:kakeibo/view_model/state/input_mode_controller.dart';

/// 支出/収入ピル + 大きな金額入力を1行に表示するウィジェット
class PriceInputRow extends ConsumerWidget {
  const PriceInputRow({
    super.key,
    required this.originalPrice,
  });

  final int originalPrice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // providerからモードを監視
    final currentMode = ref.watch(inputModeControllerProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 支出/収入切替ピル
        TransactionTypePill(
          currentMode: currentMode,
          onModeChanged: (mode) {
            // providerを更新
            ref.read(inputModeControllerProvider.notifier).updateState(mode);
          },
        ),
        const Spacer(),
        // 大きな金額表示
        Expanded(
          flex: 2,
          child: LargePriceDisplay(
            originalPrice: originalPrice,
          ),
        ),
      ],
    );
  }
}
