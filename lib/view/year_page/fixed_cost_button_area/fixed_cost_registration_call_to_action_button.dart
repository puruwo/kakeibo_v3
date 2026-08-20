import 'package:flutter/material.dart';
import 'package:kakeibo/view/component/app_empty_state.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

/// 固定費が0件のときに表示する登録誘導カード（ADR-022 の `AppEmptyState`）。
/// ホームタブの固定費ボタン領域と、固定費登録リストページの0件表示の両方から使う。
class FixedCostRegistrationCallToActionButton extends StatelessWidget {
  const FixedCostRegistrationCallToActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      icon: Icons.repeat_rounded,
      title: '固定費を登録しましょう',
      description: '毎月の家賃やサブスクを登録すると自動で記録されます',
      buttonLabel: '＋ 固定費を登録する',
      onPressed: () {
        showAppModalBottomSheet(
          context,
          child: const RegisaterPageBase.addFixedCost(),
        );
      },
    );
  }
}
