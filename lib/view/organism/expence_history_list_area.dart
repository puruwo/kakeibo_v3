import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/constant/properties.dart';
import 'package:kakeibo/repository/tbl001_record/tbl001_record.dart';
import 'package:kakeibo/repository/torok_record/torok_record.dart';
import 'dart:collection';
// DateTimeの日本語対応
import 'package:intl/intl.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:collection/collection.dart';
import 'package:kakeibo/view_model/provider/selected_datetime/selected_datetime.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

/// Local imports
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/util/screen_size_func.dart';

import 'package:kakeibo/view/page/torok.dart';

import 'package:kakeibo/view_model/provider/update_DB_count.dart';
import 'package:kakeibo/view_model/reference_day_impl.dart';

import 'package:kakeibo/model/db_read_impl.dart';
import 'package:kakeibo/model/tableNameKey.dart';
import 'package:kakeibo/model/assets_conecter/category_handler.dart';

class ExpenceHistoryArea extends ConsumerStatefulWidget {
  ExpenceHistoryArea({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExpenceHistoryAreaState();

  final AutoScrollController _scrollController = AutoScrollController();
}

class _ExpenceHistoryAreaState extends ConsumerState<ExpenceHistoryArea> {
  late SplayTreeMap<String, dynamic> sortedGroupedMap;

  // リストビューの左の空白
  late double leftsidePadding;

  @override
  Widget build(BuildContext context) {
    // 画面の横幅を取得
    final screenWidthSize = MediaQuery.of(context).size.width;

    // 画面の倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(screenWidthSize);

    // リスト内テキストボックスの倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final listSmallcategoryMemoOffset =
        listSmallcategoryMemoOffsetGetter(screenWidthSize);

    // カレンダーサイズから左の空白の大きさを計算
    leftsidePadding = 14.5 * screenHorizontalMagnification;

    // DateTimeの日本語対応
    initializeDateFormatting();

//状態管理---------------------------------------------------------------------------------------

    //databaseに操作がされた場合にカウントアップされるprovider
    ref.watch(updateDBCountNotifierProvider);

    final activeDateTime = ref.watch(selectedDatetimeNotifierProvider);

    // activeDatetimeが更新されたら動く
    ref.listen(selectedDatetimeNotifierProvider, (previous, next) {
      // ビルドが終わったら動く
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        final updatedActiveDateTime = ref.read(selectedDatetimeNotifierProvider);
        // DateTimeで並べ替えたMapのKeyをリストとして取得
        final itemKeys = List.from(sortedGroupedMap.keys);
        _scrollToItem(
            updatedActiveDateTime, itemKeys, widget._scrollController);
      });
    });

//----------------------------------------------------------------------------------------------
//データ取得--------------------------------------------------------------------------------------

    //集計スタートの日
    final fromDate = getReferenceDay(activeDateTime);

    //集計終了の日
    //次の基準日を取得しているので、そこから1引いて集計終了日を算出
    final dtBuff = getNextReferenceDay(activeDateTime);
    final toDate = dtBuff.add(const Duration(days: -1));

    final Future<List<Map<String, dynamic>>> rows =
        TBL001Impl().queryCrossMonthMutableRows(fromDate, toDate);

//----------------------------------------------------------------------------------------------

    return FutureBuilder(
        future: rows,
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          Widget children;

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            //snapShotのリストを分割する
            final groupedMap = snapshot.data!
                .groupListsBy<String>((e) => e[TBL001RecordKey().date]);
            //Mapのキーで上から降順に並び替える
            //型指定してやらんとエラーになる、Object型で判定されるため
            sortedGroupedMap = SplayTreeMap.from(
                groupedMap, (String key1, String key2) => key2.compareTo(key1));

            return Expanded(
              child: ListView.builder(
                controller: widget._scrollController,
                itemCount: sortedGroupedMap.length,
                itemBuilder: (BuildContext context, int index) {
                  String date = sortedGroupedMap.keys.elementAt(index);
                  List<Map> itemsInADay = sortedGroupedMap[date]!;
                  List<Map> descendingOrderItems =
                      descendingOrderSort(itemsInADay);

                  final stringDate = formattedLabelDateGetter(date);
                  return AutoScrollTag(
                    key: ValueKey(index),
                    index: index,
                    controller: widget._scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 日付ヘッダーの上スペース
                        const SizedBox(
                          height: 13,
                        ),
                        //日付ラベル
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: leftsidePadding),
                              child: Text(stringDate,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: MyColors.secondaryLabel,
                                  )),
                            ),
                            //右余白
                          ],
                        ),

                        //区切り線
                        Divider(
                          thickness: 0.25,
                          height: 0.25,
                          indent: leftsidePadding,
                          endIndent: leftsidePadding,
                          color: MyColors.separater,
                        ),

                        //タイル
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: descendingOrderItems.length,
                          itemBuilder: (BuildContext context, int index) {
                            final item = itemsInADay[index];

                            // アイコン
                            final icon = CategoryHandler().sisytIconGetter(
                                item[TBL001RecordKey().paymentCategoryId],
                                height: 25,
                                width: 25);
                            // 大カテゴリー名
                            final bigCategoryName =
                                item[TBL202RecordKey().bigCategoryName];
                            // 小カテゴリー
                            final categoryName =
                                item[TBL201RecordKey().categoryName];
                            // メモ
                            final memo = item[TBL001RecordKey().memo];
                            // 値段ラベル
                            final priceLabel = yenmarkFormattedPriceGetter(
                                item[TBL001RecordKey().price]);

                            return GestureDetector(
                              onTap: () async {
                                // categoryIdからcategoryOrderKeyを取得
                                final int categoryOrderKey =
                                    await getPaymentCategoryOrderKeyFromCategoryId(
                                        item[SeparateLabelMapKey().category]);
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
                                              date: item[
                                                  SeparateLabelMapKey().date],
                                              id: item[
                                                  SeparateLabelMapKey().id],
                                              price: item[
                                                  SeparateLabelMapKey().price],
                                              memo: item[
                                                  SeparateLabelMapKey().memo],
                                              categoryOrderKey:
                                                  categoryOrderKey),
                                          screenMode: 1,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Dismissible(
                                // 右から左
                                direction: DismissDirection.endToStart,
                                key: Key(item[TBL001RecordKey().id].toString()),
                                dragStartBehavior: DragStartBehavior.start,

                                // 右スワイプ時の背景
                                background: Container(color: MyColors.black),

                                // 左スワイプ時の背景
                                secondaryBackground: Container(
                                  color: MyColors.red,
                                  child: const Align(
                                      alignment: Alignment.centerRight,
                                      child: Padding(
                                        // 削除時背景のアイコンのpadding
                                        padding: EdgeInsets.only(right: 18.0),
                                        child: Icon(
                                          Icons.delete,
                                          color: MyColors.systemGray,
                                        ),
                                      )),
                                ),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.only(
                                          left: leftsidePadding,
                                          right: leftsidePadding),
                                      child: SizedBox(
                                        height: 49,
                                        width: double.infinity,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // アイコン
                                            SizedBox(
                                                height: 49,
                                                width: 49,
                                                child: icon),

                                            // 大カテゴリー、小カテゴリーのColumn
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // 大カテゴリー
                                                  SizedBox(
                                                    width: 153 *
                                                        screenHorizontalMagnification,
                                                    child: Text(
                                                      bigCategoryName,
                                                      textAlign:
                                                          TextAlign.start,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        color: MyColors.label,
                                                      ),
                                                    ),
                                                  ),

                                                  // 小カテゴリーとメモ
                                                  Row(
                                                    children: [
                                                      // 小カテゴリー
                                                      SizedBox(
                                                        width: 56,
                                                        child: Text(
                                                          ' $categoryName',
                                                          textAlign:
                                                              TextAlign.start,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              color: MyColors
                                                                  .secondaryLabel),
                                                        ),
                                                      ),
                                                      // メモ
                                                      SizedBox(
                                                        width: 90 +
                                                            listSmallcategoryMemoOffset,
                                                        child: Text(
                                                          ' $memo',
                                                          textAlign:
                                                              TextAlign.start,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: const TextStyle(
                                                              fontSize: 12,
                                                              color: MyColors
                                                                  .secondaryLabel),
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),

                                            // 値段
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 22.0),
                                              child: SizedBox(
                                                width: 100,
                                                child: Text(
                                                  priceLabel,
                                                  textAlign: TextAlign.end,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                      fontSize: 19,
                                                      color: MyColors.label),
                                                ),
                                              ),
                                            ),

                                            // nextArrowアイコン
                                            const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 4),
                                              child: Icon(
                                                size: 18,
                                                Icons.arrow_forward_ios_rounded,
                                                color: MyColors.white,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      thickness: 0.25,
                                      height: 0.25,
                                      indent: 50 + leftsidePadding,
                                      endIndent: leftsidePadding,
                                      color: MyColors.separater,
                                    )
                                  ],
                                ),

                                //タイルを横にスライドした時の処理
                                confirmDismiss: (direction) async {
                                  if (direction ==
                                      DismissDirection.endToStart) {
                                    return await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                              "登録履歴の削除"), // ダイアログのタイトル
                                          content: const Text(
                                              "削除したデータは戻せません。\n本当に削除しますか？"), // ダイアログのメッセージ
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(
                                                      false), // キャンセルボタンを押したときの処理
                                              child: Text("戻る"),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(
                                                      true), // 削除ボタンを押したときの処理
                                              child: Text("OK"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                  return null;
                                },

                                //ダイアログでOKを押したら処理
                                onDismissed: (direction) {
                                  final record = TBL001Record(
                                    id: item[TBL001RecordKey().id],
                                    category: item[
                                        TBL001RecordKey().paymentCategoryId],
                                    price: item[TBL001RecordKey().price],
                                    memo: item[TBL001RecordKey().memo],
                                    date: item[TBL001RecordKey().date],
                                  );
                                  record.delete();
                                  // 消す
                                  print(
                                      '削除されました id:${item[TBL001RecordKey().id]}'
                                      'category:${item[TBL001RecordKey().paymentCategoryId]}'
                                      'price:${item[TBL001RecordKey().price]}'
                                      'memo:${item[TBL001RecordKey().memo]}'
                                      '${item[TBL001RecordKey().date]}年');
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          } else {
            children = const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                ),
                Center(
                  child: Text(
                    '記録がまだありません',
                    style:
                        TextStyle(color: MyColors.secondaryLabel, fontSize: 16),
                  ),
                ),
              ],
            );
          }

          return children;
        });
  }

  void _scrollToItem(
      DateTime dt, List keysList, AutoScrollController controller) async {
    final specificItem = DateFormat('yyyyMMdd').format(dt);
    final index = keysList.indexOf(specificItem);
    await controller.scrollToIndex(
      index,
      duration: const Duration(milliseconds: 500),
      preferPosition: AutoScrollPosition.begin,
    );
    await controller.highlight(index);
  }

  List<Map<dynamic, dynamic>> descendingOrderSort(List<Map> itemsInADay) {
    //sortはvoid関数
    itemsInADay.sort(
        ((a, b) => b[TBL001RecordKey().id].compareTo(a[TBL001RecordKey().id])));
    final sorted = itemsInADay;
    return sorted;
  }

  String formattedLabelDateGetter(String dateString) {
    // 文字列をDateTimeに変換
    DateTime dateTime = DateTime.parse(
        '${dateString.substring(0, 4)}-${dateString.substring(4, 6)}-${dateString.substring(6, 8)}');

    // 年月日と曜日のフォーマットで日付を文字列に変換
    String formattedDate = DateFormat('yyyy年M月d日(E)', 'ja_JP').format(dateTime);

    return formattedDate;
  }

  double listSmallcategoryMemoOffsetGetter(double screenWidthSize) {
    final defaultWidth = ScreenLayoutProperties().defaultWidth;
    return screenWidthSize - defaultWidth;
  }
}
