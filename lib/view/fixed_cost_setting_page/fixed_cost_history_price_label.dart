import 'package:flutter/material.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/domain/db/expense/expense_entity.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/util/util.dart';

/// 支払い履歴行の金額ラベル
///
/// 確定行は実額を右寄せで出し、未確定行は推定額を出さず「未入力」を表示する
/// （案件: 固定費バッジデザイン調整 決定C-1）。
/// 固定費の設定ページの「直近の支払い」と支払い履歴ページで共用する。
class FixedCostHistoryPriceLabel extends StatelessWidget {
  const FixedCostHistoryPriceLabel({super.key, required this.expense});

  final ExpenseEntity expense;

  @override
  Widget build(BuildContext context) {
    if (expense.isConfirmed == 0) {
      return Text(
        '未入力',
        // 和文なので noto 系。未入力の減衰は色（textTertiary）で表す
        style: AppTextStyles.supportingText.copyWith(
          color: context.colors.textTertiary,
        ),
      );
    }
    return Text(
      yenmarkFormattedPriceGetter(expense.effectivePrice),
      style: AppTextStyles.insetGroupHistoryPrice,
    );
  }
}
