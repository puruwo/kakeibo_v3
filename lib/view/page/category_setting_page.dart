/// packegeImport
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

/// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/properties.dart';
import 'package:kakeibo/domain_service/month_period_service/month_period_service.dart';
import 'package:kakeibo/model/assets_conecter/category_handler.dart';

import 'package:kakeibo/model/db_read_impl.dart';
import 'package:kakeibo/model/tableNameKey.dart';

import 'package:kakeibo/repository/tbl202_record/tbl202_record.dart';
import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/view/molecule/icon_button%20copy.dart';
import 'package:kakeibo/view/page/small_category_edit_page.dart';

import 'package:kakeibo/view_model/state/update_DB_count.dart';
import 'package:kakeibo/view_model/provider/category_edit_page/edit_mode.dart';

import 'package:kakeibo/view_model/reference_day_impl.dart';

class CategorySettingPage extends ConsumerStatefulWidget {
  const CategorySettingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CategorySettingPageState();
}

class _CategorySettingPageState extends ConsumerState<CategorySettingPage> {
  final activeDt = DateTime.now();

  // 今月の予算データのリスト
  List<Map<String, dynamic>>? monthlyCategoryBudgetList;

  // 先月の実績データのリスト
  List<Map<String, dynamic>>? lastMonthPaymentList;

  // カテゴリーの要素クラスItemのリスト
  final List<Item> itemList = [];

  // 編集モードで表示非表示が編集されたかどうか
  bool isDefaultDisplayEdited = false;

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    MonthPeriodService monthPeriodService = ref.watch(monthPeriodServiceProvider);

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

    final editmodeProvider = ref.watch(editModeNotifierProvider);

    // DBが更新されたら再描画する
    ref.listen(updateDBCountNotifierProvider, (oldState, newState) {
      Future(() async {
        itemList.clear();
        await initialize();
        setState(() {});
      });
    });
    // ref.watch(updateDBCountNotifierProvider);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
          backgroundColor: MyColors.secondarySystemBackground,
          // ヘッダー
          appBar: AppBar(
            backgroundColor: MyColors.secondarySystemBackground,
            title: Text(
              'カテゴリーの設定',
              style: GoogleFonts.notoSans(
                  fontSize: 19,
                  color: MyColors.white,
                  fontWeight: FontWeight.w400),
            ),

            //ヘッダー左のアイコンボタン
            leading: IconButton(
                // 閉じるときはネストしているModal内のRouteではなく、root側のNavigatorを指定する必要がある
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
                icon: const Icon(Icons.close, color: MyColors.white)),

            //ヘッダー右のアイコンボタン
            actions: [
              IconButton(
                icon: editmodeProvider
                    ? const Icon(
                        //完了チェックマーク
                        Icons.done_rounded,
                        color: MyColors.white,
                      )
                    : const Text(
                        '編集',
                        style: TextStyle(color: MyColors.white),
                      ),
                onPressed: () {
                  // 登録処理
                  editmodeProvider ? registorFunction() : null;

                  //DB更新のnotifier
                  //DBが更新されたことをグローバルなproviderに反映
                  editmodeProvider ? dbUpdateNotify() : null;

                  // 編集モードの状態を更新
                  final notifier = ref.read(editModeNotifierProvider.notifier);
                  notifier.updateState();
                },
              ),
            ],
          ),

          // 本体
          body: editmodeProvider == false

              // 非編集時
              ? Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: leftsidePadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 48),
                                child: SizedBox(
                                  width: 90 + listSTextBoxOffset,
                                  child: Text(
                                    'カテゴリー',
                                    style: GoogleFonts.notoSans(
                                        fontSize: 16,
                                        color: MyColors.secondaryLabel,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                              Text(
                                '小カテゴリー',
                                style: GoogleFonts.notoSans(
                                    fontSize: 16,
                                    color: MyColors.secondaryLabel,
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '詳細',
                              style: GoogleFonts.notoSans(
                                  fontSize: 16,
                                  color: MyColors.secondaryLabel,
                                  fontWeight: FontWeight.w400),
                            ),
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
                          return GestureDetector(
                            // ヒット範囲を拡大
                            behavior: HitTestBehavior.opaque,
                            onTap: () async {
                              final bigCategoryId =
                                  itemList[index].bigCategoryId;
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: ((context) => SmallCategoryEditPage(
                                      bigCategoryId: bigCategoryId)),
                                ),
                              );
                            },
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: leftsidePadding),
                                  child: SizedBox(
                                    height: 50,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      key: Key('$index'),
                                      children: [
                                        // アイコン
                                        Padding(
                                          padding: const EdgeInsets.all(12.5),
                                          child: itemList.isEmpty
                                              ? const SizedBox(
                                                  height: 25,
                                                  width: 25,
                                                )
                                              : itemList[index].icon,
                                        ),

                                        // カテゴリー名
                                        SizedBox(
                                          width: 90 + listSTextBoxOffset,
                                          child: Text(
                                            itemList.isEmpty
                                                ? ''
                                                : itemList[index]
                                                    .bigCategoryName,
                                            style: GoogleFonts.notoSans(
                                                fontSize: 16,
                                                color: MyColors.label,
                                                fontWeight: FontWeight.w400),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        // 小カテゴリーの列挙
                                        Expanded(
                                          child: Text(
                                            itemList.isEmpty
                                                ? ''
                                                : itemList[index]
                                                    .smallCategoryName,
                                            style: GoogleFonts.notoSans(
                                                fontSize: 14,
                                                color: MyColors.secondaryLabel,
                                                fontWeight: FontWeight.w300),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        // 進むアイコン
                                        const Padding(
                                          padding: EdgeInsets.all(12.5),
                                          child: Icon(
                                              Icons.arrow_forward_ios_rounded,
                                              size: 18,
                                              color: MyColors.white),
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
                          );
                        },
                      ),
                    ),
                  ],
                )

              // 編集時
              : Column(
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: leftsidePadding),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              children: [
                                Text(
                                  '表示',
                                  style: GoogleFonts.notoSans(
                                      fontSize: 16,
                                      color: MyColors.secondaryLabel,
                                      fontWeight: FontWeight.w400),
                                ),
                                const SizedBox(
                                  width: 18,
                                ),
                                SizedBox(
                                  width: 110 + listSTextBoxOffset,
                                  child: Text(
                                    'カテゴリー',
                                    style: GoogleFonts.notoSans(
                                        fontSize: 16,
                                        color: MyColors.secondaryLabel,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                                Text(
                                  '小カテゴリー',
                                  style: GoogleFonts.notoSans(
                                      fontSize: 16,
                                      color: MyColors.secondaryLabel,
                                      fontWeight: FontWeight.w400),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '並べ替え',
                            style: GoogleFonts.notoSans(
                                fontSize: 16,
                                color: MyColors.secondaryLabel,
                                fontWeight: FontWeight.w400),
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
                        child: ReorderableListView.builder(
                      // デフォルトの並べ替えアイコン
                      buildDefaultDragHandles: false,
                      // 並べ替えた時の処理
                      onReorder: (oldIndex, newIndex) async {
                        // awaitせなアイコンがパッパしちゃう
                        await reorderFunction(oldIndex, newIndex);
                        setState(() {
                          // 変更を加えたことを管理する状態管理する
                          isDefaultDisplayEdited = true;
                        });
                      },
                      itemCount: monthlyCategoryBudgetList!.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          key: Key('$index'),
                          children: [
                            // リスト本体
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: leftsidePadding),
                              child: SizedBox(
                                height: 50,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // チェックボックス
                                    Padding(
                                      padding: const EdgeInsets.all(12.5),
                                      child: GestureDetector(
                                        onTap: () {
                                          // チェックボックスのタップ処理
                                          setState(() {
                                            final bool =
                                                itemList[index].isChecked;
                                            // チェックボックスに渡す値を更新する
                                            itemList[index].isChecked = !bool;
                                            // 編集済みフラグを立てる
                                            isDefaultDisplayEdited = true;
                                          });
                                        },
                                        child: CheckBox(
                                            isChecked:
                                                itemList[index].isChecked),
                                      ),
                                    ),

                                    // アイコン
                                    Padding(
                                      padding: const EdgeInsets.all(12.5),
                                      child: itemList[index].icon,
                                    ),

                                    // カテゴリー名
                                    SizedBox(
                                      width: 72 + listSTextBoxOffset,
                                      child: Text(
                                        itemList[index].bigCategoryName,
                                        style: GoogleFonts.notoSans(
                                            fontSize: 18,
                                            color: MyColors.label,
                                            fontWeight: FontWeight.w400),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // 小カテゴリー列挙
                                    SizedBox(
                                      width: 120 + listSTextBoxOffset,
                                      child: Text(
                                        itemList[index].smallCategoryName,
                                        style: GoogleFonts.notoSans(
                                            fontSize: 14,
                                            color: MyColors.secondaryLabel,
                                            fontWeight: FontWeight.w300),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),

                                    // 並べ替えアイコン
                                    ReorderableDragStartListener(
                                      index: index,
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        width: 50,
                                        height: 50,
                                        child: const Icon(
                                          Icons.drag_handle_rounded,
                                          color: MyColors.systemGray2,
                                        ),
                                      ),
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
                        );
                      },
                    )),
                  ],
                )),
    );
  }

  // 目標データの挿入
  void registorFunction() {
    if (isDefaultDisplayEdited) {
      tBL202Impl();
      // スナックバーの表示
      doneSnackBarFunc();
    }
  }

  void tBL202Impl() {
    for (int i = 0; i < itemList.length; i++) {
      // booleanから 0 or 1 に変換
      final isDisplayed = itemList[i].isChecked == true ? 1 : 0;

      final record = TBL202Record(
        id: itemList[i].bigCategoryId,
        colorCode: itemList[i].bigCategoryColor,
        bigCategoryName: itemList[i].bigCategoryName,
        resourcePath: itemList[i].bigCategoryResourcePath,
        displayOrder: itemList[i].editedDisplayOrder,
        isDisplayed: isDisplayed,
      );

      record.update();
    }
  }

  void doneSnackBarFunc() {
    // Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('登録が完了しました'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
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

      // 各カテゴリーの小カテゴリーのリストを取得
      final smallCategoryList = await querySmallCategoryNameList(
          monthlyCategoryBudgetList![i][TBL003RecordKey().bigCategoryId]);
      String smallCategoryNamebuff = '';
      for (int j = 0; j < smallCategoryList.length; j++) {
        if (j == 0) {
          smallCategoryNamebuff += smallCategoryList[j];
        } else {
          smallCategoryNamebuff += ',${smallCategoryList[j]}';
        }
      }

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

        // 各カテゴリーの小カテゴリーのリスト
        smallCategoryName: smallCategoryNamebuff,
      ));
    }
  }

  reorderFunction(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = itemList.removeAt(oldIndex);
    itemList.insert(newIndex, item);

    // itemの表示順を更新
    for (int i = 0; i < itemList.length; i++) {
      itemList[i].editedDisplayOrder = i;
    }
  }

  double listSmallcategoryMemoOffsetGetter(double screenWidthSize) {
    final defaultWidth = ScreenLayoutProperties().defaultWidth;
    return defaultWidth < 0 ? 0 : screenWidthSize - defaultWidth;
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
  // 各カテゴリーの小カテゴリーのリスト
  final String smallCategoryName;

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
    required this.smallCategoryName,
  }) {
    // アイコンの取得
    icon = CategoryHandler().sisytIconGetterFromBigCategoryKey(bigCategoryId);
    // 表示日表示の初期化
    isChecked = isDisplayed == 1 ? true : false;
    // 編集後表示順の初期化
    editedDisplayOrder = gotDisplayOrder;
  }
}
