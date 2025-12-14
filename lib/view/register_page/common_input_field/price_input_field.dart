import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/number_text_input_formatter.dart';
import 'package:kakeibo/view_model/state/register_page/entered_price_controller.dart';

enum PriceInputFieldStatus {
  normal, // 通常
  unconfirmed, // 未確定
}

class PriceInputField extends ConsumerStatefulWidget {
  const PriceInputField(
      {super.key,
      required this.originalPrice,
      required this.priceInputFieldStatus,
      this.titleLabel = "購入金額"});

  final int originalPrice;
  final PriceInputFieldStatus priceInputFieldStatus;
  final String titleLabel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PriceInputFieldState();
}

class _PriceInputFieldState extends ConsumerState<PriceInputField> {
  late TextEditingController _enteredPriceController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ビルドして最初の一回だけ設定
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // 購入金額の初期値をセット（カンマ区切りでフォーマット）
        _enteredPriceController.text =
            NumberTextInputFormatter.formatInitialValue(widget.originalPrice);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // コントローラの初期化
    _enteredPriceController = ref.watch(enteredPriceControllerProvider);

    return SizedBox(
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
            child: widget.priceInputFieldStatus == PriceInputFieldStatus.normal
                ? TextFormField(
                    controller: _enteredPriceController,
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
                    // カーソルの太さ
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

                    //0が入力されたらコントローラーを初期化する
                    onChanged: (value) {
                      if (value == '0') {
                        return _enteredPriceController.clear();
                      }
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
                  )
                : Text(
                    '---',
                    style: MyFonts.inputExpenseText,
                    textAlign: TextAlign.end,
                  ),
          ),
        ],
      ),
    );
  }
}
