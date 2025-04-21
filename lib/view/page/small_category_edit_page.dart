// packageImport
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// LocalImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/properties.dart';
import 'package:kakeibo/model/assets_conecter/category_handler.dart';
import 'package:kakeibo/model/db_read_impl.dart';
import 'package:kakeibo/model/tableNameKey.dart';
import 'package:kakeibo/domain/tbl201/small_category_entity.dart';
import 'package:kakeibo/domain/tbl202/big_category_entity.dart';
import 'package:kakeibo/util/screen_size_func.dart';
import 'package:kakeibo/view/molecule/icon_button%20copy.dart';
import 'package:kakeibo/view/page/color_select_page.dart';
import 'package:kakeibo/view/page/icon_select_page.dart';
import 'package:kakeibo/view_model/state/small_category_edit_page/selected_color.dart';
import 'package:kakeibo/view_model/state/small_category_edit_page/selected_icon_path.dart';

import 'package:kakeibo/view_model/state/update_DB_count.dart';

class SmallCategoryEditPage extends ConsumerStatefulWidget {
  const SmallCategoryEditPage({super.key, required this.bigCategoryId});
  final int bigCategoryId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SmallCategoryEditPageState();
}

class _SmallCategoryEditPageState extends ConsumerState<SmallCategoryEditPage> {
  // そのカテゴリーのproperty
  Map<String, dynamic>? bigCategoryProperty;

  // そのカテゴリーの情報
  List<Map<String, dynamic>>? categoryData;

  // 小カテゴリーの情報リスト
  final List<ListItem> itemList = [];

  // 編集モードで編集されたかどうか
  bool isEdited202 = false;

  // 編集モードで編集されたかどうか
  bool isEdited201 = false;

  BigCategoryEntity? tbl202record;

  // 入力のコントローラー
  late TextEditingController _categoryNameController;

  // 選択されている色のコード
  late String selectedColorCode;

  // 選択されている色
  late Color selectedColor;

  // 選択されているiconのpath
  late String selectedIconURL;

  @override
  void initState() {
    // 初期化が終わる前にbuildが完了してしまうのでawait&SetStateする
    Future(() async {
      await initialize();
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
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

    selectedIconURL = ref.watch(selectedIconPathNotifierProvider);
    selectedColor = ref.watch(selectedColorNotifierProvider);

    // 選択された色を16進数に変換
    selectedColorCode = selectedColor.red.toRadixString(16).padLeft(2, '0') +
        selectedColor.green.toRadixString(16).padLeft(2, '0') +
        selectedColor.blue.toRadixString(16).padLeft(2, '0');

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Scaffold(
          backgroundColor: MyColors.secondarySystemBackground,

          // ヘッダー
          appBar: AppBar(
            title: Text(
              '小カテゴリーの設定',
              style: GoogleFonts.notoSans(
                  fontSize: 19,
                  color: MyColors.white,
                  fontWeight: FontWeight.w400),
            ),

            backgroundColor: MyColors.secondarySystemBackground,
            //ヘッダー左のアイコンボタン
            leading: IconButton(
                // 閉じるときはネストしているModal内のRouteではなく、root側のNavigatorを指定する必要がある
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_rounded,
                    color: MyColors.white)),
            //ヘッダー右のアイコンボタン
            actions: [
              IconButton(
                icon: const Icon(
                  //完了チェックマーク
                  Icons.done_rounded,
                  color: MyColors.white,
                ),
                onPressed: () {
                  // 登録処理
                  registorFunction();
                },
              ),
            ],
          ),

          // 本体
          body: MediaQuery.withClampedTextScaling(
            // テキストサイズの制御
            minScaleFactor: 0.7,
            maxScaleFactor: 0.95,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // 大カテゴリーの設定ボックス
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, left: 16.0),
                  child: Container(
                    alignment: Alignment.topCenter,
                    decoration: BoxDecoration(
                        color: MyColors.quarternarySystemfill,
                        borderRadius: BorderRadius.circular(18)),
                    height: 135,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // アイコン部分
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return IconSelectPage(
                                    categoryIconPath: selectedIconURL);
                              },
                            );
                            isEdited202 = true;
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // カテゴリーアイコン
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 16.0, left: 18),
                                child: CategoryHandler().iconWidget(
                                    selectedIconURL, selectedColor,
                                    width: 45, height: 45),
                              ),
                              // 編集マーク
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: SvgPicture.asset(
                                  'assets/images/edit.svg',
                                  clipBehavior: Clip.none,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8.0),

                        // カテゴリー名入力部分
                        // メモinputField
                        SizedBox(
                          width: 313,
                          height: 48,
                          child: TextFormField(
                            controller: _categoryNameController,
                            // オートフォーカスさせるか
                            autofocus: true,
                            // テキストの揃え(上下)
                            textAlignVertical: TextAlignVertical.center,
                            // テキストの揃え(左右)
                            textAlign: TextAlign.center,
                            // カーソルの色
                            // cursorColor: MyColors.themeColor,
                            // カーソルの先の太さ
                            cursorWidth: 2,
                            // 入力するテキストのstyle
                            style: const TextStyle(
                                fontSize: 20, color: MyColors.label),
                            // 行数の制約
                            minLines: 1,
                            maxLines: 1,
                            // 最大文字数の制約
                            // maxLength: 20,

                            // 枠や背景などのデザイン
                            decoration: InputDecoration(
                              // なんかわからんおまじない
                              isDense: true,

                              // 背景の塗りつぶし
                              filled: true,
                              fillColor: MyColors.secondarySystemfill,

                              // ヒントテキスト
                              hintText: "カテゴリー名を入力",
                              hintStyle: const TextStyle(
                                  fontSize: 16, color: MyColors.secondaryLabel),

                              // テキストの余白
                              contentPadding: const EdgeInsets.only(
                                  top: 16, bottom: 0, left: 40, right: 16),

                              // テキスト右側のアイコン
                              suffixIcon: Padding(
                                // contentPaddingの影響を受けないので、余白を追加
                                padding: const EdgeInsets.only(right: 0),
                                child: IconButton(
                                  // 右アイコンを押した時の処理
                                  onPressed: () => null,
                                  icon: const Icon(Icons.clear,
                                      size: 14, color: MyColors.blue),
                                ),
                              ),

                              // 境界線を設定しないとアンダーラインが表示されるので透明でもいいから境界線を設定
                              // 何もしていない時の境界線
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: MyColors.jet.withOpacity(0.0),
                                ),
                              ),
                              // 入力時の境界線
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: MyColors.jet.withOpacity(0.0),
                                ),
                              ),
                            ),

                            keyboardAppearance: Brightness.dark,

                            onChanged: (event) {
                              isEdited202 = true;
                            },

                            //キーボードcloseで再描画が走っているので変更を更新してあげる必要あり
                            //領域外をタップでproviderを更新する
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
                      ],
                    ),
                  ),
                ),

                // 余白
                const SizedBox(height: 8.0),

                // カラー選択
                GestureDetector(
                  onTap: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return ColorSelectPage(categoryColor: selectedColor);
                      },
                    );
                    isEdited202 = true;
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                          color: MyColors.quarternarySystemfill,
                          borderRadius: BorderRadius.circular(10)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 16.0, right: 8),
                            child: Container(
                                height: 16,
                                width: 16,
                                decoration: BoxDecoration(
                                  color: selectedColor,
                                  shape: BoxShape.circle,
                                )),
                          ),
                          const Text(
                            'カテゴリーカラー',
                            style:
                                TextStyle(fontSize: 14, color: MyColors.label),
                          )
                        ],
                      ),
                    ),
                  ),
                ),

                // 余白
                const SizedBox(height: 8.0),

                // ヘッダー
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
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
                                '小カテゴリー',
                                style: GoogleFonts.notoSans(
                                    fontSize: 16,
                                    color: MyColors.secondaryLabel,
                                    fontWeight: FontWeight.w400),
                              ),
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

                // 小カテゴリーのリスト
                Expanded(
                    child: ReorderableListView.builder(
                  // デフォルトの並べ替えアイコン
                  buildDefaultDragHandles: false,
                  // 並べ替えた時の処理
                  onReorder: (oldIndex, newIndex) {
                    setState(() {
                      reorderFunction(oldIndex, newIndex);
                      // 変更を加えたことを管理する状態管理する
                    });
                  },
                  itemCount: categoryData!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      key: Key('$index'),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // チェックボックス
                            Padding(
                              padding: EdgeInsets.only(
                                  left: leftsidePadding + 12.5,
                                  right: 22.5,
                                  top: 12.5,
                                  bottom: 12.5),
                              child: GestureDetector(
                                onTap: () {
                                  // チェックボックスのタップ処理
                                  setState(() {
                                    final bool = itemList[index].isChecked;
                                    // チェックボックスに渡す値を更新する
                                    itemList[index].isChecked = !bool;
                                    // 編集済みフラグを立てる
                                    isEdited201 = true;
                                  });
                                },
                                child: CheckBox(
                                    isChecked: itemList[index].isChecked),
                              ),
                            ),

                            // カテゴリー名入力フィーるど
                            SizedBox(
                              width: 150,
                              child: TextField(
                                controller: itemList[index].controller,
                                // テキストフィールドのプロパティ
                                maxLength: 9,
                                textAlign: TextAlign.left,
                                textAlignVertical: TextAlignVertical.top,
                                style: const TextStyle(
                                  color: MyColors.white,
                                  fontSize: 17,
                                ),

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

                                  // あと何文字入力できるかのカウンター
                                  counterText: '',

                                  // テキストの余白
                                  contentPadding: const EdgeInsets.only(
                                      top: 16, bottom: 0, left: 0, right: 16),

                                  // 境界線を設定しないとアンダーラインが表示されるので透明でもいいから境界線を設定
                                  // 何もしていない時の境界線
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: MyColors.jet.withOpacity(0.0),
                                    ),
                                  ),
                                  // 入力時の境界線
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: BorderSide(
                                      color: MyColors.jet.withOpacity(0.0),
                                    ),
                                  ),
                                ),

                                // 編集されたら編集フラグをtrueに
                                onChanged: (value) {
                                  isEdited201 = true;
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

                            // 並べ替えアイコン
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 80,
                              ),
                              child: ReorderableDragStartListener(
                                index: index,
                                child: Container(
                                  alignment: Alignment.centerRight,
                                  width: 70,
                                  height: 50,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      const Icon(
                                        Icons.drag_handle_rounded,
                                        color: MyColors.systemGray2,
                                      ),
                                      SizedBox(
                                        width: leftsidePadding,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
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
            ),
          )),
    );
  }

  initialize() async {
    // DBから取得
    // {
    //  id:
    //  small_category_order_key
    //  big_category_key
    //  displayed_order_in_big
    //  category_name
    //  default_displayed
    // }
    bigCategoryProperty = await getBigCategoryProperty(widget.bigCategoryId);

    // DBから取得
    // {
    //  id:
    //  small_category_order_key
    //  big_category_key
    //  displayed_order_in_big
    //  category_name
    //  default_displayed
    // }
    categoryData = await getCategoryDataFromCategoryId(widget.bigCategoryId);

    // インスタンス化
    tbl202record = BigCategoryEntity(
        id: bigCategoryProperty![TBL202RecordKey().id],
        colorCode: bigCategoryProperty![TBL202RecordKey().colorCode],
        bigCategoryName:
            bigCategoryProperty![TBL202RecordKey().bigCategoryName],
        resourcePath: bigCategoryProperty![TBL202RecordKey().resourcePath],
        displayOrder: bigCategoryProperty![TBL202RecordKey().displayOrder],
        isDisplayed: bigCategoryProperty![TBL202RecordKey().isDisplayed]);

    // itemListの初期化
    for (int i = 0; i < categoryData!.length; i++) {
      itemList.add(ListItem(
        id: categoryData![i][TBL201RecordKey().id],
        smallCategoryOrderKey: categoryData![i]
            [TBL201RecordKey().smallCategoryOrderKey],
        bigCategoryKey: categoryData![i][TBL201RecordKey().bigCategoryKey],
        bigCategoryOrderInBig: categoryData![i]
            [TBL201RecordKey().displayedOrderInBig],
        categoryName: categoryData![i][TBL201RecordKey().categoryName],
        defaultDisplayed: categoryData![i][TBL201RecordKey().defaultDisplayed],
      ));

      _categoryNameController =
          TextEditingController(text: tbl202record!.bigCategoryName);
    }

    // 色コードの初期設定
    selectedColorCode = tbl202record!.colorCode;
    // 色の初期設定
    selectedColor = MyColors().getColorFromHex(tbl202record!.colorCode);
    final selectedColorNotifier =
        ref.read(selectedColorNotifierProvider.notifier);
    selectedColorNotifier.updateState(selectedColor);

    // pathの初期設定
    selectedIconURL = tbl202record!.resourcePath;
    final selectedIconNotifier =
        ref.read(selectedIconPathNotifierProvider.notifier);
    selectedIconNotifier.updateState(selectedIconURL);
  }

  void reorderFunction(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = itemList.removeAt(oldIndex);
    itemList.insert(newIndex, item);

    // itemの表示順を更新
    //
    for (int i = 0; i < itemList.length; i++) {
      itemList[i].editedDisplayOrder = i;
    }

    isEdited201 = true;
  }

  void doneSnackBarFunc() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('登録が完了しました'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));
  }

  void errorSnackBarFunc(String errorMessage) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(errorMessage),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));
  }

  registorFunction() {
    bool isCorrectlyBigCategoryNameInput = true;
    bool isCorrectlySmallCategoryNameInput = true;
    bool isThereCheck = false;

    // 大カテゴリーの名前が入力されているかチェック
    if (_categoryNameController.text == '') {
      isCorrectlyBigCategoryNameInput = false;
      errorSnackBarFunc('カテゴリー名を入力してください。');
    }
    // 小カテゴリーの名前が入力されているかチェック
    for (int i = 0; i < itemList.length; i++) {
      if (itemList[i].controller.text == '') {
        isCorrectlySmallCategoryNameInput = false;
        errorSnackBarFunc('小カテゴリー名を入力してください。');
      }
    }
    // 小カテゴリーの表示選択が0でないかのチェック
    for (int i = 0; i < itemList.length; i++) {
      if (itemList[i].isChecked) {
        isThereCheck = true;
      }
    }
    if (isThereCheck == false) {
      errorSnackBarFunc('一つは表示するようチェックを選択してください。');
    }

    if (isCorrectlyBigCategoryNameInput &&
        isCorrectlySmallCategoryNameInput &&
        isThereCheck) {
      if (isEdited201) {
        tBL201Impl();
      }
      if (isEdited202) {
        tBL202Impl();
      }

      //DB更新のnotifier
      //DBが更新されたことをグローバルなproviderに反映
      dbUpdateNotify();

      doneSnackBarFunc();

      Navigator.of(context).pop();
    }
  }

  dbUpdateNotify() {
    final notifier = ref.read(updateDBCountNotifierProvider.notifier);
    notifier.incrementState();
  }

  void tBL201Impl() {
    for (int i = 0; i < itemList.length; i++) {
      final int id = itemList[i].id;
      final int smallCategoryOrderKey = itemList[i].smallCategoryOrderKey;
      final int bigCategoryKey = itemList[i].bigCategoryKey;
      final int displayOrderInBig = itemList[i].editedDisplayOrder;
      final String categoryName = itemList[i].controller.text;
      final int defaultDisplayed = itemList[i].isChecked == true ? 1 : 0;

      // 目標データのインスタンス化
      final record = SmallCategoryEntity(
          id: id,
          smallCategoryOrderKey: smallCategoryOrderKey,
          bigCategoryKey: bigCategoryKey,
          displayedOrderInBig: displayOrderInBig,
          smallCategoryName: categoryName,
          defaultDisplayed: defaultDisplayed);

      // 目標データの挿入
      record.update();
    }
  }

  void tBL202Impl() {
    final newRecord = BigCategoryEntity(
        id: tbl202record!.id,
        colorCode: selectedColorCode,
        bigCategoryName: _categoryNameController.text,
        resourcePath: selectedIconURL,
        displayOrder: tbl202record!.displayOrder,
        isDisplayed: tbl202record!.isDisplayed);

    newRecord.update();
  }

  double listSmallcategoryMemoOffsetGetter(double screenWidthSize) {
    final defaultWidth = ScreenLayoutProperties().defaultWidth;
    return defaultWidth < 0 ? 0 : screenWidthSize - defaultWidth;
  }
}

class ListItem {
  // カテゴリーのIDを取得
  final int id;
  // 登録画面でのカテゴリーの並び順
  final int smallCategoryOrderKey;
  // 所属する大カテゴリー
  final int bigCategoryKey;
  // DBから取得した大カテゴリー内の表示順
  final int bigCategoryOrderInBig;
  // 編集後表示順
  late int editedDisplayOrder;
  // カテゴリーの名前を取得
  final String categoryName;
  // DBでの表示非表示設定 0 or 1
  final int defaultDisplayed;
  // 表示非表示の設定
  late bool isChecked;
  // 小カテゴリー名のコントローラー
  late TextEditingController controller;

  ListItem({
    required this.id,
    required this.smallCategoryOrderKey,
    required this.bigCategoryKey,
    required this.bigCategoryOrderInBig,
    required this.categoryName,
    required this.defaultDisplayed,
  }) {
    // 表示日表示の初期化
    isChecked = defaultDisplayed == 1 ? true : false;
    // 編集後表示順の初期化
    editedDisplayOrder = bigCategoryOrderInBig;
    // 小カテゴリー名のコントローラーの初期化
    controller = TextEditingController(text: categoryName);
  }
}
