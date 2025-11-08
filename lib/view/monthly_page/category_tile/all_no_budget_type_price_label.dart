import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/category_card_entity.dart';
import 'package:kakeibo/util/util.dart';

class AllNoBudgetTypePriceLabel extends StatelessWidget {
  const AllNoBudgetTypePriceLabel({
    super.key,
    required this.gapBetweenGraphAndLabel,
    required this.width,
    required this.categoryTile,
  });

  int get budget => categoryTile.monthlyBudget;
  CategoryAccountingEntity get monthlyExpenseByCategoryEntity =>
      categoryTile.monthlyExpenseByCategoryEntity;

  final double gapBetweenGraphAndLabel;
  final double width;
  final CategoryCardEntity categoryTile;

  @override
  Widget build(BuildContext context) {
    // 支出合計のLabel
    final String paymentSumLabel = formattedPriceGetter(
        monthlyExpenseByCategoryEntity.totalExpenseByBigCategory);

    // 予算のLabel
    return Padding(
      padding: EdgeInsets.only(left: gapBetweenGraphAndLabel),
      child: SizedBox(
        width: width,
        child: RichText(
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(children: [
              TextSpan(
                text: paymentSumLabel,
                style: GoogleFonts.notoSans(
                    fontSize: 18,
                    color: MyColors.white,
                    fontWeight: FontWeight.w400),
              ),
              TextSpan(
                text: ' 円',
                style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: MyColors.white,
                    fontWeight: FontWeight.w400),
              ),
            ])),
      ),
    );
  }
}
