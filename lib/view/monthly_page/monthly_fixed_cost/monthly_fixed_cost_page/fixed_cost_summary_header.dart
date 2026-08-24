/// Package imports
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/util/util.dart';

/// Local imports
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_fixed_cost_value_provider.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

/// 固定費画面の「今月の固定費」サマリー（案件 UIデザイン改修 §3）
///
/// 画面幅いっぱいの帯＋ハードコード区切り線をやめ、
/// CardContainer 1枚（合計＋確定分／未確定分の2カラム）に集約する。
class FixedCostSummaryHeader extends ConsumerStatefulWidget {
  const FixedCostSummaryHeader({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FixedCostSummaryHeaderState();
}

class _FixedCostSummaryHeaderState
    extends ConsumerState<FixedCostSummaryHeader> {
  @override
  Widget build(BuildContext context) {
    //状態管理---------------------------------------------------------------------------------------

    // DBが更新されたらリビルドするため
    ref.watch(updateDBCountNotifierProvider);

    //--------------------------------------------------------------------------------------------
    //レイアウト------------------------------------------------------------------------------------

    return ref
        .watch(resolvedFixedCostSammaryValueProvider)
        .when(
          data: (value) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: CardContainer(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  children: [
                    // 合計（支払い予定額）
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '今月の固定費',
                            style: AppTextStyles.appCardTitleLabel,
                          ),
                        ),
                        Text(
                          yenmarkFormattedPriceGetter(
                              value.scheduledPaymentAmount),
                          style: AppTextStyles.appCardPriceLabel,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.md),
                    Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: context.colors.separator,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // 確定分／未確定分（予想）の2カラム
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '確定分',
                                style: AppTextStyles.appCardTertiaryTitleLabel,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                yenmarkFormattedPriceGetter(value.fixedCostSum),
                                style:
                                    AppTextStyles.appCardSecondaryPriceLabel,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '未確定分（予想）',
                                style: AppTextStyles.appCardTertiaryTitleLabel,
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                yenmarkFormattedPriceGetter(
                                    value.unconfirmedFixedCostSum),
                                style:
                                    AppTextStyles.appCardSecondaryPriceLabel,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const AppErrorState(),
        );
  }
}
