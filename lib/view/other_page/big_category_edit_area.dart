/// packegeImport
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kakeibo/application/category/category_provider.dart';

/// localImport
import 'package:kakeibo/constant/colors.dart';
import 'package:kakeibo/constant/properties.dart';
import 'package:kakeibo/domain/ui_value/expense_big_category_with_small_list_value/edit_expense_big_category_value.dart';
import 'package:kakeibo/util/extension/media_query_extension.dart';
import 'package:kakeibo/view/other_page/check_box.dart';
import 'package:kakeibo/view_model/state/big_category_edit_page/big_category_edit_list/big_category_edit_list.dart';
import 'package:kakeibo/view_model/state/big_category_edit_page/is_big_category_list_edited/is_big_category_list_edited.dart';

class BigCategoryEditArea extends ConsumerStatefulWidget {
  const BigCategoryEditArea({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BigCategoryEditAreaState();
}

class _BigCategoryEditAreaState extends ConsumerState<BigCategoryEditArea> {
  // アイテムリスト
  late List<EditExpenseBigCategoryValue> itemList;

  bool isInitial = true;

  @override
  void initState() {
    super.initState();

    // 取得したデータをedittingBigCategoryListNotifierProviderに格納し編集できる状態にする
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.watch(allBigCategoriesWithSmallListProvider).whenData((initialList) {
        ref
            .read(edittingBigCategoryListNotifierProvider.notifier)
            .setData(initialList);
      });
    });
  }

  @override
  void dispose() {
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // リスト内テキストボックスの拡大部を計算
    // iphoneProMaxの横幅が430で、それより大きい端末では拡大しない
    // 大カテゴリーと小カテゴリーで増幅分を2等分する
    final listSTextBoxOffset = listSmallcategoryMemoOffsetGetter() / 2;

    // 左のpaddingの大きさを計算
    final leftsidePadding = 14.5 * context.screenHorizontalMagnification;

    // アイテムリストを状態監視
    itemList = ref.watch(edittingBigCategoryListNotifierProvider);

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  children: [
                    Text(
                      '表示',
                      style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: MyColors.secondaryLabel,
                          fontWeight: FontWeight.w400),
                    ),
                    const SizedBox(
                      width: 18,
                    ),
                    SizedBox(
                      width: 110 + listSTextBoxOffset,
                      child: Text(
                        'カテゴリー',
                        style: GoogleFonts.notoSans(
                            fontSize: 16,
                            color: MyColors.secondaryLabel,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                    Text(
                      '小カテゴリー',
                      style: GoogleFonts.notoSans(
                          fontSize: 16,
                          color: MyColors.secondaryLabel,
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              Text(
                '並べ替え',
                style: GoogleFonts.notoSans(
                    fontSize: 16,
                    color: MyColors.secondaryLabel,
                    fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),

        //区切り線
        Divider(
          thickness: 0.25,
          height: 0.25,
          indent: leftsidePadding,
          endIndent: leftsidePadding,
          color: MyColors.separater,
        ),

        // リスト部分
        Expanded(
            child: ReorderableListView.builder(
          // デフォルトの並べ替えアイコン
          buildDefaultDragHandles: false,
          // 並べ替えた時の処理
          onReorder: (oldIndex, newIndex) {
            // カテゴリーの状態を保持しているリストの並び替え
            ref
                .read(edittingBigCategoryListNotifierProvider.notifier)
                .reorder(oldIndex, newIndex);

            // 変更を加えたことを管理する状態管理する
            ref
                .read(isBigCategoryListEditedNotifierProvider.notifier)
                .updateState(true);
          },
          itemCount: itemList.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              key: Key('$index'),
              children: [
                // リスト本体
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: leftsidePadding),
                  child: SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // チェックボックス
                        Padding(
                          padding: const EdgeInsets.all(12.5),
                          child: GestureDetector(
                            onTap: () {
                              // チェックボックスのタップ処理
                              setState(() {
                                // チェックボックスの状態を更新する
                                ref
                                    .read(
                                        edittingBigCategoryListNotifierProvider
                                            .notifier)
                                    .toggleDisplay(index);
                                // 変更を加えたことを管理する状態管理する
                                ref
                                    .read(
                                        isBigCategoryListEditedNotifierProvider
                                            .notifier)
                                    .updateState(true);
                              });
                            },
                            child: CheckBox(
                                isChecked:
                                    itemList[index].etitedStateIsChecked),
                          ),
                        ),

                        // アイコン
                        Padding(
                          padding: const EdgeInsets.all(12.5),
                          child: SvgPicture.asset(
                            itemList[index].resourcePath,
                            semanticsLabel: 'categoryIcon',
                            width: 25,
                            height: 25,
                          ),
                        ),

                        // カテゴリー名
                        SizedBox(
                          width: 72 + listSTextBoxOffset,
                          child: Text(
                            itemList[index].bigCategoryName,
                            style: GoogleFonts.notoSans(
                                fontSize: 18,
                                color: MyColors.label,
                                fontWeight: FontWeight.w400),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // 小カテゴリー列挙
                        SizedBox(
                          width: 120 + listSTextBoxOffset,
                          child: Text(
                            itemList[index].expenseSmallCategoryNameText,
                            style: GoogleFonts.notoSans(
                                fontSize: 14,
                                color: MyColors.secondaryLabel,
                                fontWeight: FontWeight.w300),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        // 並べ替えアイコン
                        ReorderableDragStartListener(
                          index: index,
                          child: Container(
                            alignment: Alignment.centerRight,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.drag_handle_rounded,
                              color: MyColors.systemGray2,
                            ),
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
            );
          },
        )),
      ],
    );
  }

  double listSmallcategoryMemoOffsetGetter() {
    final defaultWidth = ScreenLayoutProperties().defaultWidth;
    return defaultWidth < 0 ? 0 : context.screenWidth - defaultWidth;
  }
}
