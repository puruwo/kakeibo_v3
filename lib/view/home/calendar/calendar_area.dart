import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/calendar/calendar_usecase.dart';
import 'package:logger/logger.dart';

/// LocalImport
import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/constant/colors.dart';

import 'package:kakeibo/domain/ui_value/calendar/calendar_tile_entity.dart';

import 'package:kakeibo/view/home/calendar/date_box.dart';

import 'package:kakeibo/view_model/state/calendar_page/page_controller/calendar_page_controller.dart';
import 'package:kakeibo/view_model/state/date_scope/selected_datetime/selected_datetime.dart';

final logger = Logger();

class CalendarArea extends ConsumerWidget {
  const CalendarArea({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 画面の横幅を取得
    final screenWidthSize = MediaQuery.of(context).size.width;

    // 画面の倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(screenWidthSize);

    // 縦サイズは横よりも少ない倍率で拡大
    final screenVerticalMagnification = screenVerticalMagnificationGetter(
        screenWidthSize, screenHorizontalMagnification);

//状態管理---------------------------------------------------------------------------------------

    // pageViewのコントローラ
    final PageController pageController =
        ref.watch(calendarPageControllerNotifierProvider);

//----------------------------------------------------------------------------------------------

//描写-------------------------------------------------------------------------------------------
    return Container(
      decoration: BoxDecoration(
          color: MyColors.quarternarySystemfill,
          borderRadius: BorderRadius.circular(18)),
      width: 346 * screenHorizontalMagnification,
      height: 302 * screenVerticalMagnification,
      child: PageView.builder(
        controller: pageController,

        // ページが変わったときの処理
        // selectedDatetimeNotifierProviderの値を更新する
        onPageChanged: (page) {
          // pageは現在ページ

          // ページの移動方向を判定する
          // 1: 右に移動中
          if (page > pageController.page!) {
            ref
                .read(selectedDatetimeNotifierProvider.notifier)
                .updateToNextMonth();
            logger.d('Callendar: called updateToNextMonth()');
          }

          // -1: 左に移動中
          else if (page < pageController.page!) {
            ref
                .read(selectedDatetimeNotifierProvider.notifier)
                .updateToPreviousMonth();
            logger.d('Callendar: called updateToPreviousMonth()');
          }

          // 0: ページが移動していない
          else {
            logger.d('Callendar: called no page change');
          }

          logger.d('Callendar: page is $page');
        },

        // 表示部分記述
        itemBuilder: (context, index) {
          return ref.watch(calendarUsecaseNotifierProvider(index)).when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => Center(child: Text('$error')),
                data: (calendarTileEntityList) {
                  // データ取得------------------------------------------------------

                  // dateBoxの高さ
                  final boxHeight = (calendarTileEntityList.length == 5)
                      ?
                      // 5週間表示なら高さは
                      54.0 * screenVerticalMagnification
                      // 6週間表示なら高さは
                      : 45.0 * screenVerticalMagnification;

                  // dateBoxの横幅
                  final boxWidth = 46.0 * screenHorizontalMagnification;

                  // データ取得終わり------------------------------------------------------

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // カレンダーヘッダー
                      _calendarHeader(screenHorizontalMagnification),

                      // 区切り線
                      Divider(
                        // ウィジェット自体の高さ
                        height: 0,
                        // 線の太さ
                        thickness: 0.25,
                        indent: 12 * screenHorizontalMagnification,
                        endIndent: 12 * screenHorizontalMagnification,
                        color: MyColors.separater,
                      ),

                      // カレンダー中身
                      ...List.generate(calendarTileEntityList.length,
                          (weekIndex) {
                        return Column(
                          children: [
                            _weekRow(
                                context,
                                ref,
                                calendarTileEntityList[weekIndex],
                                boxHeight,
                                boxWidth),
                            // 区切り線
                            Divider(
                              height: 0,
                              thickness: 0.25,
                              indent: 12 * screenHorizontalMagnification,
                              endIndent: 12 * screenHorizontalMagnification,
                              color: MyColors.separater,
                            ),
                          ],
                        );
                      }),
                    ],
                  );
                },
              );
        },
      ),
    );
  }
}

SizedBox _calendarHeader(double boxWidth) {
  return SizedBox(
    width: 322 * boxWidth,
    child: const Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Text('日', style: TextStyle(color: MyColors.red, fontSize: 12)),
        Text('月',
            style: TextStyle(color: MyColors.secondaryLabel, fontSize: 12)),
        Text('火',
            style: TextStyle(color: MyColors.secondaryLabel, fontSize: 12)),
        Text('水',
            style: TextStyle(color: MyColors.secondaryLabel, fontSize: 12)),
        Text('木',
            style: TextStyle(color: MyColors.secondaryLabel, fontSize: 12)),
        Text('金',
            style: TextStyle(color: MyColors.secondaryLabel, fontSize: 12)),
        Text('土', style: TextStyle(color: MyColors.blue, fontSize: 12)),
      ],
    ),
  );
}

Row _weekRow(
  BuildContext context,
  WidgetRef ref,
  List<CalendarTileEntity> calendarTileEntityList,
  double boxHeight,
  double boxWidth,
) {
  return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (dayIndex) {
        
        return DateBox(calendarTileEntity:calendarTileEntityList[dayIndex],boxHeight:boxHeight,boxWidth:boxWidth);
      }));
}

String gettermmdd(List<List<Map<String, dynamic>>> dateInformationList,
    int weekIndex, int dayIndex) {
  final month = dateInformationList[weekIndex][dayIndex]['month'].toString();
  final day = dateInformationList[weekIndex][dayIndex]['day'].toString();
  return '$month月$day日';
}



