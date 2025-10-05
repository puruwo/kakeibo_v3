import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/domain/core/category_accounting_entity/category_accounting_entity.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/small_category_tile_entity/small_category_tile_entity.dart';
import 'package:kakeibo/model/assets_conecter/category_handler.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/category_card_value/category_card_entity.dart';

class CategorySumText extends HookConsumerWidget {
  const CategorySumText({required this.categoryTile, super.key});
  final CategoryCardEntity categoryTile;

  int get budget => categoryTile.monthlyBudget;
  CategoryAccountingEntity get monthlyExpenseByCategoryEntity =>
      categoryTile.monthlyExpenseByCategoryEntity;
  List<SmallCategoryTileEntity> get smallCategoryEntity =>
      categoryTile.smallCategoryList;

  final double barFrameWidth = 280.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 支出合計のLabel
    final String paymentSumLabel = formattedPriceGetter(
        monthlyExpenseByCategoryEntity.totalExpenseByBigCategory);

    // 予算のLabel
    final String budgetLabel = formattedPriceGetter(budget);

    return // バー下ラベル
        Container(
      width: barFrameWidth * context.screenHorizontalMagnification,
      // 最小の制約を設定することで子widgetのRowが最大まで拡大する
      constraints: BoxConstraints(
        minWidth: barFrameWidth * context.screenHorizontalMagnification,
        minHeight: 30,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Expanded(
            child: Text(
              monthlyExpenseByCategoryEntity.bigCategoryName,
              style: GoogleFonts.notoSans(
                fontSize: 16,
                color: MyColors.white,
                fontWeight: FontWeight.w300,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // カテゴリー総支出
              Text(
                paymentSumLabel,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSans(
                    fontSize: 18,
                    color: MyColors.white,
                    fontWeight: FontWeight.w400),
                textAlign: TextAlign.end,
              ),
              Text(
                ' 円',
                style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: MyColors.white,
                    fontWeight: FontWeight.w400),
              ),
              Text(
                ' /',
                style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: MyColors.secondaryLabel,
                    fontWeight: FontWeight.w400),
              ),
              Text(
                '予算 ',
                style: GoogleFonts.notoSans(
                    fontSize: 13,
                    color: MyColors.secondaryLabel,
                    fontWeight: FontWeight.w400),
              ),
              // カテゴリー予算
              Text(
                budgetLabel,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSans(
                    fontSize: 14,
                    color: MyColors.secondaryLabel,
                    fontWeight: FontWeight.w400),
                textAlign: TextAlign.end,
              ),
              Padding(
                // 円の右のスペース
                padding: const EdgeInsets.only(right: 2.0),
                child: Text(
                  ' 円',
                  style: GoogleFonts.notoSans(
                    fontSize: 11,
                    color: MyColors.secondaryLabel,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          )
        ],
      ),
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
