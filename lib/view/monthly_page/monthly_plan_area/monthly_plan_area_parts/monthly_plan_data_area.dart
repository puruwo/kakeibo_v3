import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/category_card_value/all_category_card_value/all_category_card_entity.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_all_category_tile_entity_provider.dart';

class MonthlyPlanDataArea extends ConsumerWidget {
  const MonthlyPlanDataArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedAllCategoryCardModelProvider).when(
          data: (monthlyPlanValue) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 6.0, 16.0, 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '全体支出',
                          style: MyFonts.topCardTitleLabel,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            RichText(
                              ///月の総支出
                              text: TextSpan(
                                  text: formattedPriceGetter(
                                      monthlyPlanValue.allCategoryTotalExpense),
                                  style: MyFonts.topCardPriceLabel,
                                  children: [
                                    TextSpan(
                                      text: ' 円',
                                      style: MyFonts.topCardYenLabel,
                                    ),
                                  ]),
                            ),
                            monthlyPlanValue.cardStatusType !=
                                    AllCategoryCardStatusType.noData
                                ? RichText(
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.end,
                                    text: TextSpan(
                                        text: ' /',
                                        style: GoogleFonts.notoSans(
                                            fontSize: 14,
                                            color: MyColors.secondaryLabel,
                                            fontWeight: FontWeight.w400),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: monthlyPlanValue
                                                        .cardStatusType ==
                                                    AllCategoryCardStatusType
                                                        .hasBudget
                                                ? '予算 '
                                                : '収入 ',
                                            style: GoogleFonts.notoSans(
                                                fontSize: 13,
                                                color: MyColors.secondaryLabel,
                                                fontWeight: FontWeight.w400),
                                          ),
                                          // 予算
                                          TextSpan(
                                            text: formattedPriceGetter(
                                                monthlyPlanValue.denominator),
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
                                        ]),
                                  )
                                : Container(),
                          ],
                        ),
                      ]),
                  const SizedBox(
                    height: 8.0,
                  ),
                  const Divider(
                    thickness: 1.0,
                    height: 0.0,
                    color: MyColors.separater,
                  ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '月次収入',
                        style: MyFonts.topCardTitleLabel,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            formattedPriceGetter(
                                monthlyPlanValue.allCategoryTotalIncome),
                            style: MyFonts.topCardPriceLabel,
                          ),
                          Text(
                            ' 円',
                            style: MyFonts.topCardYenLabel,
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '残り現金',
                        style: MyFonts.topCardTitleLabel,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            formattedPriceGetter(monthlyPlanValue.realSavings),
                            style: MyFonts.topCardPriceLabel,
                          ),
                          Text(
                            ' 円',
                            style: MyFonts.topCardYenLabel,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('$error')),
        );
  }
}
