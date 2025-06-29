import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_monthly_plan_provider.dart';

class MonthlyPlanDataArea extends ConsumerWidget {
  const MonthlyPlanDataArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedMonthlyPlanValueProvider).when(
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
                            Text(
                              ///月の総支出
                              formattedPriceGetter(
                                  monthlyPlanValue.monthlyExpense),
                              style: MyFonts.topCardPriceLabel,
                            ),
                            Text(
                              ' 円',
                              style: MyFonts.topCardYenLabel,
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
                            // 予算
                            Text(
                              formattedPriceGetter(
                                  monthlyPlanValue.monthlyBudget),
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
                                monthlyPlanValue.monthlyIncome),
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
                            formattedPriceGetter(
                                monthlyPlanValue.realSavings),
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
