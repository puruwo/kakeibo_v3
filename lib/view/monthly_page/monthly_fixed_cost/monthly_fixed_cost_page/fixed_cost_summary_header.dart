/// Package imports
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/util/util.dart';

/// Local imports
import 'package:kakeibo/view_model/middle_provider/resolved_all_category_tile_entity_provider/resolved_fixed_cost_value_provider.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class FixedCostSummaryHeader extends ConsumerStatefulWidget {
  const FixedCostSummaryHeader({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FixedCostSummaryHeaderState();
}

class _FixedCostSummaryHeaderState extends ConsumerState<FixedCostSummaryHeader> {
  @override
  Widget build(BuildContext context) {
    //状態管理---------------------------------------------------------------------------------------

    // DBが更新されたらリビルドするため
    ref.watch(updateDBCountNotifierProvider);

    //--------------------------------------------------------------------------------------------
    //レイアウト------------------------------------------------------------------------------------

    return ref.watch(resolvedFixedCostSammaryValueProvider).when(
          data: (value) {
            return Column(
              children: [
                // ヘッダー
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          '今月の支払い予定',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '${yenmarkFormattedPriceGetter(value.scheduledPaymentAmount)} 円',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 0, color: Colors.black26, thickness: 1),

                Container(
                  height: 40,
                  color: MyColors.quarternarySystemfill,
                  child:  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '確定分',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${yenmarkFormattedPriceGetter(value.fixedCostSum)} 円',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 0, color: Colors.black26, thickness: 1),
                // 未確定確定分（推定）
                Container(
                  height: 40,
                  color: MyColors.quarternarySystemfill,
                  child:  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            '未確定確定分(推定)',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          '${yenmarkFormattedPriceGetter(value.unconfirmedFixedCostSum)} 円',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('エラー: $e')),
        );
  }
}
