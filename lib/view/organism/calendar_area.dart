import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view_model/provider/calendar_page_controller/calendar_page_controller.dart';
import 'package:kakeibo/view_model/provider/selected_datetime/selected_datetime.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:intl/intl.dart';

/// LocalImport

import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/util/screen_size_func.dart';

import 'package:kakeibo/view_model/provider/update_DB_count.dart';

import 'package:kakeibo/view_model/calendar_builder.dart';
import 'package:kakeibo/view_model/reference_day_impl.dart';

import 'package:kakeibo/repository/torok_record/torok_record.dart';

import 'package:kakeibo/view/page/torok.dart';

// pageViewのコントローラ
  // 閾値：[0,1000] 初期値：500
  final int initialCenter = 500;

class CalendarArea extends ConsumerWidget {
  CalendarArea({super.key});

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
    final PageController pageController = ref.watch(calendarPageControllerNotifierProvider);

    //databaseに操作がされた場合にカウントアップされるprovider
    ref.watch(updateDBCountNotifierProvider);

    // dayが変わった時だけ再描画する
    final activeDay = ref.watch(
        selectedDatetimeNotifierProvider.select((DateTime value) => value.day));

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
        itemBuilder: (context, index) {
          // データ取得------------------------------------------------------

          // そのindexで表示する日付のゲッター
          final thisIndexDisplayDateTime =
              getThisIndexDisplayDt(index, activeDay);

          // 表示月のデータを取得
          final calendarData =
              CalendarBuilder().build(thisIndexDisplayDateTime);

          // その月が何週間表示されるか
          final weekNumber = calendarData.length;

          // dateBoxの高さ
          final boxHeight = (weekNumber == 5)
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
              ...List.generate(calendarData.length, (weekIndex) {
                return Column(
                  children: [
                    _weekRow(ref, weekIndex, calendarData,
                        thisIndexDisplayDateTime, boxHeight, boxWidth),
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
        onPageChanged: (page) {
          // pageは現在ページ
          // pageController.pageはページ遷移中の値なので、double型
          int movingDirection;

          if (page > pageController.page!) {
            movingDirection = 1;
          } else if (page < pageController.page!) {
            movingDirection = -1;
          } else {
            movingDirection = 0;
          }

          print(page.toString());
          print(pageController.page!.toString());

          if (movingDirection == 1) {
            ref.read(selectedDatetimeNotifierProvider.notifier).updateToNextMonth();
            print('called updateToNextMonth()');
          } else if (movingDirection == -1) {
            ref.read(selectedDatetimeNotifierProvider.notifier).updateToPreviousMonth();
            print('called updateToPreviousMonth()');
          } else if (movingDirection == 0) {
            print('page isn\'t moving');
          }
        },
      ),
    );
  }

  DateTime getThisIndexDisplayDt(int index, int activeDay) {
    // そのページが現在の月のページ(index = 500)からどれだけ離れているか
    int monthDiff = index - initialCenter;

    DateTime nowDt = DateTime.now();
    final nowDtReferenceDay = getReferenceDay(nowDt);

    // activeDayが基準日と同じ月でなければ(次の月ならば)現在の月のページとずれが出るので1足す必要がある
    final month =
        activeDay >= 25 ? nowDtReferenceDay.month : nowDtReferenceDay.month + 1;
    return DateTime(nowDtReferenceDay.year, month + monthDiff, activeDay);
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
  WidgetRef ref,
  int weekIndex,
  List<List<Map<String, dynamic>>> dateInformationList,
  DateTime displayDate,
  double boxHeight,
  double boxWidth,
) {
  return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(7, (dayIndex) {
        bool isTapable = dateInformationList[weekIndex][dayIndex]['isTapable'];
        int year = dateInformationList[weekIndex][dayIndex]['year'];
        int month = dateInformationList[weekIndex][dayIndex]['month'];
        int day = dateInformationList[weekIndex][dayIndex]['day'];

        Future<int> buff = dateInformationList[weekIndex][dayIndex]['priceSum'];

        String label;
        Text priceLabel;

        if (day == 1 || day == 25) {
          label = '$month/$day';
        } else {
          label = '$day';
        }

        int weekday = dayIndex + 1;

        return FutureBuilder(
            future: buff,
            builder: ((context, snapshot) {
              if (snapshot.data == 0) {
                priceLabel = const Text('');
              } else {
                if (snapshot.data == null || snapshot.data! > 1888888) {
                  priceLabel = const Text('');
                } else if (snapshot.data! <= 9999) {
                  final buff = formattedPriceGetter(snapshot.data!);
                  priceLabel = Text(
                    '¥$buff',
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(
                      color: MyColors.white,
                      fontSize: 12,
                      fontFamily: 'sf_ui',
                    ),
                  );
                } else if (snapshot.data! <= 99999) {
                  final buff = formattedPriceGetter(snapshot.data!);
                  priceLabel = Text(
                    buff,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(
                      color: MyColors.white,
                      fontSize: 12,
                      fontFamily: 'sf_ui',
                    ),
                  );
                } else {
                  final buff = formattedPriceGetter(snapshot.data!);
                  priceLabel = Text(
                    buff,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.fade,
                    style: const TextStyle(
                      color: MyColors.white,
                      fontSize: 11,
                      fontFamily: 'sf_ui',
                    ),
                  );
                }
              }
              return InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: isTapable
                      ? () {
                          final provider =
                              ref.read(selectedDatetimeNotifierProvider);

                          // タップした日付が状態と違っていたら状態を更新
                          if (DateFormat('yyyyMMdd').format(provider) !=
                              DateFormat('yyyyMMdd')
                                  .format(DateTime(year, month, day))) {
                            final notifier = ref
                                .read(selectedDatetimeNotifierProvider.notifier);
                            notifier.updateState(DateTime(year, month, day));
                          }
                          // タップした日付が状態と同じならタップした日付を持ったTorok画面を出す
                          else if (DateFormat('yyyyMMdd').format(provider) ==
                              DateFormat('yyyyMMdd')
                                  .format(DateTime(year, month, day))) {
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
                                      child: Torok.origin(
                                        torokRecord: TorokRecord(
                                            date: DateFormat('yyyyMMdd').format(
                                                DateTime(year, month, day))),
                                        screenMode: 0,
                                      )),
                                );
                              },
                            );
                          }
                        }
                      : null,

                  // ロングプレスでも選択日付を持った登録画面を出す
                  onLongPress: () => isTapable
                      ? showModalBottomSheet(
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
                                  child: Torok.origin(
                                    torokRecord: TorokRecord(
                                        date: DateFormat('yyyyMMdd').format(
                                            DateTime(year, month, day))),
                                    screenMode: 0,
                                  )),
                            );
                          },
                        )
                      : null,
                  child: displayDate == DateTime(year, month, day)
                      ? activeDateBox(
                          weekday, label, priceLabel, boxHeight, boxWidth)
                      : isTapable
                          ? normalDateBox(
                              weekday, label, priceLabel, boxHeight, boxWidth)
                          : vacantDateBox(weekday, label, boxHeight, boxWidth));
            }));
      }));
}

String gettermmdd(List<List<Map<String, dynamic>>> dateInformationList,
    int weekIndex, int dayIndex) {
  final month = dateInformationList[weekIndex][dayIndex]['month'].toString();
  final day = dateInformationList[weekIndex][dayIndex]['day'].toString();
  return '$month月$day日';
}

Container vacantDateBox(
    int weekday, String dateLabel, double boxHeight, double boxWidth) {
  return Container(
    width: boxWidth,
    height: boxHeight,
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(6)),
    ),
    child: Center(
      child: Column(
        children: [
          Text(dateLabel,
              style: const TextStyle(color: MyColors.tirtiaryLabel)),
        ],
      ),
    ),
  );
}

Container normalDateBox(int weekday, String dateLabel, Text priceLabel,
    double boxHeight, double boxWidth) {
  return Container(
    width: boxWidth,
    height: boxHeight,
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(6)),
    ),
    child: Center(
      child: Column(
        children: [
          Text(
            dateLabel,
            style: TextStyle(
              color: weekday == 7
                  ? MyColors.blue
                  : weekday == 1
                      ? MyColors.red
                      : MyColors.secondaryLabel,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: SizedBox(
              width: boxWidth,
              child: priceLabel,
            ),
          )
        ],
      ),
    ),
  );
}

Container activeDateBox(int weekday, String dateLabel, Text priceLabel,
    double boxHeight, double boxWidth) {
  return Container(
    width: boxWidth,
    height: boxHeight,
    decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6)),
        color: MyColors.tirtiarySystemfill),
    child: Center(
      child: Column(
        children: [
          Text(
            dateLabel,
            style: TextStyle(
              color: weekday == 7
                  ? MyColors.blue
                  : weekday == 1
                      ? MyColors.red
                      : MyColors.secondaryLabel,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: SizedBox(
              width: boxWidth,
              child: priceLabel,
            ),
          )
        ],
      ),
    ),
  );
}
