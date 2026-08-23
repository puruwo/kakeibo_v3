// カテゴリー別サマリーリスト
import 'package:flutter/material.dart';
import 'package:kakeibo/util/color_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_fixed_cost_value_provider.dart';

class MonthlyFixedCostBigCategorySummaryList extends ConsumerWidget {
  const MonthlyFixedCostBigCategorySummaryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedFixedCostBigCategorySummaryValueProvider).when(
          data: (categorySummaries) {
            if (categorySummaries.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(children: [
              // 区切り線
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white24,
                ),
              ),

              ...categorySummaries.map((summary) {
                // カテゴリーの色を取得
                final color = ColorCode.toColor(summary.colorCode);

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // アイコンとカテゴリー名
                      Row(
                        children: [
                          SvgPicture.asset(
                            summary.resourcePath,
                            colorFilter:
                                ColorFilter.mode(color, BlendMode.srcIn),
                            width: 24,
                            height: 24,
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Text(summary.categoryName,
                              style: AppTextStyles.listTilePrimaryTitle),
                        ],
                      ),
                      // 金額 or 未確定
                      summary.isAllConfirmed
                          ? Text(
                              yenmarkFormattedPriceGetter(summary.totalAmount),
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.appCardSecondaryPriceLabel,
                            )
                          : Text(
                              '未確定',
                              style: AppTextStyles.listTilePrimaryTitle,
                            ),
                    ],
                  ),
                );
              }).toList(),
            ]);
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => const SizedBox.shrink(),
        );
  }
}
