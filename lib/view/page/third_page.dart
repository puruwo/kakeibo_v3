/// Package imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view/atom/next_arrow_button.dart';
import 'package:kakeibo/view/atom/previous_arrow_button.dart';
import 'package:kakeibo/view/foundation.dart';
import 'package:kakeibo/view/page/category_setting_page.dart';
import 'package:kakeibo/view/page/torok.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/model/assets_conecter/category_handler.dart';
import 'package:kakeibo/model/tableNameKey.dart';

/// Local imports
import 'package:kakeibo/view/page/budget_setting_page.dart';

import 'package:kakeibo/view/organism/category_sum_tile.dart';
import 'package:kakeibo/view/organism/balance_graph.dart';
import 'package:kakeibo/view/organism/balance_graph_syncfusion.dart';
import 'package:kakeibo/view/organism/prediction_graph.dart';
import 'package:kakeibo/view/organism/all_category_sum_tile.dart';

import 'package:kakeibo/view/molecule/calendar_month_display.dart';

import 'package:kakeibo/view_model/provider/active_datetime.dart';
import 'package:kakeibo/view_model/provider/update_DB_count.dart';
import 'package:kakeibo/view_model/category_sum_getter.dart';

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

    final activeDt = ref.watch(activeDatetimeNotifierProvider);

    //----------------------------------------------------------------------------------------------
    //データ取得--------------------------------------------------------------------------------------

    Future<List<Map<String, dynamic>>> bigcategorySumMapList =
        BigCategorySumMapGetter().build(activeDt);
    // {
    // _id:
    // color_code:
    // big_category_name:
    // resource_path:
    // big_category_budget:
    // payment_price_sum:
    // smallCategorySumAndBudgetList:{_id
    //                                small_category_payment_sum :
    //                                big_category_key:
    //                                tdisplayed_order_in_big:
    //                                category_name:
    //                                default_displayed}:
    // }

    Future<List<Map<String, dynamic>>> paymentSumByBig =
        AllPaymentGetter().build(activeDt);

    Future<List<Map<String, dynamic>>> allBudgetSum =
        AllBudgetGetter().build(activeDt);

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
                PreviousArrowButton(function: () async {
                  final notifier =
                      ref.read(activeDatetimeNotifierProvider.notifier);
                  notifier.updateToPreviousMonth();
                  // Navigator.pushReplacement();
                  Navigator.of(context, rootNavigator: true).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          MaterialApp(
                        debugShowCheckedModeBanner: false,
                        theme: ThemeData.dark(),
                        themeMode: ThemeMode.dark,
                        darkTheme: ThemeData.dark(),
                        home: MediaQuery.withClampedTextScaling(
                          // テキストサイズの制御
                          minScaleFactor: 0.7,
                          maxScaleFactor: 0.95,
                          child: Foundation(),
                        ),
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }),
                Consumer(builder: (context, ref, _) {
                  final activeDt = ref.watch(activeDatetimeNotifierProvider);
                  final label = labelGetter(activeDt);
                  return CalendarMonthDisplay(label: label);
                }),
                //左矢印ボタン、押すと次の月に移動
                NextArrowButton(function: () async {
                  final notifier =
                      ref.read(activeDatetimeNotifierProvider.notifier);
                  notifier.updateToNextMonth();
                  Navigator.of(context, rootNavigator: true).pushReplacement(
                    PageRouteBuilder(
                      pageBuilder: (context, animation1, animation2) =>
                          MaterialApp(
                        debugShowCheckedModeBanner: false,
                        theme: ThemeData.dark(),
                        themeMode: ThemeMode.dark,
                        darkTheme: ThemeData.dark(),
                        home: MediaQuery.withClampedTextScaling(
                          // テキストサイズの制御
                          minScaleFactor: 0.7,
                          maxScaleFactor: 0.95,
                          child: Foundation(),
                        ),
                      ),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                }),
              ]),
        ),
      ),
      backgroundColor: MyColors.secondarySystemBackground,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 343 * screenHorizontalMagnification,
                  height: 35,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ' 支出グラフ',
                        style: GoogleFonts.notoSans(
                            fontSize: 18,
                            color: MyColors.secondaryLabel,
                            fontWeight: FontWeight.w600),
                      ),
                      TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                              //sccafoldの上に出すか
                              useRootNavigator: true,
                              isScrollControlled: true,
                              useSafeArea: true,
                              constraints: const BoxConstraints(
                                maxWidth: 2000,
                              ),
                              context: context,
                              // constで呼び出さないとリビルドがかかってtextfieldのも何度も作り直してしまう
                              builder: (context) {
                                return MaterialApp(
                                  debugShowCheckedModeBanner: false,
                                  theme: ThemeData.dark(),
                                  themeMode: ThemeMode.dark,
                                  darkTheme: ThemeData.dark(),
                                  home: MediaQuery.withClampedTextScaling(
                                    // テキストサイズの制御
                                    minScaleFactor: 0.7,
                                    maxScaleFactor: 0.95,
                                    child: BudgetSettingPage(),
                                  ),
                                );
                              },
                            );
                          },
                          child: const Text(
                            '予算設定',
                            style: TextStyle(
                                color: MyColors.linkColor, fontSize: 14),
                          )),
                    ],
                  ),
                ),

                // グラフ部分
                FutureBuilder(
                    future: allBudgetSum,
                    builder: ((context, snapshot) {
                      if (snapshot.hasData) {
                        // constで呼び出さないとリビルドがかかってグラフの挙動がおかしくなる
                        return PredictionGraph(
                          activeDt: activeDt,
                        );
                      } else {
                        return Container(
                          width: 343 * screenHorizontalMagnification,
                          height: 213,
                        );
                      }
                    })),

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
                        style: GoogleFonts.notoSans(
                            fontSize: 18,
                            color: MyColors.secondaryLabel,
                            fontWeight: FontWeight.w600),
                      ),
                      SizedBox(
                        height: 30,
                        width: 120,
                        child: TextButton(
                            onPressed: () {
                              showModalBottomSheet(
                                //sccafoldの上に出すか
                                useRootNavigator: true,
                                isScrollControlled: true,
                                useSafeArea: true,
                                constraints: const BoxConstraints(
                                  maxWidth: 2000,
                                ),
                                context: context,
                                // constで呼び出さないとリビルドがかかってtextfieldのも何度も作り直してしまう
                                builder: (context) {
                                  return MaterialApp(
                                    debugShowCheckedModeBanner: false,
                                    theme: ThemeData.dark(),
                                    themeMode: ThemeMode.dark,
                                    darkTheme: ThemeData.dark(),
                                    home: MediaQuery.withClampedTextScaling(
                                      // テキストサイズの制御
                                      minScaleFactor: 0.7,
                                      maxScaleFactor: 0.95,
                                      child: const CategorySettingPage(),
                                    ),
                                  );
                                },
                              );
                            },
                            child: const Text(
                              'カテゴリー設定',
                              style: TextStyle(
                                  color: MyColors.linkColor, fontSize: 14),
                            )),
                      ),
                    ],
                  ),
                ),

                // カテゴリータイル
                FutureBuilder(
                    future: Future.wait(
                        [bigcategorySumMapList, paymentSumByBig, allBudgetSum]),
                    builder: ((context, snapshot) {
                      if (snapshot.hasData) {
                        // 全カテゴリーのタイル
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: AllCategorySumTile(
                              // ['big_category_key']['big_category_name'] ['payment_price_sum'] ['icon'] ['color']
                              bigCategoryInformationMaps: snapshot.data![0],
                              // int
                              allCategorySum:
                                  snapshot.data![1][0]['all_price_sum'] ?? 0,
                              // int
                              allCategoryBudgetSum:
                                  snapshot.data![2][0]['budget_sum'] ?? 0),
                        );
                      } else {
                        return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              height: 63,
                              width: 343 * screenHorizontalMagnification,
                            ));
                      }
                    })),

                FutureBuilder(
                    future: bigcategorySumMapList,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Column(
                            children:
                                List.generate(snapshot.data!.length, (index) {
                          final bigCategoryKey = snapshot.data![index]
                              [TBL201RecordKey().bigCategoryKey];
                          // 個別カテゴリーのタイル
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: CategorySumTile(
                                icon: CategoryHandler()
                                    .sisytIconGetterFromBigCategoryKey(
                                        bigCategoryKey,
                                        height: 25,
                                        width: 25),
                                categoryName: snapshot.data![index]
                                    [TBL202RecordKey().bigCategoryName],
                                colorCode: snapshot.data![index]
                                    [TBL202RecordKey().colorCode],
                                bigCategorySum: snapshot.data![index]
                                    ['payment_price_sum'],
                                budget: snapshot.data![index]
                                    ['big_category_budget'],
                                smallCategorySumList: snapshot.data![index]
                                    ['smallCategorySumAndBudgetList']),
                          );
                        }));
                      } else {
                        return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              height: 63,
                              width: 343 * screenHorizontalMagnification,
                            ));
                      }
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
