import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/repository/torok_record/torok_record.dart';
import 'package:flutter/services.dart';
import 'package:kakeibo/util/number_text_input_formatter.dart';
import 'package:kakeibo/util/screen_size_func.dart';

import 'package:kakeibo/view/organism/category_area.dart';
import 'package:kakeibo/view/organism/torok_selected_segment.dart';
import 'package:kakeibo/view_model/state/register_page/selected_segment_status.dart';
import 'package:kakeibo/view_model/state/register_page/is_registerable.dart';
import 'package:kakeibo/view_model/state/update_DB_count.dart';
import 'package:kakeibo/view_model/state/register_page/when_open.dart';

import 'package:kakeibo/view/organism/date_input_field.dart';
import 'package:kakeibo/view_model/state/register_page/torok_state.dart';

class Torok extends ConsumerStatefulWidget {
  //0:登録モード、1:編集モード
  final int screenMode;
  final TorokRecord torokRecord;

  Torok({this.screenMode = 0, super.key})
      : torokRecord =
            TorokRecord(date: DateFormat('yyyyMMdd').format(DateTime.now()));

  const Torok.origin(
      {this.screenMode = 0, required this.torokRecord, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TorokState();
}

class _TorokState extends ConsumerState<Torok> {
  late TextEditingController _priceInputController;
  late TextEditingController _memoInputController;

  @override
  void initState() {
    // 初期値が0ならpriceInputFieldに空文字を入れる
    final initialPriceData = widget.torokRecord.price == 0
        ? ''
        : widget.torokRecord.price.toString();

    _priceInputController = TextEditingController.fromValue(
      NumberTextInputFormatter().formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(text: initialPriceData),
      ),
    );
    _memoInputController = TextEditingController(text: widget.torokRecord.memo);

    super.initState();
  }

  @override
  void dispose() {
    _priceInputController.dispose();
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

    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * screenHorizontalMagnification;

    //状態管理---------------------------------------------------------------------------------------

    final whenOpenprovider = ref.watch(whenOpenNotifierProvider);

    //ビルド完了時の操作
    //前画面からレコードを受け取っていればそれを設定する
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //リビルドじゃない時
      //データをセットしてwhenOpenフラグをfalseに設定する
      if (whenOpenprovider == true) {
        final notifier = ref.read(torokRecordNotifierProvider.notifier);
        notifier.setData(widget.torokRecord!);
        // 一度openしたというflagを立てる
        final whenOpenNotifier = ref.read(whenOpenNotifierProvider.notifier);
        whenOpenNotifier.updateToOpenedState();
      }
    });

    //支出か収入かの切り替えは登録時のみ可能
    //編集モードでは他のレコードに影響を与える可能性があるため実装しない
    final selectedSegmentedStatus =
        ref.watch(selectedSegmentStatusNotifierProvider);

    //listenもしくはwatchし続けやんとstateが勝手にdisposeされる
    //なのでlistenしている
    //watchやといちいちリビルドされるのでlisten
    ref.listen(
      torokRecordNotifierProvider,
      (oldState, newState) {
        //なんもしやん
      },
    );

    ref.listen(
      isRegisterableNotifierProvider,
      (oldState, newState) {
        //なんもしやん
      },
    );

    //----------------------------------------------------------------------------------------------
    //レイアウト------------------------------------------------------------------------------------

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Scaffold(
        backgroundColor: MyColors.secondarySystemBackground,

        appBar: AppBar(
          // ヘッダーの色
          backgroundColor: MyColors.secondarySystemBackground,

          // ヘッダーの形
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          title: SizedBox(
            child: Text(
              widget.screenMode == 0 ? '記録' : '記録を編集する',
              style: GoogleFonts.notoSans(
                  fontSize: 19,
                  color: MyColors.white,
                  fontWeight: FontWeight.w400),
            ),
          ),

          //ヘッダー右のアイコンボタン
          actions: [
            IconButton(
              icon: const Icon(
                //完了チェックマーク
                Icons.done_rounded,
                color: MyColors.white,
              ),
              onPressed: () async {
                //登録可非のチェック
                final isRegisterable = checkPriceFunc(
                    _priceInputController.text.replaceAll(',', ''),
                    selectedSegmentedStatus);

                //登録できるなら
                if (isRegisterable == true) {
                  //挿入するためにproviderから値をfetch
                  final provider = ref.read(torokRecordNotifierProvider);
                  final id = widget.torokRecord.id;
                  final price =
                      int.parse(_priceInputController.text.replaceAll(',', ''));
                  final selectedDt = provider.date;
                  final selectedCategoryOrderKey = provider.categoryOrderKey;
                  final memo = _memoInputController.text;

                  // TorokRecordにセット
                  final notifier =
                      ref.read(torokRecordNotifierProvider.notifier);
                  notifier.setData(TorokRecord(
                      id: id,
                      price: price,
                      date: selectedDt,
                      memo: memo,
                      categoryOrderKey: selectedCategoryOrderKey));

                  //登録モード
                  if (widget.screenMode == 0) {
                    if (selectedSegmentedStatus == SelectedEnum.sisyt) {
                      final tBL001Record = await notifier.setToTBL001();
                      tBL001Record.insert();
                    } else if (selectedSegmentedStatus == SelectedEnum.syunyu) {
                      final tBL002Record = await notifier.setToTBL002();
                      tBL002Record.insert();
                    }
                    // スナックバーの表示
                    doneSnackBarFunc();
                  }
                  //編集モード
                  else if (widget.screenMode == 1) {
                    if (selectedSegmentedStatus == SelectedEnum.sisyt) {
                      final tBL001Record = await notifier.setToTBL001();
                      tBL001Record.update();
                    } else if (selectedSegmentedStatus == SelectedEnum.syunyu) {
                      final tBL002Record = await notifier.setToTBL002();
                      tBL002Record.update();
                    }
                    // スナックバーの表示
                    changeSnackBarFunc();
                  }
                  //DB更新のnotifier
                  //DBが更新されたことをグローバルなproviderに反映
                  dbUpdateNotify();
                }
                //登録できないなら
                else if (isRegisterable == false) {
                  //エラーハンドル
                  errorSnackBarFunc();
                }
              },
            ),
          ],

          //ヘッダーの左ボタン
          leading: IconButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            icon: const Icon(
              //バッテン
              Icons.close_rounded,
              color: MyColors.white,
            ),
          ),
        ),

        //body
        body: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(leftsidePadding),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  //登録モードなら切り替えを出す
                  //編集モードなら出せない
                  widget.screenMode != 1
                      ? const TorokSelectedSegment()
                      : const SizedBox(
                          height: 0,
                        ),

                  const SizedBox(height: 8),

                  // 値段inputField
                  SizedBox(
                    // 高さを内側から変更するにはcontentsPaddingのプロパティを触る
                    width: 343 * screenHorizontalMagnification,

                    child: TextFormField(
                      controller: _priceInputController,
                      // オートフォーカスさせるか
                      autofocus: true,
                      // テキストの揃え(上下)
                      textAlignVertical: TextAlignVertical.center,
                      // テキストの揃え(左右)
                      textAlign: TextAlign.end,
                      // カーソルの色
                      cursorColor: MyColors.themeColor,
                      // カーソルの先の太さ
                      cursorWidth: 2,
                      // 入力するテキストのstyle
                      style:
                          const TextStyle(fontSize: 17, color: MyColors.label),
                      // 行数の制約
                      minLines: 1,
                      maxLines: 1,
                      // 最大文字数の制約
                      // maxLength: 20,

                      // 数字のみ
                      inputFormatters: [NumberTextInputFormatter()],
                      keyboardType: TextInputType.number,
                      keyboardAppearance: Brightness.dark,

                      // 枠や背景などのデザイン
                      decoration: InputDecoration(
                        // なんかわからんおまじない
                        isDense: true,

                        // 背景の塗りつぶし
                        filled: true,
                        fillColor: MyColors.secondarySystemfill,

                        // ヒントテキスト
                        hintText: "値段を入力",
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          color: MyColors.secondaryLabel,
                        ),

                        // テキストの余白
                        contentPadding: const EdgeInsets.only(
                            top: 10, bottom: 10, left: 40, right: 16),

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
                      // //領域外をタップでproviderを更新する
                      onTapOutside: (event) {
                        //キーボードを閉じる
                        FocusScope.of(context).unfocus();
                      },
                      onEditingComplete: () {
                        //キーボードを閉じる
                        FocusScope.of(context).unfocus();
                      },

                      //0が入力されたらコントローラーを初期化する
                      onChanged: (value) {
                        if (value == '0') {
                          return _priceInputController.clear();
                        }
                      },
                    ),
                  ),

                  const SizedBox(height: 8),

                  // メモinputField
                  SizedBox(
                    width: 343 * screenHorizontalMagnification,
                    // height: 100,
                    child: TextFormField(
                      controller: _memoInputController,
                      // オートフォーカスさせるか
                      autofocus: true,
                      // テキストの揃え(上下)
                      textAlignVertical: TextAlignVertical.center,
                      // テキストの揃え(左右)
                      textAlign: TextAlign.end,
                      // カーソルの色
                      cursorColor: MyColors.themeColor,
                      // カーソルの先の太さ
                      cursorWidth: 2,
                      // 入力するテキストのstyle
                      style:
                          const TextStyle(fontSize: 17, color: MyColors.label),
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
                        hintText: "メモ",
                        hintStyle: const TextStyle(
                          fontSize: 16,
                          color: MyColors.secondaryLabel,
                        ),

                        // テキストの余白
                        contentPadding: const EdgeInsets.only(
                            top: 10, bottom: 10, left: 40, right: 16),

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

                  const SizedBox(height: 8),

                  // 日付選択エリア
                  const DateDisplay(),

                  const SizedBox(height: 16),

                  // カテゴリー選択エリア
                  const CategoryArea(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool checkPriceFunc(
      String stringPrice, SelectedEnum selectedSegmentedStatus) {
    //torokrecordの金額を取得
    late bool isRegisterable;
    if (selectedSegmentedStatus == SelectedEnum.sisyt) {
      // 文字列の金額をint型に変換
      late int intPrice;
      if (stringPrice == '') {
        intPrice = 0;
      } else {
        intPrice = int.parse(stringPrice);
      }

      //エラーチェック
      //金額分岐でisRegisterableの更新とメッセージ定義
      if (intPrice <= 0) {
        isRegisterable = false;
      } else if (intPrice >= 1888888) {
        isRegisterable = false;
      } else {
        isRegisterable = true;
      }
    } else if (selectedSegmentedStatus == SelectedEnum.syunyu) {
      isRegisterable = true;
    }

    return isRegisterable;
  }

  void changeSnackBarFunc() {
    Navigator.of(context, rootNavigator: true).pop();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
        content: Text('変更が完了しました'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));
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

  void errorSnackBarFunc() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(
          content: Text('正しく入力してください'),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2)));
  }

  void dbUpdateNotify() {
    final notifier2 = ref.read(updateDBCountNotifierProvider.notifier);
    notifier2.incrementState();
  }
}
