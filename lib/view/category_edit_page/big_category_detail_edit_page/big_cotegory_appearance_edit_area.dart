import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:kakeibo/application/category/category_provider.dart';
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/dialog/color_select_dialog.dart';
import 'package:kakeibo/view/category_edit_page/big_category_detail_edit_page/dialog/icon_select_dialog.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/big_category_color_contoroller/big_category_color_contoroller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/big_category_icon_contoroller/big_category_icon_contoroller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/big_category_name_contoroller/big_category_name_contoroller.dart';
import 'package:kakeibo/view_model/state/big_category_detail_edit_page/is_big_category_appearance_edited/is_big_category_appearance_edited.dart';

class BigCategoryAppearanceEditArea extends ConsumerStatefulWidget {
  const BigCategoryAppearanceEditArea({required this.bigId, super.key});

  final int bigId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BigCategoryAppearanceEditAreaState();
}

class _BigCategoryAppearanceEditAreaState
    extends ConsumerState<BigCategoryAppearanceEditArea> {
  @override
  void initState() {
    super.initState();

    // 取得したデータをedittingSmallCategoryListNotifierProviderに格納し編集できる状態にする
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // -1の時は新規作成のため、initialItemはなく、下記処理はしない
      if (widget.bigId == -1) {
        return;
      }

      Future(() async {
        // 一度だけ取得してセット
        final initialItem =
            await ref.watch(bigCategoriesProvider(widget.bigId).future);

        ref.read(bigCategoryNameControllerProvider).text =
            initialItem.bigCategoryName;
        ref
            .read(bigCategroyColorControllerNotifierProvider.notifier)
            .initState(MyColors().getColorFromHex(initialItem.colorCode));
        ref
            .read(bigCategroyIconControllerNotifierProvider.notifier)
            .initState(initialItem.resourcePath);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final iconPath = ref.watch(bigCategroyIconControllerNotifierProvider);
    final color = ref.watch(bigCategroyColorControllerNotifierProvider);

    return Column(
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
                        return const IconSelectDialog();
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // カテゴリーアイコン
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, left: 18),
                        child: SvgPicture.asset(
                          iconPath,
                          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                          semanticsLabel: 'categoryIcon',
                          width: 45,
                          height: 45,
                        ),
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
                    controller: ref.watch(bigCategoryNameControllerProvider),
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
                    style: const TextStyle(fontSize: 20, color: MyColors.label),
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
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(
                              color: MyColors.systemfill,
                              shape: BoxShape.circle,
                            ),
                          ),
                          IconButton(
                            // 右アイコンを押した時の処理
                            onPressed: () => {
                              // テキストフィールドの内容をクリア
                              ref
                                  .read(bigCategoryNameControllerProvider)
                                  .clear(),

                              // 大カテゴリーの見た目が編集されたことを通知
                              ref
                                  .read(
                                      isBigCategoryAppearanceEditedNotifierProvider
                                          .notifier)
                                  .updateState(true),
                            },
                            icon: const Icon(Icons.clear,
                                size: 14, color: MyColors.white),
                          ),
                        ]),
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
                      // 大カテゴリーの見た目が編集されたことを通知
                      ref
                          .read(isBigCategoryAppearanceEditedNotifierProvider
                              .notifier)
                          .updateState(true);
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
                return const ColorSelectDialog();
              },
            );
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
                    padding: const EdgeInsets.only(left: 16.0, right: 8),
                    child: Container(
                        height: 16,
                        width: 16,
                        decoration: BoxDecoration(
                          color: ref.watch(
                              bigCategroyColorControllerNotifierProvider),
                          shape: BoxShape.circle,
                        )),
                  ),
                  const Text(
                    'カテゴリーカラー',
                    style: TextStyle(fontSize: 14, color: MyColors.label),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
