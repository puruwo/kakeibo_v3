import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakeibo/constant/colors.dart';

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
          color: MyColors.themeThinColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: MyColors.themeColor)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.show_chart,
            size: 12,
            color: MyColors.themeColor,
          ),
          const SizedBox(width: 2),
          Text(
            '変動あり',
            style: GoogleFonts.notoSans(
              fontSize: 10,
              color: MyColors.themeColor,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
