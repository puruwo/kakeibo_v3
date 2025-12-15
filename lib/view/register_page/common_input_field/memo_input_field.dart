import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/view_model/state/register_page/entered_memo_controller.dart';

class MemoInputField extends ConsumerStatefulWidget {
  const MemoInputField(
      {super.key, required this.originalMemo, this.titleLabel = "メモ"});

  final String originalMemo;
  final String titleLabel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MemoInputFieldState();
}

class _MemoInputFieldState extends ConsumerState<MemoInputField> {
  late TextEditingController _enteredMemoController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 初期値をセット
      _enteredMemoController.text = widget.originalMemo;
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
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 5),
        child: SizedBox(
          height: 34,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.titleLabel,
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
                  decoration: const InputDecoration(
                    // trueにするとテキストフィールド全体の密度が下がる
                    isDense: true,
                    // 背景の塗りつぶし
                    filled: false,
                    // テキストの余白をゼロにして中央揃えを実現
                    contentPadding: EdgeInsets.zero,
                    // 境界線なし
                    border: InputBorder.none,
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
