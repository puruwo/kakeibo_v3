import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/category_card_entity.dart';
import 'package:kakeibo/util/util.dart';

class PriceLabel extends StatelessWidget {
  const PriceLabel({
    super.key,
    required this.categoryTile,
  });

  int get budget => categoryTile.monthlyBudget;
  CategoryAccountingEntity get monthlyExpenseByCategoryEntity =>
      categoryTile.monthlyExpenseByCategoryEntity;

  final CategoryCardEntity categoryTile;

  @override
  Widget build(BuildContext context) {
    // 支出合計のLabel
    final String paymentSumLabel = formattedPriceGetter(
        monthlyExpenseByCategoryEntity.totalExpenseByBigCategory);

    // 予算のLabel
    final String budgetLabel = formattedPriceGetter(budget);
    return Padding(
      padding: const EdgeInsets.only(left:12.0),
      child: SizedBox(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // カテゴリー総支出
            RichText(
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
        
            // 予算
            categoryTile.graphType == GraphType.hasBudget ||
                    categoryTile.graphType == GraphType.hasBudgetButOver
                ? Flexible(
                    child: RichText(
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(children: [
                          TextSpan(
                            text: ' /',
                            style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: MyColors.secondaryLabel,
                                fontWeight: FontWeight.w400),
                          ),
                          TextSpan(
                            text: '予算 ',
                            style: GoogleFonts.notoSans(
                                fontSize: 13,
                                color: MyColors.secondaryLabel,
                                fontWeight: FontWeight.w400),
                          ),
                          // カテゴリー予算
                          TextSpan(
                            text: budgetLabel,
                            style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: MyColors.secondaryLabel,
                                fontWeight: FontWeight.w400),
                          ),
                          TextSpan(
                            text: ' 円',
                            style: GoogleFonts.notoSans(
                              fontSize: 11,
                              color: MyColors.secondaryLabel,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ])),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
