/// packegeImport
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/properties.dart';
import 'package:kakeibo/model/assets_conecter/category_handler.dart';

import 'package:kakeibo/model/db_read_impl.dart';
import 'package:kakeibo/model/db_delete_impl.dart';
import 'package:kakeibo/model/tableNameKey.dart';

import 'package:kakeibo/repository/tbl003_record/tbl003_record.dart';
import 'package:kakeibo/util/number_text_input_formatter.dart';
import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/util/util.dart';

import 'package:kakeibo/view_model/provider/update_DB_count.dart';

import 'package:kakeibo/view_model/reference_day_impl.dart';

class BudgetSettingPage extends ConsumerStatefulWidget {
  const BudgetSettingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BudgetSettingPageState();
}

class _BudgetSettingPageState extends ConsumerState<BudgetSettingPage> {
  final activeDt = DateTime.now();

  // 今月の予算データのリスト
  List<Map<String, dynamic>>? monthlyCategoryBudgetList;

  // 先月の実績データのリスト
  List<Map<String, dynamic>>? lastMonthPaymentList;

  // カテゴリーの要素クラスItemのリスト
  final List<Item> itemList = [];

  // 編集モードで予算が編集されたかどうか
  bool isBudgetEdited = false;

  @override
  void initState() {
    super.initState();

    // 初期化が終わる前にbuildが完了してしまうのでawait&SetStateする
    Future(() async {
      await initialize();
      setState(() {});
    });
  }

  @override
  void dispose() {
    itemList.forEach((element) {
      element.controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 画面の横幅を取得
    final screenWidthSize = MediaQuery.of(context).size.width;

    // 画面の倍率を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    final screenHorizontalMagnification =
        screenHorizontalMagnificationGetter(screenWidthSize);

    // リスト内テキストボックスの拡大部を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    // 大カテゴリーと小カテゴリーで増幅分を2等分する
    final listSTextBoxOffset =
        listSmallcategoryMemoOffsetGetter(screenWidthSize) / 2;

    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * screenHorizontalMagnification;

    // DBが更新されたら再描画する
    ref.listen(updateDBCountNotifierProvider, (oldState, newState) {
      Future(() async {
        itemList.forEach((element) {
          element.controller.dispose();
        });
        itemList.clear();
        await initialize();
        setState(() {});
      });
    });

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: MyColors.secondarySystemBackground,
        // ヘッダー
        appBar: AppBar(
          title: Text(
            '今月の予算を入力',
            style: GoogleFonts.notoSans(
                fontSize: 19,
                color: MyColors.white,
                fontWeight: FontWeight.w400),
          ),

          backgroundColor: MyColors.secondarySystemBackground,
          //ヘッダー左のアイコンボタン
          leading: IconButton(
              // 閉じるときはネストしているModal内のRouteではなく、root側のNavigatorを指定する必要がある
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              icon: const Icon(
                Icons.close,
                color: MyColors.white,
              )),

          //ヘッダー右のアイコンボタン
          actions: [
            IconButton(
              icon: const Icon(
                //完了チェックマーク
                Icons.done_rounded,
                color: MyColors.white,
              ),
              onPressed: () async {
                // 登録処理
                await registorFunction();
              },
            ),
          ],
        ),

        // 本体
        body: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 56),
                    child: Text(
                      'カテゴリー',
                      style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: MyColors.secondaryLabel,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '先月の支出',
                        style: GoogleFonts.notoSans(
                            fontSize: 16,
                            color: MyColors.secondaryLabel,
                            fontWeight: FontWeight.w400),
                      ),
                      SizedBox(
                        width: 123,
                        child: Text(
                          '今月の予算',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.notoSans(
                              fontSize: 16,
                              color: MyColors.secondaryLabel,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            //区切り線
            Divider(
              thickness: 0.25,
              height: 0.25,
              indent: leftsidePadding,
              endIndent: leftsidePadding,
              color: MyColors.separater,
            ),

            // リスト部分
            Expanded(
              child: ListView.builder(
                itemCount: monthlyCategoryBudgetList != null
                    ? monthlyCategoryBudgetList!.length
                    : 0,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      // リスト本体
                      Column(
                        children: [
                          SizedBox(
                            height: 50,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: leftsidePadding),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                key: Key('$index'),
                                children: [
                                  // アイコン
                                  Padding(
                                    padding: const EdgeInsets.all(12.5),
                                    child: itemList[index].icon,
                                  ),

                                  // カテゴリー名
                                  SizedBox(
                                    width: 70 + listSTextBoxOffset * 2,
                                    child: Text(
                                      itemList[index].bigCategoryName,
                                      style: GoogleFonts.notoSans(
                                          fontSize: 18,
                                          color: MyColors.label,
                                          fontWeight: FontWeight.w400),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),

                                  // 先月の実績
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: 64,
                                        child: Text(
                                          formattedPriceGetter(
                                              itemList[index].sumBigCategory),
                                          style: const TextStyle(
                                              fontFamily: 'sf_ui',
                                              fontSize: 16,
                                              color: MyColors.secondaryLabel,
                                              fontWeight: FontWeight.w300),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                      Text(
                                        ' 円',
                                        style: GoogleFonts.notoSans(
                                            fontSize: 14,
                                            color: MyColors.secondaryLabel,
                                            fontWeight: FontWeight.w300),
                                      )
                                    ],
                                  ),

                                  // 金額入力フィールド
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 100,
                                        child: TextField(
                                          controller:
                                              itemList[index].controller,
                                          // テキストフィールドのプロパティ
                                          textAlign: TextAlign.right,
                                          textAlignVertical:
                                              TextAlignVertical.top,
                                          style: const TextStyle(
                                              fontFamily: 'sf_ui',
                                              fontWeight: FontWeight.w600,
                                              color: MyColors.white,
                                              fontSize: 20),
                                          inputFormatters: [
                                            // カンマのフォーマット
                                            NumberTextInputFormatter()
                                          ],

                                          // デコレーション
                                          decoration: InputDecoration(
                                            // なんかわからんおまじない
                                            isDense: true,

                                            // 背景の塗りつぶし
                                            filled: false,

                                            // ヒントテキスト
                                            hintText: "金額を入力",
                                            hintStyle: const TextStyle(
                                              fontSize: 16,
                                            ),

                                            // テキストの余白
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    top: 16,
                                                    bottom: 0,
                                                    left: 0,
                                                    right: 0),

                                            // 境界線を設定しないとアンダーラインが表示されるので透明でもいいから境界線を設定
                                            // 何もしていない時の境界線
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: MyColors.jet
                                                    .withOpacity(0.0),
                                              ),
                                            ),
                                            // 入力時の境界線
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              borderSide: BorderSide(
                                                color: MyColors.jet
                                                    .withOpacity(0.0),
                                              ),
                                            ),
                                          ),
                                          keyboardType: TextInputType.number,
                                          // 編集されたら編集フラグをtrueに
                                          onChanged: (value) {
                                            isBudgetEdited = true;
                                          },
                                          // //領域外をタップでproviderを更新する
                                          onTapOutside: (event) {
                                            //キーボードを閉じる
                                            FocusScope.of(context).unfocus();
                                          },
                                          onEditingComplete: () {
                                            //キーボードを閉じる
                                            FocusScope.of(context).unfocus();
                                          },
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            top: 12.0, bottom: 8.0),
                                        child: Text(
                                          ' 円',
                                          style: GoogleFonts.notoSans(
                                              fontSize: 14,
                                              color: MyColors.secondaryLabel,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //区切り線
                          Divider(
                            thickness: 0.25,
                            height: 0.25,
                            indent: leftsidePadding + 50,
                            endIndent: leftsidePadding,
                            color: MyColors.separater,
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 目標データの挿入
  registorFunction() async {
    if (isBudgetEdited) {
      await tBL003Impl();
    }
  }

  tBL003Impl() async {
    bool isCorrectlyInput = true;

    // 正しく入力できているか確認
    for (int i = 0; i < itemList.length; i++) {
      // 入力が空かどうか
      if (itemList[i].controller.text == '') {
        isCorrectlyInput = false;
        inputErrorSnackBarFunc(itemList[i].bigCategoryName);
      }
    }

    // 登録成功
    if (isCorrectlyInput) {
      for (int i = 0; i < itemList.length; i++) {
        final int inputPrice =
            int.parse(itemList[i].controller.text.replaceAll(',', ''));

        final int bigCategoryId = itemList[i].bigCategoryId;
        final int price = inputPrice;
        final String date = DateFormat('yyyyMMdd').format(DateTime.now());

        // 目標データのインスタンス化
        final record =
            TBL003Record(date: date, bigCategory: bigCategoryId, price: price);

        // 日付被りのデータを一行取得
        final listBuff =
            await getSpecifiedDateBigCategoryBudget(date, bigCategoryId);
        Map? deletingTargetData;
        if (listBuff.isNotEmpty) {
          deletingTargetData = listBuff[0];
        }

        // 削除するべきレコードがあれば削除
        if (deletingTargetData != null) {
          int deletingTargetDataId = deletingTargetData[TBL003RecordKey().id];
          tBL003RecordDelete(deletingTargetDataId);
        }

        // 目標データの挿入
        record.insert();
      }
      // スナックバーの表示
      doneSnackBarFunc();

      //DB更新のnotifier
      //DBが更新されたことをグローバルなproviderに反映
      dbUpdateNotify();

      // 編集したかどうかを初期化
      isBudgetEdited = false;
    }
  }

  void doneSnackBarFunc() {
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('登録が完了しました'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));
  }

  void inputErrorSnackBarFunc(String categoryName) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text('$categoryNameの値を入力してください'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
  }

  void dbUpdateNotify() {
    final notifier = ref.read(updateDBCountNotifierProvider.notifier);
    notifier.incrementState();
  }

  // initstate内の宣言
  initialize() async {
    // 目標データの取得
    // {
    //  big_category_id
    //  price
    //  color_code
    //  big_category_name
    //  resource_path
    //  display_order
    //  is_displayed
    // }
    monthlyCategoryBudgetList = await queryMonthlyCategoryBudget(activeDt);

    // 先月の実績のデータを取得
    final toDate = getReferenceDay(activeDt);
    final fromDate = getPreviousReferenceDay(toDate);
    // {
    //  sum_by_bigcategory:
    //  big_category_key:
    // }
    lastMonthPaymentList =
        await queryCrossMonthMutableRowsByCategory(fromDate, toDate);

    // itemListの初期化
    for (int i = 0; i < monthlyCategoryBudgetList!.length; i++) {
      final price = monthlyCategoryBudgetList![i]['price'].toString();
      itemList.add(Item(
        // 大カテゴリーのIDを取得
        bigCategoryId: monthlyCategoryBudgetList![i]
            [TBL003RecordKey().bigCategoryId],
        // 大カテゴリーの予算を取得
        bigCategoryBudget: monthlyCategoryBudgetList![i]['price'],
        // 大カテゴリーのcolorCodeを取得
        bigCategoryColor: monthlyCategoryBudgetList![i]
            [TBL202RecordKey().colorCode],
        // 大カテゴリーの名前を取得
        bigCategoryName: monthlyCategoryBudgetList![i]
            [TBL202RecordKey().bigCategoryName],
        // 大カテゴリーの画像パスを取得
        bigCategoryResourcePath: monthlyCategoryBudgetList![i]
            [TBL202RecordKey().resourcePath],
        // 大カテゴリーの先月の実績
        sumBigCategory: lastMonthPaymentList![i]['sum_by_bigcategory'],
        // 大カテゴリーの先月のid
        bigCategoryKey: lastMonthPaymentList![i][TBL202RecordKey().id],
        // 表示順
        gotDisplayOrder: monthlyCategoryBudgetList![i]
            [TBL202RecordKey().displayOrder],
        // 表示非表示設定
        isDisplayed: monthlyCategoryBudgetList![i]
            [TBL202RecordKey().isDisplayed],
        // コントローラー
        controller: TextEditingController.fromValue(
          NumberTextInputFormatter().formatEditUpdate(
            TextEditingValue.empty,
            TextEditingValue(text: price),
          ),
        ),
      ));
    }
  }

  double listSmallcategoryMemoOffsetGetter(double screenWidthSize) {
    final defaultWidth = ScreenLayoutProperties().defaultWidth;
    return screenWidthSize - defaultWidth;
  }
}

class Item {
  // 大カテゴリーのIDを取得
  final int bigCategoryId;
  // 大カテゴリーの予算を取得
  final int bigCategoryBudget;
  // 大カテゴリーのcolorCodeを取得
  final String bigCategoryColor;
  // 大カテゴリーの名前を取得
  final String bigCategoryName;
  // 大カテゴリーの画像パスを取得
  final String bigCategoryResourcePath;
  // アイコンの取得
  late Widget icon;
  // 大カテゴリーの先月の実績
  final int sumBigCategory;
  // 大カテゴリーの先月のid
  final int bigCategoryKey;
  // DBから取得した表示順
  final int gotDisplayOrder;
  // 編集後表示順
  late int editedDisplayOrder;
  // DBでの表示非表示設定 0 or 1
  final int isDisplayed;
  // 表示非表示の設定
  late bool isChecked;
  // コントローラー
  final TextEditingController controller;

  Item({
    required this.bigCategoryId,
    required this.bigCategoryBudget,
    required this.bigCategoryColor,
    required this.bigCategoryName,
    required this.bigCategoryResourcePath,
    required this.sumBigCategory,
    required this.bigCategoryKey,
    required this.gotDisplayOrder,
    required this.isDisplayed,
    required this.controller,
  }) {
    // アイコンの取得
    icon = CategoryHandler().sisytIconGetterFromBigCategoryKey(bigCategoryId,
        height: 25, width: 25);
    // 表示日表示の初期化
    isChecked = isDisplayed == 1 ? true : false;
    // 編集後表示順の初期化
    editedDisplayOrder = gotDisplayOrder;
  }
}
