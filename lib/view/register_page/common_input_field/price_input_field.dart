import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/number_text_input_formatter.dart';
import 'package:kakeibo/view_model/state/register_page/entered_price_controller.dart';

enum PriceInputFieldStatus {
  normal,// 通常
  unconfirmed,// 未確定
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
        // 購入金額の初期値をセット
        _enteredPriceController.text = widget.originalPrice.toString();
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
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            widget.titleLabel,
            textAlign: TextAlign.left,
            style: MyFonts.placeHolder,
          ),
          Expanded(
            child: widget.priceInputFieldStatus == PriceInputFieldStatus.normal ? TextFormField(
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
