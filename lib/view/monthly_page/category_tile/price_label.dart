import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/category_card_entity.dart';
import 'package:kakeibo/util/util.dart';

class PriceLabel extends StatelessWidget {
  const PriceLabel({super.key, required this.categoryTile});

  CategoryAccountingEntity get monthlyExpenseByCategoryEntity =>
      categoryTile.monthlyExpenseByCategoryEntity;

  final CategoryCardEntity categoryTile;

  @override
  Widget build(BuildContext context) {
    // 支出合計のLabel
    final String paymentSumLabel = formattedPriceGetter(
      monthlyExpenseByCategoryEntity.totalExpenseByBigCategory,
    );

    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: RichText(
        textAlign: TextAlign.end,
        overflow: TextOverflow.ellipsis,
        text: TextSpan(
          children: [
            TextSpan(
              text: paymentSumLabel,
              style: AppTextStyles.appCardOptionalSecondaryPriceLabel,
            ),
            TextSpan(
              text: ' 円',
              style: AppTextStyles.appCardSecondaryPriceUnit,
            ),
          ],
        ),
      ),
    );
  }
}
