import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/db/fixed_cost/fixed_cost_entity.dart';
import 'package:kakeibo/view/register_page/common_input_field/price_input_field.dart';
import 'package:kakeibo/view/register_page/fixed_cost_tab/price_input_area/price_type_switch_area.dart';
import 'package:kakeibo/view_model/state/register_page/price_type_switch_controller/price_type_switch_controller.dart';

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

    return Container(
      decoration: BoxDecoration(
        color: MyColors.secondarySystemfill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 支払い金額入力
            PriceInputField(
              originalPrice: widget.initialFixedData.price,
              priceInputFieldStatus: priceInputFieldStatus,
              titleLabel: "支払い金額",
            ),

            const SizedBox(
              height: 8,
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

            const SizedBox(
              height: 2,
            ),

            // 変動アリナシ 選択エリア
            PriceTypeSwitchArea(
              originalState:
                  widget.initialFixedData.variable == 1 ? true : false,
            )
          ],
        ),
      ),
    );
  }
}
