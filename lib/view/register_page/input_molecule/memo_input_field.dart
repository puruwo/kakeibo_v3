import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view_model/state/register_page/entered_memo_controller.dart';
import 'package:kakeibo/view_model/state/register_page/original_expense_entity/original_expense_entity.dart';

class MemoInputField extends ConsumerStatefulWidget {
  const MemoInputField({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MemoInputFieldState();
}

class _MemoInputFieldState extends ConsumerState<MemoInputField> {
  late TextEditingController _enteredMemoController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final originalExpenseEntity =
          ref.read(originalExpenseEntityNotifierProvider);

      // 初期値をセット
      _enteredMemoController.text = originalExpenseEntity.memo;
    });
  }

  @override
  Widget build(BuildContext context) {
    _enteredMemoController = ref.watch(enteredMemoControllerProvider);

    return // メモinputField
        Container(
      decoration: BoxDecoration(
        color: MyColors.secondarySystemfill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 3, 16, 6),
        child: SizedBox(
          height: 36,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                "メモ",
                textAlign: TextAlign.left,
                style: MyFonts.placeHolder,
              ),
              Expanded(
                child: TextFormField(
                  controller: _enteredMemoController,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
