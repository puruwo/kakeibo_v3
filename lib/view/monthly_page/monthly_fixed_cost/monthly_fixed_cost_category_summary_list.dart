// カテゴリー別サマリーリスト
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_fixed_cost_value_provider.dart';

class MonthlyFixedCostCategorySummaryList extends ConsumerWidget {
  const MonthlyFixedCostCategorySummaryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(resolvedFixedCostCategorySummaryValueProvider).when(
          data: (categorySummaries) {
            if (categorySummaries.isEmpty) {
              return const SizedBox.shrink();
            }

            return Column(children: [
              // 区切り線
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.white24,
                ),
              ),

              ...categorySummaries.map((summary) {
                // カテゴリーの色を取得
                final color = MyColors().getColorFromHex(summary.colorCode);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
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
                          const SizedBox(width: 12),
                          Text(
                            summary.categoryName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      // 金額 or 未確定
                      Text(
                        summary.isAllConfirmed
                            ? '${formattedPriceGetter(summary.totalAmount)} 円'
                            : '未確定',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
