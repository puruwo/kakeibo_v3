import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/app_inset_group.dart';
import 'package:kakeibo/view/year_page/bonus_plan_area/bonus_plan_bar_graph.dart';
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_bonus_plan_provider.dart';

/// 特別枠ページ用のサマリー（案件 UIデザイン改修 §4）
///
/// 役割は「内訳と進捗の詳細」。収入／利用額／残額の3分割カード（角丸14）と
/// バーのカードの2枚組。トップ用（BonusPlanArea＝残額ヒーロー）とは役割で分ける。
class BonusPlanDetailSummary extends ConsumerWidget {
  const BonusPlanDetailSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(resolvedBonusPlanValueProvider)
        .when(
          data: (value) {
            final usagePercent = _usagePercent(
              income: value.yearlyBonusIncome,
              expense: value.yearlyBonusExpense,
            );

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 3分割カード（収入／利用額／残額）
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colors.fillQuaternary,
                    border: Border.all(color: context.colors.surfaceBorder),
                    borderRadius: appInsetGroupRadius,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        _SummaryCell(
                          label: '収入',
                          price: value.yearlyBonusIncome,
                        ),
                        _cellDivider(context),
                        _SummaryCell(
                          label: '利用額',
                          price: value.yearlyBonusExpense,
                        ),
                        _cellDivider(context),
                        _SummaryCell(
                          label: '残額',
                          price: value.lastBonusPrice,
                          priceColor: context.colors.primary,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                // バーのカード
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colors.fillQuaternary,
                    border: Border.all(color: context.colors.surfaceBorder),
                    borderRadius: appInsetGroupRadius,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        BonusPlanBarGraph(
                          expense: value.yearlyBonusExpense,
                          budget: value.yearlyBonusIncome,
                        ),
                        if (usagePercent != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '利用 $usagePercent%',
                                style:
                                    AppTextStyles.budgetFixedCostForecastLabel,
                              ),
                              Text(
                                // 予算超過時はマイナスの「残り」ではなく超過率を示す
                                usagePercent <= 100
                                    ? '残り ${100 - usagePercent}%'
                                    : '超過 ${usagePercent - 100}%',
                                style:
                                    AppTextStyles.budgetFixedCostForecastLabel,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const AppErrorState(),
        );
  }

  Widget _cellDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: VerticalDivider(
        width: 0.5,
        thickness: 0.5,
        color: context.colors.separator,
      ),
    );
  }
}

/// 3分割カードの1セル（ラベル＋金額の縦積み・中央揃え）
class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.price,
    this.priceColor,
  });

  final String label;
  final int price;
  final Color? priceColor;

  @override
  Widget build(BuildContext context) {
    final priceStyle = priceColor == null
        ? AppTextStyles.listTilePriceLabel
        : AppTextStyles.listTilePriceLabel.copyWith(color: priceColor);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: AppTextStyles.listTileTertiaryTitle),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                yenmarkFormattedPriceGetter(price),
                style: priceStyle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// スクロール時に出す1行のコンパクトバー（案件 UIデザイン改修 §4）
///
/// サマリー2枚が縮んだ状態。残額＋ミニバー＋利用%を高さ48の帯で表示する。
class BonusPlanCollapsedBar extends ConsumerWidget {
  const BonusPlanCollapsedBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(resolvedBonusPlanValueProvider)
        .when(
          data: (value) {
            final usagePercent = _usagePercent(
              income: value.yearlyBonusIncome,
              expense: value.yearlyBonusExpense,
            );

            // Columnのフロー内配置で背後にコンテンツが重ならないため、
            // ブラーは使わず不透明な帯にする
            return Container(
              height: 48,
              decoration: BoxDecoration(
                color: context.colors.surfaceElevated2,
                border: Border(
                  top: BorderSide(color: context.colors.separator, width: 0.5),
                  bottom: BorderSide(
                    color: context.colors.separator,
                    width: 0.5,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Text('残額', style: AppTextStyles.appCardTertiaryTitleLabel),
                  const SizedBox(width: 10),
                  Text(
                    yenmarkFormattedPriceGetter(value.lastBonusPrice),
                    style: AppTextStyles.listTilePriceLabel.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  const Spacer(),
                  if (usagePercent != null) ...[
                    SizedBox(
                      width: 96,
                      height: 6,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            Container(color: context.colors.fillSecondary),
                            FractionallySizedBox(
                              widthFactor: (usagePercent / 100).clamp(0.0, 1.0),
                              // heightFactor未指定だと子の高さが0になり塗りが見えない
                              heightFactor: 1,
                              child: Container(color: context.colors.primary),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '$usagePercent%',
                      style: AppTextStyles.budgetFixedCostForecastLabel,
                    ),
                  ],
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const AppErrorState(),
        );
  }
}

/// 利用率（%）。収入が未登録（0以下）のときはnull
int? _usagePercent({required int income, required int expense}) {
  if (income <= 0) return null;
  return ((expense / income) * 100).round().clamp(0, 999);
}
