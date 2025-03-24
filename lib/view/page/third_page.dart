/// Package imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:kakeibo/constant/strings.dart';

import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/atom/next_arrow_button.dart';
import 'package:kakeibo/view/atom/previous_arrow_button.dart';
import 'package:kakeibo/view/foundation.dart';
import 'package:kakeibo/view/organism/third_page/all_category_tile_area.dart';
import 'package:kakeibo/view/organism/third_page/category_tile_area.dart';
import 'package:kakeibo/view/page/category_setting_page.dart';
import 'package:kakeibo/view/page/torok.dart';
import 'package:kakeibo/view_model/provider/selected_datetime/selected_datetime.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/model/tableNameKey.dart';

/// Local imports
import 'package:kakeibo/view/page/budget_setting_page.dart';

import 'package:kakeibo/view/organism/prediction_graph.dart';

import 'package:kakeibo/view/molecule/calendar_month_display.dart';

import 'package:kakeibo/view_model/provider/update_DB_count.dart';

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
        title: SizedBox(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //左矢印ボタン、押すと前の月に移動
                const PreviousArrowButton(),
                Consumer(builder: (context, ref, _) {
                  final activeDt = ref.watch(selectedDatetimeNotifierProvider);
                  final label = labelGetter(activeDt);
                  return CalendarMonthDisplay(label: label);
                }),
                //左矢印ボタン、押すと次の月に移動
                const NextArrowButton(),
              ]),
        ),
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
                                context, const CategorySettingPage());
                          },
                          child: const Text(
                            'カテゴリー設定',
                            style: MyFonts.thirdPageTextButton,
                          )),
                    ],
                  ),
                ),

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
