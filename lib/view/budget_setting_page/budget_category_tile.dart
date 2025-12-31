import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/strings.dart';
import 'package:kakeibo/domain/ui_value/budget_edit_value/budget_edit_value.dart';
import 'package:kakeibo/util/common_widget/inkwell_util.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/util/number_text_input_formatter.dart';
import 'package:kakeibo/util/util.dart';
import 'package:kakeibo/view_model/state/budget_edit_page/is_price_edited/is_price_edited.dart';
import 'package:kakeibo/view_model/state/budget_edit_page/price_controller/price_controller.dart';
import 'package:kakeibo/view_model/state/monthly_plan_page/footer_state_controller/footer_state_controller.dart';

class BudgetCategoryTile extends ConsumerStatefulWidget {
  const BudgetCategoryTile({super.key, required this.budgetEditValue});

  final BudgetEditValue budgetEditValue;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BudgetCategoryTileState();
}

class _BudgetCategoryTileState extends ConsumerState<BudgetCategoryTile> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // リスト内テキストボックスの拡大部を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    // 大カテゴリーと小カテゴリーで増幅分を2等分する
    final listSTextBoxOffset = context.screenHorizontalMagnification / 2;

    // カレンダーサイズから左の空白の大きさを計算
    final leftsidePadding = 14.5 * context.screenHorizontalMagnification;

    final controller =
        ref.watch(enteredBudgetPriceControllerProvider(widget.budgetEditValue));

    // フッターの状態を取得
    // 非編集時はTextFieldを表示しないので、編集時のみ表示する
    final state = ref.watch(footerStateControllerNotifierProvider);

    return Column(
      children: [
        // リスト本体
        Column(
          children: [
            SizedBox(
              height: 50,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  key: Key(widget.budgetEditValue.id.toString()),
                  children: [
                    // アイコン
                    Padding(
                      padding: const EdgeInsets.all(12.5),
                      child: SvgPicture.asset(
                        widget.budgetEditValue.resourcePath,
                        colorFilter: ColorFilter.mode(
                            MyColors().getColorFromHex(
                                widget.budgetEditValue.colorCode),
                            BlendMode.srcIn),
                        semanticsLabel: 'categoryIcon',
                        width: 25,
                        height: 25,
                      ),
                    ),

                    // カテゴリー名
                    SizedBox(
                      width: 70 + listSTextBoxOffset * 2,
                      child: Text(
                        widget.budgetEditValue.expenseBigCategoryName,
                        style: BudgetSettingsStyles.categoryTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // 先月の実績
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 64,
                          child: Text(
                            formattedPriceGetterAndZeroAsHyphen(
                                widget.budgetEditValue.lastMonthBudgetPrice),
                            style: BudgetSettingsStyles.subPrice,
                            textAlign: TextAlign.right,
                          ),
                        ),
                        Text(
                          ' 円',
                          style: BudgetSettingsStyles.yenText,
                        )
                      ],
                    ),

                    // 金額入力フィールド

                    AppInkWell(
                      borderRadius: BorderRadius.circular(8),
                      // readOnly時のタップで編集モードに切り替え
                      onTap: () {
                        if (state != TabState.budgetEdditing) {
                          ref
                              .read(footerStateControllerNotifierProvider
                                  .notifier)
                              .updateState(TabState.budgetEdditing);
                          _focusNode.requestFocus();
                        }
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          SizedBox(
                            width: 100,
                            child: TextField(
                              controller: controller,
                              focusNode: _focusNode,
                              readOnly: state != TabState.budgetEdditing,
                              // テキストフィールドのプロパティ
                              textAlign: TextAlign.right,
                              textAlignVertical: TextAlignVertical.top,
                              style: BudgetSettingsStyles.textField,
                              inputFormatters: [
                                // カンマのフォーマット
                                NumberTextInputFormatter()
                              ],

                              // TextFieldのタップイベント
                              // 親AppInkWellでもonTap制御しているが、テキストフィールドは別途制御を記載しないと反応しない
                              onTap: () {
                                if (state != TabState.budgetEdditing) {
                                  ref
                                      .read(
                                          footerStateControllerNotifierProvider
                                              .notifier)
                                      .updateState(TabState.budgetEdditing);
                                  _focusNode.requestFocus();
                                }
                              },

                              // デコレーション
                              decoration: InputDecoration(
                                // なんかわからんおまじない
                                isDense: true,

                                // 背景の塗りつぶし
                                filled: false,

                                // ヒントテキスト
                                // 空文字かどうかを判定することで、入力時再描画のちらつきを防止する
                                hintText:
                                    controller.text.isNotEmpty ? "" : "金額を入力",
                                hintStyle: BudgetSettingsStyles.textFieldHint,

                                // テキストの余白
                                contentPadding: const EdgeInsets.only(
                                    top: 16, bottom: 0, left: 0, right: 0),

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

                                // 入力テキストの末尾に「円」を表示
                                suffix: controller.text.isNotEmpty
                                    ? Text(
                                        ' 円',
                                        style: BudgetSettingsStyles.yenText,
                                      )
                                    : null,
                              ),
                              keyboardType: TextInputType.number,

                              // 編集されたら編集フラグをtrueに
                              onChanged: (value) {
                                // setStateをかますことでwidgetが再描画される
                                setState(() {
                                  ref
                                      .read(isPriceEditedNotifierProvider
                                          .notifier)
                                      .updateState(true);
                                });
                              },
                              // //領域外をタップでproviderを更新する
                              onTapOutside: (event) {
                                //キーボードを閉じる
                                // FocusScope.of(context).unfocus();
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
      ],
    );
  }
}
