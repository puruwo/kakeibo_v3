import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/calendar/calendar_usecase.dart';
import 'package:kakeibo/view/historical_calendar_page/calendar_area/date_box.dart';
import 'package:kakeibo/view_model/state/date_scope/historical_page/selected_datetime/historical_selected_datetime.dart';
import 'package:kakeibo/view_model/state/page_manager/page_manager.dart';
import 'package:logger/logger.dart';

/// LocalImport
import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/calendar/calendar_tile_entity.dart';
import 'package:kakeibo/view/component/card_container.dart';
import 'package:kakeibo/view_model/state/calendar_page/page_controller/calendar_page_controller.dart';

final logger = Logger();

class CalendarArea extends ConsumerStatefulWidget {
  const CalendarArea({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CalendarAreaState();
}

class _CalendarAreaState extends ConsumerState<CalendarArea> {
  late DateTime initialDate;

  @override
  Widget build(
    BuildContext context,
  ) {
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

    // providerが破棄されていないことが多いので、初期化を強制的に行う
    // 初期化することで、pageManagerNotifierProviderの値を取り込んで初期化する
    ref.invalidate(calendarPageControllerNotifierProvider);

    // pageViewのコントローラ
    final PageController pageController =
        ref.watch(calendarPageControllerNotifierProvider);

//----------------------------------------------------------------------------------------------

//描写-------------------------------------------------------------------------------------------
    return CardContainer(
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
                .read(historicalSelectedDatetimeNotifierProvider.notifier)
                .updateToNextMonth();
            // 全体管理の状態も更新
            ref.read(pageManagerNotifierProvider.notifier).nextPage();
            logger.d('Callendar: called updateToNextMonth()');
          }

          // -1: 左に移動中
          else if (page < pageController.page!) {
            ref
                .read(historicalSelectedDatetimeNotifierProvider.notifier)
                .updateToPreviousMonth();
            // 全体管理の状態も更新
            ref.read(pageManagerNotifierProvider.notifier).previousPage();
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
        Text('日', style: MyFonts.calendarWeekdaySunday),
        Text('月', style: MyFonts.calendarWeekdayLabel),
        Text('火', style: MyFonts.calendarWeekdayLabel),
        Text('水', style: MyFonts.calendarWeekdayLabel),
        Text('木', style: MyFonts.calendarWeekdayLabel),
        Text('金', style: MyFonts.calendarWeekdayLabel),
        Text('土', style: MyFonts.calendarWeekdaySaturday),
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
        return DateBox(
            calendarTileEntity: calendarTileEntityList[dayIndex],
            boxHeight: boxHeight,
            boxWidth: boxWidth);
      }));
}

String gettermmdd(List<List<Map<String, dynamic>>> dateInformationList,
    int weekIndex, int dayIndex) {
  final month = dateInformationList[weekIndex][dayIndex]['month'].toString();
  final day = dateInformationList[weekIndex][dayIndex]['day'].toString();
  return '$month月$day日';
}
