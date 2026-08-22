/// Package imports
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/view/component/app_error_state.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/util/util.dart';

/// Local imports
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_fixed_cost_value_provider.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

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
            return Column(
              children: [
                // ヘッダー
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '今月の固定費',
                          style: AppTextStyles.appCardTitleLabel,
                        ),
                      ),
                      Text(
                        yenmarkFormattedPriceGetter(value.scheduledPaymentAmount),
                        style: AppTextStyles.appCardPriceLabel,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0, color: Colors.black26, thickness: 1),

                Container(
                  height: 40,
                  color: context.colors.fillQuaternary,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('確定分', style: AppTextStyles.appCardTitleLabel),
                        Text(
                          yenmarkFormattedPriceGetter(value.fixedCostSum),
                          style: AppTextStyles.appCardSecondaryPriceLabel,
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 0, color: Colors.black26, thickness: 1),
                // 未確定分（想定額での計上）
                Container(
                  height: 40,
                  color: context.colors.fillQuaternary,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '未確定分（予想）',
                            style: AppTextStyles.appCardTitleLabel,
                          ),
                        ),
                        Text(
                          yenmarkFormattedPriceGetter(value.unconfirmedFixedCostSum),
                          style: AppTextStyles.appCardSecondaryPriceLabel,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => const AppErrorState(),
        );
  }
}
