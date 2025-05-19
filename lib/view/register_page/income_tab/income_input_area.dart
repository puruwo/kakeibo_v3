import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view/register_page/common_input_field/price_input_field.dart';

class IncomeInputArea extends ConsumerStatefulWidget {
  const IncomeInputArea({super.key,required this.originalPrice});

  final int originalPrice;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomeInputArea();
}

class _IncomeInputArea extends ConsumerState<IncomeInputArea> {

  @override
  Widget build(BuildContext context) {

    return Container(
      decoration: BoxDecoration(
        color: MyColors.secondarySystemfill,
        borderRadius: BorderRadius.circular(8),
      ),
      child:  Padding(
        padding:const EdgeInsets.fromLTRB(16, 0, 16, 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 購入金額入力
            PriceInputField(originalPrice: widget.originalPrice),
          ],
        ),
      ),
    );
  }
}
