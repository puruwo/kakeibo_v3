/// Package imports
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakeibo/constant/strings.dart';

/// Local imports
import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/config/config_top.dart';
import 'package:kakeibo/view/third_page/monthly_plan_area.dart';
import 'package:kakeibo/view/third_page/next_arrow_button.dart';
import 'package:kakeibo/view/third_page/previous_arrow_button.dart';
import 'package:kakeibo/view/third_page/tile/all_category_tile_area.dart';
import 'package:kakeibo/view/third_page/tile/category_tile_area.dart';
import 'package:kakeibo/view/category_edit_page/big_category_setting_page/big_category_setting_page.dart';
import 'package:kakeibo/view_model/state/date_scope/selected_datetime/selected_datetime.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view/budget_setting_page/budget_setting_page.dart';
import 'package:kakeibo/view/third_page/prediction_graph.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';

class Third extends ConsumerStatefulWidget {
  const Third({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ThirdState();
}

class _ThirdState extends ConsumerState<Third> {
  @override
  Widget build(BuildContext context) {
    // 画面の横幅を取得
    final screenWidthSize = MediaQuery.of(context).size.width;

    // 画面の倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(screenWidthSize);

    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * screenHorizontalMagnification;

    //状態管理---------------------------------------------------------------------------------------

    // DBが更新されたらリビルドするため
    ref.watch(updateDBCountNotifierProvider);

    final activeDt = ref.watch(selectedDatetimeNotifierProvider);

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
                  final activeDt = ref.watch(selectedDatetimeNotifierProvider);
                  final label = labelGetter(activeDt);
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
            child: Column(
              children: [
                SizedBox(
                  width: 343 * screenHorizontalMagnification,
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ' 支出グラフ',
                        style: MyFonts.thirdPageSubheading,
                      ),
                      TextButton(
                          onPressed: () {
                            _showModalBottomSheet(
                                context, const BudgetSettingPage());
                          },
                          child: const Text(
                            '予算設定',
                            style: MyFonts.thirdPageTextButton,
                          )),
                    ],
                  ),
                ),

                // グラフ部分
                PredictionGraph(
                  activeDt: activeDt,
                ),

                const SizedBox(
                  height: 8,
                ),

                SizedBox(
                  width: 343 * screenHorizontalMagnification,
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
                            _showModalBottomSheet(
                                context, const BigCategorySettingPage());
                          },
                          child: const Text(
                            'カテゴリー設定',
                            style: MyFonts.thirdPageTextButton,
                          )),
                    ],
                  ),
                ),

                const MonthlyPlanArea(),

                const SizedBox(
                  height: 8,
                ),
                const AllCategoryTileArea(),

                const SizedBox(
                  height: 8,
                ),

                const CategoryTileArea(),

                const SizedBox(
                  height: 32,
                ),

                const SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showModalBottomSheet(BuildContext context, Widget page) {
    showModalBottomSheet(
      //sccafoldの上に出すか
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      constraints: const BoxConstraints(
        maxWidth: 2000,
      ),
      context: context,
      builder: (context) {
        return page;
      },
    );
  }
}
