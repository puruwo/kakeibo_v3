import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/income_category_provider.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/util/number_text_input_formatter.dart';
import 'package:kakeibo/view/register_page/input_molecule/income_souce_picker.dart';
import 'package:kakeibo/view_model/state/register_page/entered_income_source_controller/entered_income_source_controller.dart';
import 'package:kakeibo/view_model/state/register_page/entered_price_controller.dart';
import 'package:kakeibo/view_model/state/register_page/original_expense_entity/original_expense_entity.dart';

class ExpenseInputField extends ConsumerStatefulWidget {
  const ExpenseInputField({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ExpenseInputFieldState();
}

class _ExpenseInputFieldState extends ConsumerState<ExpenseInputField> {
  late TextEditingController _enteredPriceController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final originalExpenseEntity =
          ref.read(originalExpenseEntityNotifierProvider);

      // 購入金額の初期値をセット
      _enteredPriceController.text = originalExpenseEntity.price.toString();

      // 拠出元予算カテゴリーの初期値をセット
      ref
          .read(enteredIncomeSourceControllerNotifierProvider.notifier)
          .setData(originalExpenseEntity.incomeSourceBigCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    // コントローラの初期化
    _enteredPriceController = ref.watch(enteredPriceControllerProvider);
    final incomeSourceBigCategory =
        ref.watch(enteredIncomeSourceControllerNotifierProvider);

    return Container(
      decoration: BoxDecoration(
        color: MyColors.secondarySystemfill,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 購入金額入力
            SizedBox(
              height: 40,
              child: Row(
                children: [
                  Text(
                    "購入金額",
                    textAlign: TextAlign.left,
                    style: MyFonts.placeHolder,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _enteredPriceController,
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
                    ),
                  ),
                ],
              ),
            ),

            // 区切り線
            const Divider(
              // ウィジェット自体の高さ
              height: 0,
              // 線の太さ
              thickness: 1,
              indent: 0,
              endIndent: 0,
              color: MyColors.separater,
            ),

            // 拠出元選択
            GestureDetector(
              child: Container(
                decoration: const BoxDecoration(
                  color: MyColors.transparent,
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // プレースホルダー
                    Text(
                      "拠出元",
                      textAlign: TextAlign.left,
                      style: MyFonts.placeHolder,
                    ),

                    // 選択状態
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 拠出元選択状態
                        Text(
                          ref.watch(anIncomeCategoryProvider(incomeSourceBigCategory)).when(
                              data: (data) => data.name,
                              loading: () => '',
                              error: (e, _) => ''),
                          textAlign: TextAlign.right,
                          style: MyFonts.inputText,
                        ),
                        // テキストとアイコンの間のスペース
                        const SizedBox(width: 4),
                        // 矢印アイコン
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: MyColors.secondaryLabel,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              onTap: ()  {
                showDialog(context: context, builder: (context) {
                  return const IncomeSourcePicker();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
