import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/category_card_entity.dart';
import 'package:kakeibo/util/util.dart';

class BudgetLabel extends StatelessWidget {
  const BudgetLabel({super.key, required this.categoryTile});

  final CategoryCardEntity categoryTile;

  int get budget => categoryTile.monthlyBudget;

  @override
  Widget build(BuildContext context) {
    final bool hasBudget =
        categoryTile.graphType == GraphType.hasBudget ||
        categoryTile.graphType == GraphType.hasBudgetButOver;

    return SizedBox(
      width: 100,
      child: hasBudget
          ? Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: RichText(
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '予算 ',
                        style: AppTextStyles.appCardTertiaryPriceUnit,
                      ),
                      TextSpan(
                        text: yenmarkFormattedPriceGetter(budget),
                        style: AppTextStyles.appCardTertiaryPriceLabel,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
