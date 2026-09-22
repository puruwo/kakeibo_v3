import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakeibo/constant/styles/app_spacing.dart';
import 'package:kakeibo/constant/styles/app_text_styles.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view/component/glass_app_bar_background.dart';
import 'package:kakeibo/view/component/modal.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/fixed_cost_summary_header.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/fixed_cost_by_category_list_area.dart';
import 'package:kakeibo/view/register_page/register_page_base.dart';
import 'package:kakeibo/view/year_page/fixed_cost_button_area/fixed_cost_registration_list_page/fixed_cost_registration_list_page.dart';
import 'package:kakeibo/constant/icon.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';

class MonthlyFixedCostPage extends ConsumerWidget {
  const MonthlyFixedCostPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 表示中の月度（月間分析タブと連動）。タイトルにどの月度の一覧かを出す
    final monthPeriod = ref.watch(
      analyzePageDateScopeEntityProvider.select(
        (scope) => scope.valueOrNull?.aggregationMonthPeriod,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        flexibleSpace: const GlassAppBarBackground(),
        // 固定費登録リストページ（「登録中の固定費」）と見分けられるよう、
        // 「その月度に支払う固定費」だと月度と期間で示す（案件 KP-030・M-A案）
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              monthPeriod == null
                  ? '固定費'
                  : '${mmToMMGetter(monthPeriod)}の固定費',
              style: context.textStyles.pageHeaderText,
            ),
            if (monthPeriod != null)
              Text(
                periodDayRangeGetter(monthPeriod),
                style: context.textStyles.pageHeaderSubNumeric,
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + kToolbarHeight,
              ),
              child: const Column(
                children: [
                  SizedBox(height: AppSpacing.lg),

                  // ヘッダー
                  FixedCostSummaryHeader(),

                  // カテゴリー別リスト
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                        AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                    child: FixedCostByCategoryListArea(),
                  ),
                ],
              ),
            ),
          ),
          // 仕様 §1: フッターの区切り線は置かない（背景と地続きの控えめなフッター）
          // フッターボタンエリア（グロナビに隠れないようSafeAreaを適用）
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  // 固定費を管理ボタン
                  Expanded(
                    child: MainButton(
                      buttonType: ButtonColorType.secondary,
                      buttonText: '登録中の固定費を見る',
                      onPressed: () async {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: ((context) =>
                                const FixedCostRegistrationListPage()),
                          ),
                        );
                      },
                    ),
                  ),

                  // 間の隙間
                  const SizedBox(width: AppSpacing.sm),

                  // 固定費を新しく登録する
                  Expanded(
                    child: MainButton(
                      iconData: AppIcons.add,
                      buttonType: ButtonColorType.main,
                      buttonText: '固定費を登録',
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
          ),
        ],
      ),
    );
  }
}
