import 'package:flutter/material.dart';
import 'package:kakeibo/constant/font_style.dart';
import 'package:kakeibo/theme/app_colors.dart';

class UnconfirmedFixedCostChipLabel extends StatelessWidget {
  const UnconfirmedFixedCostChipLabel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
          color: context.colors.primarySubtle,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: context.colors.primary)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.show_chart,
            size: 12,
            color: context.colors.primary,
          ),
          const SizedBox(width: 2),
          Text(
            '変動あり',
            style: MyFontStyle.notoSans.copyWith(
              fontSize: 10,
              color: context.colors.primary,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
