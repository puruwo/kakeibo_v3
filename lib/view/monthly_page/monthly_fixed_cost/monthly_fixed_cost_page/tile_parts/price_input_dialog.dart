// packegeImport
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/fixed_cost_expense/fixed_cost_expense_usecase.dart';

// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/monthly_fixed_cost_value/monthly_unconfirmed_fixed_cost_tile_value/monthly_unconfirmed_fixed_cost_tile_value.dart';
import 'package:kakeibo/util/number_text_input_formatter.dart';

class PriceInputDialog extends ConsumerStatefulWidget {
  const PriceInputDialog({
    required this.value,
    super.key,
  });

  final MonthlyUnconfirmedFixedCostTileValue value;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PriceInputDialog();
}

class _PriceInputDialog extends ConsumerState<PriceInputDialog> {
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
              child: Text('未確定固定費の金額を入力'),
            ),
            TextFormField(
              controller: _textContoroller,
              // 入力するテキストのstyle
              style: MyFonts.inputExpenseText,

              // オートフォーカスさせるか
              autofocus: true,
              // テキストの揃え(上下)
              textAlignVertical: TextAlignVertical.center,
              // テキストの揃え(左右)
              textAlign: TextAlign.end,
              // カーソルの色
              cursorColor: MyColors.themeColor,
              // カーソルの高さ
              cursorHeight: 25,
              // カーソルの先の太さ
              cursorWidth: 2,
              // 行数の制約
              minLines: 1,
              maxLines: 1,
              // 最大文字数の制約
              maxLength: 10,
              // 右下のカウンターを非表示にする
              buildCounter: (
                BuildContext context, {
                required int currentLength,
                required bool isFocused,
                required int? maxLength,
              }) {
                return null;
              },

              // 数字のみ
              inputFormatters: [NumberTextInputFormatter()],
              keyboardType: TextInputType.number,
              keyboardAppearance: Brightness.dark,

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

              //0が入力されたらコントローラーを初期化する
              onChanged: (value) {
                if (value == '0') {
                  return _textContoroller.clear();
                }
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

            // ボタンエリア
            ButtonBar(
              alignment: MainAxisAlignment.end,
              children: [
                // キャンセルボタン
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

                // OKボタン
                ElevatedButton(
                  onPressed: () {
                    // 入力が空の場合は何もしない
                    if (_textContoroller.text.isEmpty ||
                        _textContoroller.text == '0') {
                      // スナックバーを表示する
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text(
                            '金額を入力してください',
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

                    // 入力された金額を整数に変換して、FixedCostExpenseRepositoryを通じて更新
                    ref.read(fixedCostExpenseUsecaseProvider).confirmExpense(
                          tileValue: widget.value,
                          confirmedPrice: int.parse(_textContoroller.text
                              .replaceAll(RegExp(r'\D'), '')),
                        );

                    // OKボタンを押した時の処理
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.buttonPrimary,
                  ),
                  child: Text(
                    'OK',
                    style: MyFonts.secondaryButtonText,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
