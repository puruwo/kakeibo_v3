import 'package:flutter/material.dart';
import 'package:kakeibo/view/component/app_empty_state.dart';

/// 今月の収支データ（支出・収入・予算）がすべて未入力のとき、登録を促す誘導カード
/// （ADR-022 の `AppEmptyState`・ボタン無し版）。
/// ボタンは monthly_page.dart 側の「収入を追加 / 予算を編集」ボタン Row があるため省略する。
class MonthlyPlanRegisterPromptArea extends StatelessWidget {
  const MonthlyPlanRegisterPromptArea({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppEmptyState(
      icon: Icons.account_balance_wallet_rounded,
      title: '今月の収支を記録しましょう',
      description: '収入や予算を登録すると今月の収支が表示されます',
    );
  }
}
