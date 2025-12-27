import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/view/register_page/common_input_field/price_input_row/large_price_display.dart';
import 'package:kakeibo/view/register_page/common_input_field/transaction_type_pill.dart';
import 'package:kakeibo/view_model/state/input_mode_controller.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

/// 支出/収入ピル + 大きな金額入力を1行に表示するウィジェット
class PriceInputRow extends ConsumerWidget {
  const PriceInputRow({
    super.key,
    required this.originalPrice,
    required this.mode,
    this.status = PriceInputFieldStatus.normal,
  });

  final int originalPrice;
  final RegisterScreenMode mode;
  final PriceInputFieldStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // providerからモードを監視
    final currentMode = ref.watch(inputModeControllerProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // 支出/収入切替ピル
        TransactionTypePill(
          mode: mode,
          currentMode: currentMode,
          onModeChanged: (mode) {
            // providerを更新
            ref.read(inputModeControllerProvider.notifier).updateState(mode);
          },
        ),

        const SizedBox(width: 16),

        // 大きな金額表示
        Expanded(
          child: LargePriceDisplay(
            originalPrice: originalPrice,
            status: status,
          ),
        ),
      ],
    );
  }
}
