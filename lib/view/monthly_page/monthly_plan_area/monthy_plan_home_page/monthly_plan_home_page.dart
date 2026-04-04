import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/budget_setting_page/budget_cotegory_area.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/budget_page_summary_area.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/monthly_plan_home_footer.dart';

class MonthlyPlanHomePage extends ConsumerWidget {
  const MonthlyPlanHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: MyColors.secondarySystemBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          flexibleSpace: const GlassAppBarBackground(),
          title: Text(
            '毎月の予算',
            style: AppTextStyles.pageHeaderText,
          ),
        ),
        body: Column(
          children: [
            // 上部サマリー（予算と収入のみ）
            const Padding(
              padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
              child: BudgetPageSummaryArea(),
            ),

            const SizedBox(height: 8),

            // 予算カテゴリーリスト
            const Expanded(
              child: BudgetCategoryArea(),
            ),

            const Divider(height: 1),

            // フッターボタンエリア（グロナビに隠れないようSafeAreaを適用）
            const SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                child: MonthlyPlanHomeFooter(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
