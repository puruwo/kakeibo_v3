import 'package:flutter/material.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/theme/app_colors.dart';
import 'package:kakeibo/view/component/card_container.dart';

/// 今月の収支データ（支出・収入・予算）がすべて未入力のとき、登録を促す誘導カード。
/// yearly_balance_area.dart の空状態と同じ構成（アイコン＋見出し＋説明）。
/// ボタンは monthly_page.dart 側の「収入を追加 / 予算を編集」ボタン Row があるため省略する。
class MonthlyPlanRegisterPromptArea extends StatelessWidget {
  const MonthlyPlanRegisterPromptArea({super.key});

  @override
  Widget build(BuildContext context) {
    return CardContainer(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 20.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.account_balance_wallet_rounded,
              size: 32,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              '今月の収支を記録しましょう',
              style: AppTextStyles.appCardTitleLabel,
            ),
            const SizedBox(height: 4),
            Text(
              '収入や予算を登録すると今月の収支が表示されます',
              style: AppTextStyles.listCardSecondaryTitle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
