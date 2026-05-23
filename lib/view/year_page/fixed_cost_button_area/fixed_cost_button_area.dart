import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/application/fixed_cost/active_fixed_cost_count_provider.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/card_container.dart';
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
          width: 8,
        ),
        FixedCostAddButton(),
      ],
    );
  }
}

class FixedCostManagePageButton extends ConsumerWidget {
  const FixedCostManagePageButton({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCountAsync = ref.watch(activeFixedCostCountProvider);

    return AppInkWell(
      color: MyColors.quarternarySystemfill,
      borderRadius: BorderRadius.circular(50.0),
      onTap: () async {
        Navigator.of(context).push(MaterialPageRoute(
            builder: ((context) => const FixedCostRegistrationListPage())));
      },
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '固定費一覧',
                style: AppTextStyles.oneLineButtonText,
              ),
              Row(
                children: [
                  activeCountAsync.when(
                    data: (count) => Text(
                      '$count件',
                      style: AppTextStyles.oneLineButtonSubText,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    size: 16,
                    Icons.arrow_forward_ios_rounded,
                    color: MyColors.secondaryLabel,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FixedCostAddButton extends StatelessWidget {
  const FixedCostAddButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      onTap: () {
        showAppModalBottomSheet(
          context,
          child: const RegisaterPageBase.addFixedCost(),
        );
      },
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: MyColors.quarternarySystemfill,
          borderRadius: BorderRadius.circular(50.0),
        ),
        child: const Icon(
          size: 18,
          Icons.add_rounded,
          color: MyColors.secondaryLabel,
        ),
      ),
    );
  }
}

/// 固定費が0件のときに表示する登録誘導カード
class FixedCostRegistrationCallToActionButton extends StatelessWidget {
  const FixedCostRegistrationCallToActionButton({super.key});

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
            const Icon(
              Icons.repeat_rounded,
              size: 32,
              color: MyColors.secondaryLabel,
            ),
            const SizedBox(height: 8),
            Text(
              '固定費を登録しましょう',
              style: AppTextStyles.appCardTitleLabel,
            ),
            const SizedBox(height: 4),
            Text(
              '毎月の家賃やサブスクを登録すると自動で記録されます',
              style: AppTextStyles.listCardSecondaryTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: MainButton(
                buttonText: '＋ 固定費を登録する',
                onPressed: () {
                  showAppModalBottomSheet(
                    context,
                    child: const RegisaterPageBase.addFixedCost(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
