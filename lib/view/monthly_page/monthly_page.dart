/// Package imports
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';

/// Local imports
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_page/monthly_fixed_cost_page.dart';
import 'package:kakeibo/view/monthly_page/monthly_fixed_cost/monthly_fixed_cost_summary_area.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthy_plan_home_page/monthly_plan_home_page.dart';
import 'package:kakeibo/view/config/config_top.dart';
import 'package:kakeibo/view/monthly_page/next_arrow_button.dart';
import 'package:kakeibo/view/monthly_page/previous_arrow_button.dart';
import 'package:kakeibo/view/monthly_page/monthly_plan_area/monthly_plan_area.dart';
import 'package:kakeibo/view/monthly_page/category_tile/category_sum_tile_list.dart';
import 'package:kakeibo/view/category_edit_page/category_setting_page.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/analyze_page_date_scope.dart';
import 'package:kakeibo/view_model/state/date_scope/analyze_page/selected_datetime/analyze_page_selected_datetime.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view/monthly_page/prediction_graph_area/prediction_graph.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';
import 'package:kakeibo/view/component/modal.dart';

class MonthlyPage extends ConsumerStatefulWidget {
  const MonthlyPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MonthlyPage();
}

class _MonthlyPage extends ConsumerState<MonthlyPage> {
  @override
  Widget build(BuildContext context) {
    //状態管理---------------------------------------------------------------------------------------

    // DBが更新されたらリビルドするため
    ref.watch(updateDBCountNotifierProvider);

    //--------------------------------------------------------------------------------------------
    //レイアウト------------------------------------------------------------------------------------

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Stack(children: [
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //左矢印ボタン、押すと前の月に移動
                const PreviousArrowButton(),
                Consumer(builder: (context, ref, _) {
                  final activeDt =
                      ref.watch(analyzePageSelectedDatetimeNotifierProvider);
                  final label = yyyyMMtoMMGetter(activeDt);
                  return Text(
                    label,
                    style: MyFonts.pageHeaderText,
                  );
                }),
                //右矢印ボタン、押すと次の月に移動
                const NextArrowButton(),
              ]),
          Positioned(
            right: 0,
            child: IconButton(
                onPressed: () => {
                      // 設定画面にrootのNavigatorで遷移
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => const ConfigTop(),
                        ),
                      )
                    },
                icon: const Icon(Icons.settings_rounded)),
          )
        ]),
      ),
      backgroundColor: MyColors.secondarySystemBackground,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.leftsidePadding),
          child: Column(
            children: [
              SizedBox(
                width: 343 * context.screenHorizontalMagnification,
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      ' 支出グラフ',
                      style: MyFonts.thirdPageSubheading,
                    ),
                  ],
                ),
              ),

              // グラフ部分
              Consumer(builder: (context, ref, _) {
                final dateScope = ref.watch(analyzePageDateScopeEntityProvider);
                return dateScope.when(
                  data: (scope) => PredictionGraph(dateScope: scope),
                  loading: () => Container(
                    height: 213,
                    width: 343 * context.screenHorizontalMagnification,
                    decoration: BoxDecoration(
                      color: MyColors.quarternarySystemfill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => Container(
                    height: 213,
                    width: 343 * context.screenHorizontalMagnification,
                    decoration: BoxDecoration(
                      color: MyColors.quarternarySystemfill,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'エラーが発生しました',
                        style: TextStyle(
                            color: MyColors.secondaryLabel, fontSize: 16),
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(
                height: 12,
              ),

              SizedBox(
                width: 343 * context.screenHorizontalMagnification,
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ' 今月の計画',
                      style: MyFonts.thirdPageSubheading,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 予算ボタン
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: SubButton(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MonthlyPlanHomePage(initialTab: 0),
                                ),
                              );
                            },
                            icon: Padding(
                              padding: const EdgeInsets.symmetric(horizontal:4.0),
                              child: SvgPicture.asset(
                                'assets/images/ui_icon_edit.svg',
                                colorFilter: const ColorFilter.mode(
                                    MyColors.themeColor, BlendMode.srcIn),
                                width: 15,
                                height: 15,
                              ),
                            ),
                            label: '予算',
                          ),
                        ),
                        const SizedBox(width: 6),
                        // 収入ボタン
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: SubButton(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MonthlyPlanHomePage(initialTab: 1),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.add,
                              size: 18,
                              color: MyColors.themeColor,
                            ),
                            label: '収入',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const MonthlyPlanArea(),

              const SizedBox(
                height: 8,
              ),

              SizedBox(
                width: 343 * context.screenHorizontalMagnification,
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ' カテゴリーの支出',
                      style: MyFonts.thirdPageSubheading,
                    ),
                    TextButton(
                        onPressed: () {
                          showModalBottomSheetFunc(
                              context, const CategorySettingPage());
                        },
                        child: const Text(
                          'カテゴリー設定',
                          style: MyFonts.thirdPageTextButton,
                        )),
                  ],
                ),
              ),

              const CategorySumTileList(),

              const SizedBox(
                height: 8,
              ),

              SizedBox(
                width: 343 * context.screenHorizontalMagnification,
                height: 35,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      ' 固定費',
                      style: MyFonts.thirdPageSubheading,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) =>
                                  const MonthlyFixedCostPage()));
                        },
                        child: const Text(
                          'さらに表示',
                          style: MyFonts.thirdPageTextButton,
                        )),
                  ],
                ),
              ),

              const MonthlyFixedCostSummaryArea(),

              const SizedBox(
                height: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SubButton extends StatelessWidget {
  const SubButton({
    super.key,
    required this.onTap,
    required this.icon,
    required this.label,
  });

  final void Function() onTap;
  final Widget icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AppInkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: MyColors.tirtiarySystemfill,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(width: 6),
              Text(
                label,
                style: MyFonts.thirdPageTextButton,
                textHeightBehavior: const TextHeightBehavior(
                  applyHeightToFirstAscent: true,
                  applyHeightToLastDescent: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
