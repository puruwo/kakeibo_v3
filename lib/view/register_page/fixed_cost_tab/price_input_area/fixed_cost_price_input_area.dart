import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/view/register_page/common_input_field/price_input_row/large_price_display.dart';
import 'package:kakeibo/view/register_page/common_input_field/price_input_row/price_input_row.dart';
import 'package:kakeibo/view/register_page/fixed_cost_tab/price_input_area/price_type_switch_area.dart';
import 'package:kakeibo/view_model/state/register_page/price_type_switch_controller/price_type_switch_controller.dart';
import 'package:kakeibo/view_model/state/register_page/register_screen_mode/register_screen_mode.dart';

class FixedCostPriceInputArea extends ConsumerStatefulWidget {
  const FixedCostPriceInputArea({super.key, required this.initialFixedData});

  final FixedCostEntity initialFixedData;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FixedCostPriceInputArea();
}

class _FixedCostPriceInputArea extends ConsumerState<FixedCostPriceInputArea> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // トグル状態の初期値をセット
      ref
          .read(priceTypeSwitchControllerNotifierProvider.notifier)
          .setData(widget.initialFixedData.variable == 1 ? true : false);
    });
  }

  @override
  Widget build(BuildContext context) {
    // トグルの状態を監視
    bool isOn = ref.watch(priceTypeSwitchControllerNotifierProvider);
    // トグルの状態から金額の入力フィールドの状態を決定
    final priceInputFieldStatus =
        isOn ? PriceInputFieldStatus.unconfirmed : PriceInputFieldStatus.normal;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PriceInputRow(
          originalPrice: widget.initialFixedData.price,
          mode: RegisterScreenMode.add,
          status: priceInputFieldStatus,
        ),

        const SizedBox(
          height: 6,
        ),

        // 変動アリナシ 選択エリア
        PriceTypeSwitchArea(
          originalState: widget.initialFixedData.variable == 1 ? true : false,
        )
      ],
    );
  }
}
