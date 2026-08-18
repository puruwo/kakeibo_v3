import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost/active_fixed_cost_count_provider.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/view/component/app_empty_state.dart';
import 'package:kakeibo/view/component/app_navigation_list_tile.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_registration_list_page.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';

class FixedCostButtonArea extends ConsumerWidget {
  const FixedCostButtonArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCountAsync = ref.watch(activeFixedCostCountProvider);

    // 件数取得時のみ空状態を判定し、ローディング・エラー時は安全側で従来表示
    final isEmpty = activeCountAsync.maybeWhen(
      data: (count) => count == 0,
      orElse: () => false,
    );

    if (isEmpty) {
      return const FixedCostRegistrationCallToActionButton();
    }

    return const Row(
      children: [
        Expanded(
          child: FixedCostManagePageButton(),
        ),
        SizedBox(
          width: AppSpacing.sm,
        ),
        FixedCostAddButton(),
      ],
    );
  }
}

/// ADR-016 B: 固定費一覧はボタンではなくナビゲーション行（[AppNavigationListTile]）。
class FixedCostManagePageButton extends ConsumerWidget {
  const FixedCostManagePageButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCountAsync = ref.watch(activeFixedCostCountProvider);

    return AppNavigationListTile(
      title: '固定費一覧',
      trailingText: activeCountAsync.maybeWhen(
        data: (count) => '$count件',
        orElse: () => null,
      ),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: ((context) => const FixedCostRegistrationListPage())));
      },
    );
  }
}

/// ADR-016 A: Icon-onlyは既存の[IconOnlyButton]（AppIconCircleContainer経由）を使う。
/// 独自にContainerで円を組み立てない。
class FixedCostAddButton extends StatelessWidget {
  const FixedCostAddButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconOnlyButton(
      icon: Icons.add_rounded,
      onTap: () {
        showAppModalBottomSheet(
          context,
          child: const RegisaterPageBase.addFixedCost(),
        );
      },
    );
  }
}

/// 固定費が0件のときに表示する登録誘導カード
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
