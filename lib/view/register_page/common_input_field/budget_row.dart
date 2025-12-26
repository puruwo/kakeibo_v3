import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';

/// 予算行（「予算」ラベルと拠出元選択）
///
/// 画像デザインの「📊 予算 | 給料 ▼」部分
class BudgetRow extends ConsumerWidget {
  const BudgetRow({
    super.key,
    required this.originalIncomeSourceBigCategory,
  });

  final int originalIncomeSourceBigCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 実際の拠出元リストから取得するように改修
    final incomeSourceLabels = ['給料', '貯金', 'ボーナス', 'その他'];
    final selectedLabel =
        originalIncomeSourceBigCategory < incomeSourceLabels.length
            ? incomeSourceLabels[originalIncomeSourceBigCategory]
            : '給料';

    return Container(
      decoration: BoxDecoration(
        color: MyColors.secondarySystemfill,
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 左側：予算アイコン+ラベル
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: MyColors.secondaryLabel,
              ),
              const SizedBox(width: 8),
              Text(
                '予算',
                style: TextStyle(
                  color: MyColors.secondaryLabel,
                  fontSize: 15,
                ),
              ),
            ],
          ),

          // 右側：拠出元選択
          AppInkWell(
            borderRadius: BorderRadius.circular(6),
            onTap: () {
              _showIncomeSourcePicker(context, ref, incomeSourceLabels);
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedLabel,
                  style: TextStyle(
                    color: MyColors.white,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 20,
                  color: MyColors.secondaryLabel,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showIncomeSourcePicker(
    BuildContext context,
    WidgetRef ref,
    List<String> labels,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: MyColors.tertiarySystemBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MyColors.separater,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ...labels.map(
                (label) => ListTile(
                  title: Text(
                    label,
                    style: const TextStyle(color: MyColors.white),
                  ),
                  onTap: () {
                    // TODO: 拠出元を更新
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
