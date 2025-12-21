// packegeImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/edit_expense_small_category_list_value/edit_expense_small_category_value.dart';
import 'package:kakeibo/view/component/button_util.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/editting_small_category_edit_list%20copy/editting_small_category_edit_list.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_small_category_list_edited/is_small_category_list_edited.dart';

class NewSmallCategoryInputNameDialog extends ConsumerStatefulWidget {
  const NewSmallCategoryInputNameDialog({
    required this.bigCategoryId,
    required this.displayedOrderInBig,
    super.key,
  });

  final int bigCategoryId;
  final int displayedOrderInBig;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NewSmallCategoryInputNameDialog();
}

class _NewSmallCategoryInputNameDialog
    extends ConsumerState<NewSmallCategoryInputNameDialog> {
  final _textContoroller = TextEditingController();

  @override
  void dispose() {
    _textContoroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        alignment: Alignment.center,
        height: 150,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('新しい項目名を入力'),
            ),
            TextFormField(
              controller: _textContoroller,
              // オートフォーカスさせるか
              autofocus: true,
              // テキストの揃え(上下)
              textAlignVertical: TextAlignVertical.center,
              // テキストの揃え(左右)
              textAlign: TextAlign.center,
              // カーソルの色
              cursorColor: MyColors.themeColor,
              // カーソルの先の太さ
              cursorWidth: 2,
              // 入力するテキストのstyle
              style: MyFonts.inputText,
              // 行数の制約
              minLines: 1,
              maxLines: 1,
              // 最大文字数の制約
              maxLength: 20,
              // 右下のカウンターを非表示にする
              buildCounter: (
                BuildContext context, {
                required int currentLength,
                required bool isFocused,
                required int? maxLength,
              }) {
                return null;
              },

              // 枠や背景などのデザイン
              decoration: InputDecoration(
                // trueにするとテキストフィールド全体の密度が下がる
                isDense: true,

                // 背景の塗りつぶし
                filled: false,

                // テキストの余白
                contentPadding: const EdgeInsets.only(
                    top: 10, bottom: 10, left: 0, right: 0),

                // 境界線を設定しないとアンダーラインが表示されるので透明でもいいから境界線を設定
                // 何もしていない時の境界線
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: MyColors.transparent,
                  ),
                ),
                // 入力時の境界線
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: MyColors.transparent,
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
            ButtonBar(
              alignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    // キャンセルボタンを押した時の処理
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.buttonSecondary,
                  ),
                  child: Text(
                    'キャンセル',
                    style: MyFonts.secondaryButtonText,
                  ),
                ),
                MainButton(
                  buttonType: ButtonColorType.main,
                  buttonText: 'OK',
                  onPressed: () {
                    // 入力が空の場合は何もしない
                    if (_textContoroller.text.isEmpty) {
                      // スナックバーを表示する
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            '項目名を入力してください',
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      );
                      return;
                    }

                    // 入力された名前を使って新しい小カテゴリーのentityを作成
                    final entity = EditExpenseSmallCategoryValue(
                      id: -1, // 新規作成なのでIDは-1
                      bigCategoryKey: widget.bigCategoryId,
                      name: _textContoroller.text,
                      smallCategoryOrderKey: 0, // 新規作成なので0
                      displayOrderInBig: widget.displayedOrderInBig,
                      defaultDisplayed: 1,
                      editedStateDisplayOrder: widget.displayedOrderInBig,
                      etitedStateIsChecked: true,
                    );

                    // 追加する処理をここに書く
                    ref
                        .read(
                            edittingSmallCategoryListNotifierProvider.notifier)
                        .addSmallCategory(entity);

                    // 変更を加えたことを管理する状態管理する
                    ref
                        .read(
                            isSmallCategoryListEditedNotifierProvider.notifier)
                        .updateState(true);

                    // OKボタンを押した時の処理
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
