import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/model/assets_conecter/category_handler.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/category_card_entity.dart';

class CategorySumText extends HookConsumerWidget {
  const CategorySumText({required this.categoryTile, super.key});
  final CategoryCardEntity categoryTile;

  int get budget => categoryTile.monthlyBudget;
  CategoryAccountingEntity get monthlyExpenseByCategoryEntity =>
      categoryTile.monthlyExpenseByCategoryEntity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return // バー下ラベル
        Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 2.0),
          child: CategoryHandler().sisytIconGetterFromBigCategoryKey(
              monthlyExpenseByCategoryEntity.id,
              height: 25,
              width: 25),
        ),
        // カテゴリー名
        Text(
          monthlyExpenseByCategoryEntity.bigCategoryName,
          style: GoogleFonts.notoSans(
            fontSize: 16,
            color: MyColors.white,
            fontWeight: FontWeight.w300,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class MyClipper extends CustomClipper<Rect> {
  final double frameWidth;
  final double degrees;

  MyClipper({required this.frameWidth, required this.degrees});

  @override
  Rect getClip(Size size) {
    double maskWidth = frameWidth * (degrees - 1);
    return Rect.fromLTWH(0, 0, maskWidth, 10);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return false;
  }
}
